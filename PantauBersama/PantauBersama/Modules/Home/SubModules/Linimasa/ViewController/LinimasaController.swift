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
import AlamofireImage

class LinimasaController: UIViewController {
    
    @IBOutlet weak var filter: UIButton!
    @IBOutlet weak var addJanji: UIButton!
    @IBOutlet weak var segementedControl: SegementedControl!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var navbar: Navbar!
    var viewModel: LinimasaViewModel!
    
    lazy var pilpresViewModel = PilpresViewModel(navigator: viewModel.navigator)
    lazy var janjiViewModel = JanjiPolitikViewModel(navigator: viewModel.navigator)
    
    private lazy var pilpresController = PilpresViewController(viewModel: pilpresViewModel)
    private lazy var janjiController = JanjiPolitikViewController(viewModel: janjiViewModel)
    
    private lazy var searchBar: UISearchBar = {
       let search = UISearchBar()
        search.searchBarStyle = .minimal
        search.sizeToFit()
        return search
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        add(childViewController: pilpresController, context: container)
        add(childViewController: janjiController, context: container)
    
        // MARK
        // bind to viewModel
        filter.rx.tap
            .bind(to: viewModel.input.filterTrigger)
            .disposed(by: disposeBag)
        
        addJanji.rx.tap
            .bind(to: viewModel.input.addTrigger)
            .disposed(by: disposeBag)
    
        navbar.profile.rx.tap
            .bind(to: viewModel.input.profileTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.filterSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.addSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.profileSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.userO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let user = response.user
                if let thumbnail = user.avatar.thumbnail.url {
                    self.navbar.avatar.af_setImage(withURL: URL(string: thumbnail)!)
                }
            })
            .disposed(by: disposeBag)
        
        // MARK
        // segmented control value
        // assign extension Reactive UIControl
        segementedControl.rx.value
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] i in
                UIView.animate(withDuration: 0.3, animations: {
                    if i == 0 {
                        self.pilpresController.view.alpha = 1.0
                        self.janjiController.view.alpha = 0.0
                        self.addJanji.isHidden = true
                    } else {
                        self.pilpresController.view.alpha = 0.0
                        self.janjiController.view.alpha = 1.0
                        self.addJanji.isHidden = false
                    }
                })
            })
            .disposed(by: disposeBag)
        
        // MARK
        // Navigation bar hide
        // when scrolling tableViews
//        let tableViews = [self.pilpresController.tableView,
//                          self.janjiController.tableView]
//        tableViews.forEach { tableView in
//            guard let tableView = tableView else { return }
//            tableView.scrollsToTop = true
//            Driver.merge([
//                pilpresController.tableView.rx.contentOffset.asDriver(),
//                janjiController.tableView.rx.contentOffset.asDriver()
//                ])
//                .drive(onNext: { position in
//                    UIView.animate(withDuration: 0.3, animations: {
//                        if position.y >= 153.0 {
//                            self.navigationController?.isNavigationBarHidden = true
//                        } else {
//                            self.navigationController?.isNavigationBarHidden = false
//                        }
//                    })
//                })
//                .disposed(by: disposeBag)
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        viewModel.input.viewWillAppearTrigger.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
}
