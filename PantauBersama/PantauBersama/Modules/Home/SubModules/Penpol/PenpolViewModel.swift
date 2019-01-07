//
//  PenpolViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class PenpolViewModel: ViewModelType {
    var input: Input
    var output: Output
    
    struct Input {
        let addTrigger: AnyObserver<Void>
        let filterTrigger: AnyObserver<(type: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>)>
        let refreshTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let filterSelected: Driver<Void>
        let addSelected: Driver<Void>
    }
    
    let navigator: PenpolNavigator
    private let addSubject = PublishSubject<Void>()
    private let filterSubject = PublishSubject<(type: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>)>()
    private let refreshSubject = PublishSubject<Void>()
    
    init(navigator: PenpolNavigator) {
        self.navigator = navigator
        
        input = Input(addTrigger: addSubject.asObserver(), filterTrigger: filterSubject.asObserver(), refreshTrigger: refreshSubject.asObserver())
        
        let add = addSubject
            .flatMap({navigator.launchCreateAsk()})
            .asDriver(onErrorJustReturn: ())
        
        let filter = filterSubject
            .flatMap({ navigator.launchFilter(filterType: $0.type, filterTrigger: $0.filterTrigger) })
            .asDriver(onErrorJustReturn: ())
        
        output = Output(filterSelected: filter, addSelected: add)
    }
}
