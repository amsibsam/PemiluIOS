//
//  PopupChallengeCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking

enum PopupChallengeResult {
    case cancel
    case oke(String)
}

protocol PopupChallengeNavigator {
    func back() -> Observable<Void>
}

final class PopupChallengeCoordinator: BaseCoordinator<PopupChallengeResult> {
    
    private let navigationController: UINavigationController
    private let viewController: PopupChallengeController
    var type: PopupChallengeType
    var data: Challenge
    
    init(navigationController: UINavigationController, type: PopupChallengeType, data: Challenge) {
        self.navigationController = navigationController
        self.viewController = PopupChallengeController()
        self.type = type
        self.data = data
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = PopupChallengeViewModel(navigator: self)
        let viewController = PopupChallengeController()
        viewController.type = type
        viewController.data = data
        viewController.viewModel = viewModel
//        viewController.providesPresentationContextTransitionStyle = true
//        viewController.definesPresentationContext = true
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        navigationController.present(viewController, animated: true, completion: nil)
        return viewModel.output.actionSelected
            .asObservable()
            .take(1)
            .do(onNext: { [weak self] (_) in
                self?.navigationController.dismiss(animated: true, completion: nil)
            })
    }
}

extension PopupChallengeCoordinator: PopupChallengeNavigator {
    func back() -> Observable<Void> {
        let root = UIApplication.shared.keyWindow?.rootViewController
        root?.dismiss(animated: true, completion: nil)
        return Observable.empty()
    }
}
