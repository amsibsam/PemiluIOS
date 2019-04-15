//
//  RekapCoordinator.swift
//  PantauBersama
//
//  Created by asharijuang on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import Networking


protocol MerayakanNavigator: RekapNavigator, PerhitunganNavigator {
    func launchSearch() -> Observable<Void>
    func launchNotifications() -> Observable<Void>
    func launchProfile() -> Observable<Void>
    func launchNote() -> Observable<Void>
}

class MerayakanCoordinator: BaseCoordinator<Void> {
    var navigationController: UINavigationController!
    private var filterCoordinator: PenpolFilterCoordinator!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = MerayakanController()
        let viewModel = MerayakanViewModel(navigator: self)
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: true)
        return Observable.never()
    }
}

extension MerayakanCoordinator : MerayakanNavigator {
    func launchLink() -> Observable<Void> {
        let webView = WKWebCoordinator(navigationController: navigationController, url: "https://app.pantaubersama.com/")
        return coordinate(to: webView)
    }
    
    func launchBanner(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
    
    
    func launchDetail(item: Region) -> Observable<Void> {
        let rekapList = RekapListCoordinator(navigationController: navigationController, region: item)
        return coordinate(to: rekapList)
    }
    
    func launchSearch() -> Observable<Void> {
        let searchCoordinator = SearchCoordinator(navigationController: navigationController)
        return coordinate(to: searchCoordinator)
    }
    
    func launchNote() -> Observable<Void> {
        let noteCoordinator = CatatanCoordinator(navigationController: navigationController)
        return coordinate(to: noteCoordinator)
    }
    
    func launchProfile() -> Observable<Void> {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController, isMyAccount: true, userId: nil)
        return coordinate(to: profileCoordinator)
    }
    
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
    
    func launchNotifications() -> Observable<Void> {
        let notificationCoordinator = NotificationCoordinator(navigationController: navigationController)
        return coordinate(to: notificationCoordinator)
    }
}
