//
//  RekapViewModel.swift
//  PantauBersama
//
//  Created by asharijuang on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Networking
import Common

final class RekapViewModel: ViewModelType {
    
    var input: Input
    var output: Output

    struct Input {
        
    }
    
    struct Output {
        
    }
    
    let navigator: MerayakanNavigator
    
    init(navigator: MerayakanNavigator, searchTrigger: PublishSubject<String>? = nil, showTableHeader: Bool) {
        self.navigator = navigator
    
        input = Input(
        
        )
        
        output = Output(
            
        )
    }
}