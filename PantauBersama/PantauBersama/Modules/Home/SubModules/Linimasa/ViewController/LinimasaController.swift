//
//  LinimasaController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class LinimasaController: UIViewController {
    
    
    @IBOutlet weak var segementedControl: SegementedControl!
    @IBOutlet weak var container: UIView!
    
    private lazy var pilpresController = PilpresViewController()
    private lazy var janjiController = JanjiPolitikViewController()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        add(childViewController: pilpresController, context: container)
        add(childViewController: janjiController, context: container)
        
        let notifications = UIBarButtonItem(image: #imageLiteral(resourceName: "icNotif"), style: .plain, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = notifications
        
//        segementedControl.rx
//                .value
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.configure(type: .pantau)
    }
    
}
