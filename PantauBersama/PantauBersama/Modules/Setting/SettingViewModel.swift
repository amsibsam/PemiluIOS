//
//  SettingViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import TwitterKit
import FBSDKLoginKit
import FBSDKCoreKit
import Common

protocol ISettingViewModelInput {
    var backI: AnyObserver<Void> { get }
    var itemSelectedI: AnyObserver<IndexPath> { get }
    var viewWillAppearTrigger: AnyObserver<Void> { get }
    var itemTwitterI: AnyObserver<String> { get }
    var facebookI: AnyObserver<String> { get }
    var facebookGraphI: AnyObserver<Void> { get }
    var refreshI: AnyObserver<Void> { get }
 }

protocol ISettingViewModelOutput {
    var itemsO: Driver<[SectionOfSettingData]> { get }
    var itemSelectedO: Driver<Void> { get }
    var itemTwitterO: Driver<String> { get }
    var facebookO: Driver<Void> { get }
    var facebookMeO: Driver<MeFacebookResponse> { get }
    var loadingO: Driver<Bool> { get }
    var errorO: Driver<Error> { get }
    var meO: Driver<User> { get }
}

protocol ISettingViewModel {
    var input: ISettingViewModelInput { get }
    var output: ISettingViewModelOutput { get }
    
    var navigator: SettingNavigator! { get }
}

final class SettingViewModel: ISettingViewModel, ISettingViewModelInput, ISettingViewModelOutput {
    
    var input: ISettingViewModelInput { return self }
    var output: ISettingViewModelOutput { return self }
    
    var navigator: SettingNavigator!
    
    // Input
    var backI: AnyObserver<Void>
    var itemSelectedI: AnyObserver<IndexPath>
    var viewWillAppearTrigger: AnyObserver<Void>
    var itemTwitterI: AnyObserver<String>
    var facebookI: AnyObserver<String>
    var facebookGraphI: AnyObserver<Void>
    var refreshI: AnyObserver<Void>
    
    // Output
    var itemsO: Driver<[SectionOfSettingData]>
    var itemSelectedO: Driver<Void>
    var itemTwitterO: Driver<String>
    var facebookO: Driver<Void>
    var facebookMeO: Driver<MeFacebookResponse>
    var loadingO: Driver<Bool>
    var errorO: Driver<Error>
    var meO: Driver<User>
    
    
    private let backS = PublishSubject<Void>()
    private let editS = PublishSubject<Int>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    private let userData: User
    private let viewWillAppearS = PublishSubject<Void>()
    private let itemTwitterS = PublishSubject<String>()
    private let viewControllerS = PublishSubject<UIViewController?>()
    private let facebookS = PublishSubject<String>()
    private let facebookGraphS = PublishSubject<Void>()
    private let refreshS = PublishSubject<Void>()
    
    init(navigator: SettingNavigator, data: User) {
        self.navigator = navigator
        self.navigator.finish = backS
        self.userData = data
    
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        backI = backS.asObserver()
        itemSelectedI = itemSelectedS.asObserver()
        viewWillAppearTrigger = viewWillAppearS.asObserver()
        itemTwitterI = itemTwitterS.asObserver()
        facebookI = facebookS.asObserver()
        facebookGraphI = facebookGraphS.asObserver()
        refreshI = refreshS.asObserver()
        
        let cloudMe = Observable.merge(
            viewWillAppearS.asObservable(),
            refreshS.asObservable())
            .flatMapLatest { (_) -> Observable<User> in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI.me,
                                   c: BaseResponse<UserResponse>.self)
                    .map({ $0.data.user })
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asObservable()
                    .catchErrorJustComplete()
            }
        
        let item = cloudMe
            .flatMapLatest { (user) -> Observable<[SectionOfSettingData]> in
                return Observable.just([
                    SectionOfSettingData(header: nil, items: [
                        SettingData.updateProfile,
                        SettingData.updatePassword,
                        SettingData.verifikasi,
                        SettingData.badge
                        ], isHide: false),
                    SectionOfSettingData(header: "Twitter", items: [
                        SettingData.twitter(data: user)
                        ], isHide: false),
                    SectionOfSettingData(header: "Facebook", items: [
                        SettingData.facebook(data: user)
                        ], isHide: false),
                    SectionOfSettingData(header: "Cluster", items: [
                        SettingData.cluster
                        ], isHide: data.cluster == nil),
                    SectionOfSettingData(header: "SUPPORT", items: [
                        SettingData.pusatBantuan,
                        SettingData.pedomanKomunitas,
                        SettingData.tentang,
                        SettingData.rate,
                        SettingData.share
                        ], isHide: false),
                    SectionOfSettingData(header: nil, items: [
                        SettingData.logout ], isHide: false)])
            }
        
        let items = item
            .map { (a) -> [SectionOfSettingData] in
                return a.filter({$0.isHide == false})
            }
            .asDriverOnErrorJustComplete()
        
        let verifikasi = NetworkService.instance.requestObject(
            PantauAuthAPI.verifications,
            c: BaseResponse<VerificationsResponse>.self)
            .map({ $0.data.user })
            .asObservable()
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
        
        let itemSelected = itemSelectedS
            .withLatestFrom(items) { indexPath, item in
                return item[indexPath.section].items[indexPath.row]
            }
            .flatMap { (type) -> Observable<Void> in
                switch type {
                case .logout:
                    return navigator.launchSignOut(data: data)
                case .badge:
                    return navigator.launchBadge(userId: data.id)
                case .verifikasi:
                    // MARK
                    // Fetch verifications data
                    return verifikasi.flatMapLatest({ navigator.launchVerifikasi(user: $0)})
                    
                case .updateProfile:
                    return navigator.launchProfileEdit(data: data, type: ProfileHeaderItem.editProfile)
                case .updatePassword:
                    let urlEditProfile = "\(AppContext.instance.infoForKey("DOMAIN_SYMBOLIC"))/users/edit"
                    return navigator.launchWKWeb(link: urlEditProfile)
                case .updateDataLapor:
                    return navigator.launchProfileEdit(data: data, type: ProfileHeaderItem.editDataLapor)
                case .cluster:
                      return navigator.launchUndang(data: data)
                case .twitter(let user):
                    if user.twitter == true {
                        return navigator.launchTwitterAlert()
                    } else {
                        return TWTRTwitter.sharedInstance().loginTwitter()
                            .flatMapLatest({ (session) -> Observable<Void> in
                                UserDefaults.Account.set("Connected as \(session.userName)", forKey: .usernameTwitter)
                                UserDefaults.Account.set(session.userID, forKey: .userIdTwitter)
                                return NetworkService.instance
                                    .requestObject(PantauAuthAPI
                                        .accountsConnect(
                                            type: "twitter",
                                            oauthToken: session.authToken,
                                            oauthSecret: session.authTokenSecret),
                                                   c: BaseResponse<AccountResponse>.self)
                                    .trackError(errorTracker)
                                    .trackActivity(activityIndicator)
                                    .catchErrorJustComplete()
                                    .mapToVoid()
                            })
                            .mapToVoid()
                    }
                case .facebook(let user):
                    if user.facebook == true {
                        return navigator.launchFacebookAlert()
                    } else {
                        return Observable.empty()
                    }
                case .pusatBantuan:
                    return navigator.launchWKWeb(link: AppContext.instance.infoForKey("FAQ_PANTAU"))
                case .pedomanKomunitas:
                    return navigator.launchWKWeb(link: AppContext.instance.infoForKey("COMMUNITY_PANTAU"))
                case .tentang:
                    return navigator.launchAbout()
                case .rate:
                    return navigator.launchRate()
                case .share:
                    return navigator.lauchShareApp()
                }
        }
        
        
        // MARK
        // Facbeook
        let facebook = facebookS
            .flatMapLatest { (result) -> Observable<Void> in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI
                        .accountsConnect(type: "facebook",
                                         oauthToken: result,
                                         oauthSecret: ""),
                                   c: BaseResponse<AccountResponse>.self)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .catchErrorJustComplete()
                    .mapToVoid()
            }.mapToVoid()
        
        let meFacebook = facebookGraphS
            .flatMapLatest { (_) -> Observable<MeFacebookResponse> in
                if let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, email, gender, birthday, photos"]) {
                    return request.fetchMeFacebook()
                }
                return Observable<MeFacebookResponse>.empty()
            }
        
        itemsO = items
        itemSelectedO = itemSelected.asDriverOnErrorJustComplete()
        itemTwitterO = itemTwitterS.asDriver(onErrorJustReturn: "")
        facebookO = facebook.asDriverOnErrorJustComplete()
        facebookMeO = meFacebook.asDriverOnErrorJustComplete()
        loadingO = activityIndicator.asDriver()
        errorO = errorTracker.asDriver()
        meO = cloudMe.asDriverOnErrorJustComplete()
    }
    
}
