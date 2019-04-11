//
//  C1PhotoHeader.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 04/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

class C1PhotoHeader: UITableViewHeaderFooterView, IReusableCell {
    
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lblTitle: Label!
    
    var disposeBag: DisposeBag = DisposeBag()
    
}
