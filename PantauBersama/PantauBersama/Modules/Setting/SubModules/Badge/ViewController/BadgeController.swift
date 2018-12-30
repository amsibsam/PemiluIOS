//
//  BadgeController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class BadgeController: UIViewController {
    
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    var viewModel: BadgeViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // MARK: TableView
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.registerReusableCell(BadgeCell.self)
        tableView.estimatedRowHeight = 73
        tableView.rowHeight = UITableView.automaticDimension
          tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        // MARK: Bind viewModel
        buttonClose.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.input.refreshI)
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .distinctUntilChanged()
            .flatMapLatest { (offset) -> Observable<Void> in
                if offset.y > self.tableView.contentSize.height -
                    (self.tableView.frame.height * 2) {
                    return Observable.just(())
                } else {
                    return Observable.empty()
                }
            }
            .bind(to: viewModel.input.nextTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.badgeItems
            .drive(tableView.rx.items) { (tableView, index, item) -> UITableViewCell in
                let cell: BadgeCell = tableView.dequeueReusableCell()
                item.configure(cell: cell)
                return cell
            }
            .disposed(by: disposeBag)
        
        viewModel.output.loading
            .drive(onNext: { [unowned self](loading) in
                self.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.configure(with: .transparent)
    }
    
}
