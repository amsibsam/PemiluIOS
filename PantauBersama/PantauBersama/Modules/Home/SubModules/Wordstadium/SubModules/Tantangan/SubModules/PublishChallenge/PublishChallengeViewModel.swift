//
//  PublishChallengeViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import TwitterKit
import FBSDKLoginKit

class PublishChallengeViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let twitterI: AnyObserver<Bool>
        let facebookI: AnyObserver<Bool>
        let twitterLoginI: AnyObserver<Void>
        let refreshI: AnyObserver<Void>
        let facebookLoginI: AnyObserver<String>
        let facebookGraphI: AnyObserver<Void>
        let publishI: AnyObserver<Void>
    }
    
    struct Output {
        let meO: Driver<User>
        let twitterO: Driver<Bool>
        let facebookO: Driver<Bool>
        let twitterLoginO: Driver<Void>
        let facebookLoginO: Driver<Void>
        let facebookGraphO: Driver<MeFacebookResponse>
        let enableO: Driver<Bool>
        let publishO: Driver<Void>
    }
    
    private let backS = PublishSubject<Void>()
    private let twitterS = PublishSubject<Bool>()
    private let facebookS = PublishSubject<Bool>()
    private let twitterLoginS = PublishSubject<Void>()
    private let refreshS = PublishSubject<Void>()
    private let facebookLoginS = PublishSubject<String>()
    private let facebookGraphS = PublishSubject<Void>()
    private let publishS = PublishSubject<Void>()
    
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    private var navigator: PublishChallengeNavigator
    private var type: Bool
    private var model: ChallengeModel
    
    init(navigator: PublishChallengeNavigator, type: Bool, model: ChallengeModel) {
        self.navigator = navigator
        self.navigator.finish = backS
        self.type = type
        self.model = model
        
        input = Input(backI: backS.asObserver(),
                      twitterI: twitterS.asObserver(),
                      facebookI: facebookS.asObserver(),
                      twitterLoginI: twitterLoginS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      facebookLoginI: facebookLoginS.asObserver(),
                      facebookGraphI: facebookGraphS.asObserver(),
                      publishI: publishS.asObserver())
        
        
        let twitter = twitterLoginS
            .flatMapLatest { (_) -> Observable<Void> in
                return TWTRTwitter.sharedInstance().loginTwitter()
                    .flatMapLatest({ (session) -> Observable<Void> in
                        UserDefaults.Account.set("Connected as \(session.userName)", forKey: .usernameTwitter)
                        UserDefaults.Account.set(session.userID, forKey: .userIdTwitter)
                        return NetworkService.instance
                            .requestObject(PantauAuthAPI.accountsConnect(type: "twitter", oauthToken: session.authToken, oauthSecret: session.authTokenSecret), c: BaseResponse<AccountResponse>.self)
                            .trackError(self.errorTracker)
                            .trackActivity(self.activityIndicator)
                            .do(onNext: { (response) in
                                print(response)
                            }, onError: { (error) in
                                print(error.localizedDescription)
                            })
                            .catchErrorJustComplete()
                            .mapToVoid()
                    })
            }.asDriverOnErrorJustComplete()
        
        let facebook = facebookLoginS
            .flatMapLatest { (result) -> Observable<Void> in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI.accountsConnect(type: "facebook", oauthToken: result, oauthSecret: ""), c: BaseResponse<AccountResponse>.self)
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustComplete()
                    .mapToVoid()
        }.asDriverOnErrorJustComplete()
        
        let facebookMe = facebookGraphS
            .flatMapLatest { (_) -> Observable<MeFacebookResponse> in
                if let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, email, gender, birthday, photos"]) {
                    return request.fetchMeFacebook()
                }
                return Observable<MeFacebookResponse>.empty()
        }.asDriverOnErrorJustComplete()
        
        let user = refreshS
            .flatMapLatest { (_) -> Observable<User> in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI.me,
                                   c: BaseResponse<UserResponse>.self)
                    .map({ $0.data.user })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
                    .catchErrorJustComplete()
            }
            .asDriverOnErrorJustComplete()
        
        let enable = twitterS
            .startWith(false)
            .asDriverOnErrorJustComplete()
        
        let publishOpen = publishS
            .flatMapLatest { (_) -> Observable<Void> in
                return NetworkService.instance
                    .requestObject(WordstadiumAPI
                        .createChallengeOpen(statement: model.statement ?? "",
                                             source: model.source ?? "",
                                             timeAt: model.timeAt ?? "",
                                             timeLimit: Int(model.limitAt ?? "") ?? 0,
                                             topic: model.tag ?? "")
                        , c: BaseResponse<TagKajianResponse>.self)
                    .asObservable()
                    .mapToVoid()
        }.asDriverOnErrorJustComplete()
        
        
        
        output = Output(meO: user,
                        twitterO: twitterS.asDriverOnErrorJustComplete(),
                        facebookO: facebookS.asDriverOnErrorJustComplete(),
                        twitterLoginO: twitter,
                        facebookLoginO: facebook,
                        facebookGraphO: facebookMe,
                        enableO: enable,
                        publishO: publishOpen)
        
    }
    
}
