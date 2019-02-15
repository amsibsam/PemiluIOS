//
//  ChallengeController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class ChallengeController: UIViewController {
    
    @IBOutlet weak var containerHeader: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var headerTantanganView: HeaderTantanganView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var challengeButton: ChallengeButtonView!
    @IBOutlet weak var containerContent: UIView!
    @IBOutlet weak var imageContent: UIImageView!
    @IBOutlet weak var titleContent: UILabel!
    @IBOutlet weak var subtitleContent: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerAcceptChallenge: UIView!
    @IBOutlet weak var containerTerima: RoundView!
    @IBOutlet weak var btnTerima: Button!
    @IBOutlet weak var containerTolak: RoundView!
    @IBOutlet weak var btnTolak: Button!
    
    @IBOutlet weak var btnBack: ImageButton!
    
    var viewModel: ChallengeViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnBack.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}
