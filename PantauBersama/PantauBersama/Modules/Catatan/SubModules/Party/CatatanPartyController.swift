//
//  CatatanPartyController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 23/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Common

class CatatanPartyController: UIViewController {
    
    @IBOutlet weak var lblPreferenceParty: Label!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: CatatanPartyViewModel!
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: CatatanPartyViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerReusableCell(PartyCell.self)
        tableView.rowHeight = 60.0
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.delegate = nil
        tableView.dataSource = nil
        
        viewModel.output.itemsO
            .drive(tableView.rx.items) { tableView, row, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) else {
                    return UITableViewCell()
                }
                cell.tag = row
                item.configure(cell: cell)
                return cell
            }
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
            .bind(to: viewModel.input.nextTriggerI)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: viewModel.input.itemSelectedI)
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelectedO
            .do(onNext: { [weak self] (political) in
                self?.lblPreferenceParty.text = "(\(political.name))"
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.userDataO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let user = response.user
                self.lblPreferenceParty.text = user.politicalParty?.name
                // check state number selected cell
                // - 1 for indexes array
                if user.politicalParty != nil {
                    if let number = user.politicalParty?.number {
                        self.tableView.selectRow(at: IndexPath(row: number - 1 , section: 0), animated: false, scrollPosition: .none)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppearI.onNext(())
    }
}

