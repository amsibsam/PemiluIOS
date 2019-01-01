//
//  CreateJanjiCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

protocol CreateJanjiNavigator {
    var finish: Observable<Void>! { get set }
    func back()
}


class CreateJanjCoordinator: BaseCoordinator<Void> {
    
    private var navigationController: UINavigationController!
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = CreateJanjiController()
        let viewModel = CreateJanjiViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
}

extension CreateJanjCoordinator: CreateJanjiNavigator {
    func back() {
        guard let viewController = navigationController.viewControllers.first else {
            return
        }
        navigationController.popToViewController(viewController, animated: true)
    }
}
