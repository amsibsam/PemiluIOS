//
//  PenpolFilterCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

public enum FilterType {
    case question
    case quiz
    case pilpres
    case janji
    case user
    case cluster
}

class PenpolFilterCoordinator: BaseCoordinator<Void> {
    let navigationController: UINavigationController
    var filterType: FilterType! {
        didSet {
            if oldValue != filterType {
                reloadFilterTable = true
            } else {
                reloadFilterTable = false
            }
        }
    }
    var filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>!
    private var reloadFilterTable: Bool = false
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = PenpolFilterController()
        let viewModel = PenpolFilterViewModel(filterItems: generateFilterItems(), filterTrigger: filterTrigger)
        viewController.viewModel = viewModel
        viewController.reloadTable = reloadFilterTable
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        
        return viewModel.output.apply
            .do(onNext: { [weak self](_) in
                self?.navigationController.popViewController(animated: true)
            })
            .asObservable()
    }
    
    private func generateFilterItems() -> [PenpolFilterModel] {
        switch filterType {
        case .question?:
            return PenpolFilterModel.generateQuestionFilter()
        case .quiz?:
            return PenpolFilterModel.generateQuizFilter()
        case .pilpres?:
            return PenpolFilterModel.generatePilpresFilter()
        case .janji?:
            return PenpolFilterModel.generateJanjiFilter()
        case .user?:
            return PenpolFilterModel.generateUsersFilter()
        case .cluster?:
            return PenpolFilterModel.generateClusterFilter()
        default:
            return []
        }
    }
}
