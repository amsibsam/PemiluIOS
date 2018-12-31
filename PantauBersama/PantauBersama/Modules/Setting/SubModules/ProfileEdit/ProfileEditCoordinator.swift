//
//  ProfileEditCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import UIKit
import Networking

protocol ProfileEditNavigator {
    var finish: Observable<Void>! { get set }
    func back()
    func launchMore(_ item: SectionOfProfileInfoData) -> Observable<Void>
}

class ProfileEditCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    var finish: Observable<Void>!
    private var data: User
    private var type: ProfileHeaderItem
    
    init(navigationController: UINavigationController, data: User, type: ProfileHeaderItem) {
        self.navigationController = navigationController
        self.data = data
        self.type = type
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = ProfileEditViewModel(navigator: self, data: data, type: type)
        let viewController = ProfileEditController()
        viewController.user = data
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension ProfileEditCoordinator: ProfileEditNavigator {
    
    func launchMore(_ item: SectionOfProfileInfoData) -> Observable<Void> {
        let editCoordinator = EditCoordinator(navigationController: navigationController, item: item)
        return coordinate(to: editCoordinator)
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
}
