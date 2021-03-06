//
//  ProfileCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import Networking

protocol ProfileNavigator: BadgeNavigator,IQuestionNavigator,IJanpolNavigator {
    func back()
    func launchSetting(user: User) -> Observable<Void>
    func launchVerifikasi(user: VerificationsResponse.U) -> Observable<Void>
    func launchReqCluster() -> Observable<Void>
    func launchUndangAnggota(data: User) -> Observable<Void>
    func launchAlertExitCluster() -> Observable<Void>
    func lauchAlertCluster() -> Observable<Void>
    func launchBadge(userId: String?) -> Observable<Void>
    func launchClusterDetail(cluster: ClusterDetail) -> Observable<Void>
}


final class ProfileCoordinator: BaseCoordinator<Void> {
    
    var navigationController: UINavigationController!
    private var isMyAccount: Bool
    private var userId: String?
    
    init(navigationController: UINavigationController, isMyAccount: Bool, userId: String?) {
        self.navigationController = navigationController
        self.isMyAccount = isMyAccount
        self.userId = userId
    }
    
    override func start() -> Observable<Void> {
        let viewController = ProfileController()
        let viewModel = ProfileViewModel(navigator: self, isMyAccount: isMyAccount, userId: userId)
        viewController.viewModel = viewModel
        viewController.isMyAccount = isMyAccount
        viewController.userId = userId
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        return Observable.empty()
    }
}

extension ProfileCoordinator: ProfileNavigator {
    func launchJanjiDetail(data: JanjiPolitik) -> Observable<DetailJanpolResult> {
        let janjiDetailCoordinator = DetailJanjiCoordinator(navigationController: navigationController, data: data.id)
        return coordinate(to: janjiDetailCoordinator)
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
    
    func launchSetting(user: User) -> Observable<Void> {
        let settingCoordinator = SettingCoordinator(navigationController: navigationController, data: user)
        return coordinate(to: settingCoordinator)
    }
    func launchVerifikasi(user: VerificationsResponse.U) -> Observable<Void>  {
        switch user.nextStep {
        case 1:
            let identitasCoordinator = IdentitasCoordinator(navigationController: navigationController)
            return coordinate(to: identitasCoordinator)
        case 2:
            let selfIdentitasCoordinator = SelfIdentitasCoordinator(navigationController: navigationController)
            return coordinate(to: selfIdentitasCoordinator)
        case 3:
            let ktpCoordinator = KTPCoordinator(navigationController: navigationController)
            return coordinate(to: ktpCoordinator)
        case 4:
            let signatureCoordinator = SignatureCoordinator(navigationController: navigationController)
            return coordinate(to: signatureCoordinator)
        case 5:
            let successCoordinator = SuccessCoordinator(navigationController: navigationController)
            return coordinate(to: successCoordinator)
        default :
            let identitasCoordinator = IdentitasCoordinator(navigationController: navigationController)
            return coordinate(to: identitasCoordinator)
        }
    }
    func launchReqCluster() -> Observable<Void> {
        let reqClusterCoordinator = ReqClusterCoordinator(navigationController: navigationController)
        return coordinate(to: reqClusterCoordinator)
            .filter({ $0 == .create })
            .mapToVoid()
    }
    
    func launchUndangAnggota(data: User) -> Observable<Void> {
        let undangAnggotaCoordinator = UndangAnggotaCoordinator(navigationController: navigationController, data: data)
        return coordinate(to: undangAnggotaCoordinator)
    }
    
    func launchAlertExitCluster() -> Observable<Void> {
        return Observable<ClusterOption>.create({ [weak self] (observer) -> Disposable in
            let alert = UIAlertController(title: nil, message: "Apakah anda ingin keluar dari Cluster?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: { (_) in
                observer.onNext(.cancel)
                observer.on(.completed)
            }))
            alert.addAction(UIAlertAction(title: "Ya", style: .default
                , handler: { (_) in
                    observer.onNext(.done)
                    observer.on(.completed)
            }))
            DispatchQueue.main.async {
                self?.navigationController.present(alert, animated: true, completion: nil)
            }
            return Disposables.create()
        })
            .filter({ $0 == .done })
            .mapToVoid()
            .flatMapLatest({ self.deleteCluster() })
    }
    
    func lauchAlertCluster() -> Observable<Void> {
        return Observable<ClusterOption>.create({ [weak self] (observer) -> Disposable in
            let alert = UIAlertController(title: nil, message: "Anda bukan moderator atau admin dari Cluster ini", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Oke", style: .default
                , handler: { (_) in
                    observer.onNext(.done)
                    observer.on(.completed)
            }))
            DispatchQueue.main.async {
                self?.navigationController.present(alert, animated: true, completion: nil)
            }
            return Disposables.create()
        }).mapToVoid()
    }
    
    func launchShare(id: String) -> Observable<Void> {
        let shareCoordinator = ShareBadgeCoordinator(navigationController: navigationController, id: id)
        return coordinate(to: shareCoordinator)
    }

    func launchBadge(userId: String?) -> Observable<Void> {
        let badgeCoordinator = BadgeCoordinator(navigationController: navigationController, userId: userId ?? "")
        return coordinate(to: badgeCoordinator)
    }
    
    func launchClusterDetail(cluster: ClusterDetail) -> Observable<Void> {
        let clusterDetailCoordinator = ClusterDetailCoordinator(navigationController: navigationController, cluster: cluster)
        return coordinate(to: clusterDetailCoordinator)
    }
}

extension ProfileCoordinator {
    
    func deleteCluster() -> Observable<Void> {
        return NetworkService.instance
            .requestObject(PantauAuthAPI.deleteCluster,
                           c: BaseResponse<DeleteCluster>.self)
            .asObservable()
            .catchErrorJustComplete()
            .mapToVoid()
    }
}
