//
//  PerhitunganController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 24/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class PerhitunganController: UITableViewController {
    private lazy var headerView =  BannerHeaderView()
    private lazy var btnCreate: UIButton = {
       let btn = UIButton()
        btn.adjustsImageWhenHighlighted = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(#imageLiteral(resourceName: "icCreate"), for: .normal)
        
        return btn
    }()
    
    private var emptyView = EmptyView()
    private var viewModel: PerhitunganViewModel!
    private let disposeBag = DisposeBag()
    
    internal lazy var rControl = UIRefreshControl()
    
    convenience init(viewModel: PerhitunganViewModel) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(btnCreate)
        configureConstraint()
        tableView.registerReusableCell(PerhitunganCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableHeaderView = headerView
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = rControl
        } else {
            tableView.addSubview(rControl)
        }
        
        btnCreate.rx.tap
            .bind(to: viewModel.input.createPerhitunganTrigger)
            .disposed(by: disposeBag)
        
        rControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.input.refreshTrigger)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: viewModel.input.itemSelectTrigger)
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
        
        viewModel.output.createPerhitunganO
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.output.bannerInfo
            .drive(onNext: { (banner) in
                self.headerView.config(banner: banner, viewModel: self.viewModel.headerViewModel)
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.infoSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.feedsCells
            .do(onNext: { [weak self] (items) in
                guard let `self` = self else { return }
                self.tableView.backgroundView = nil
                if items.count == 0 {
                    self.emptyView.frame = self.tableView.bounds
                    self.tableView.backgroundView = self.emptyView
                } else {
                    self.tableView.backgroundView = nil
                }
                self.refreshControl?.endRefreshing()
            })
            .drive(tableView.rx.items) { tableView, row, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) else {
                    return UITableViewCell()
                }
                cell.tag = row
                item.configure(cell: cell)
                return cell
            }
            .disposed(by: disposeBag)
        
        viewModel.output.moreSelected
            .asObservable()
            .flatMapLatest({ [weak self] (data) -> Observable<PerhitunganType> in
                return Observable.create({ (observer) -> Disposable in
                    
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let hapus = UIAlertAction(title: "Hapus", style: .default, handler: { (_) in
                        observer.onNext(PerhitunganType.hapus(data: data))
                        observer.on(.completed)
                    })
                    let edit = UIAlertAction(title: "Ubah Data TPS", style: .default, handler: { (_) in
                        observer.onNext(PerhitunganType.edit(data: data))
                        observer.on(.completed)
                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: nil)
                    
                    if data.status == .sandbox {
                        alert.addAction(edit)
                        alert.addAction(cancel)
                    } else if data.status == .published {
                        alert.addAction(hapus)
                        alert.addAction(cancel)
                    } else {
                        alert.addAction(hapus)
                        alert.addAction(edit)
                        alert.addAction(cancel)
                    }
                    
                    DispatchQueue.main.async {
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    return Disposables.create()
                })
            })
            .bind(to: viewModel.input.moreMenuTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.moreMenuSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelected
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.input.refreshTrigger.onNext(())
    }
    
    private func configureConstraint() {
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                btnCreate.heightAnchor.constraint(equalToConstant: 60),
                btnCreate.widthAnchor.constraint(equalToConstant: 60),
                btnCreate.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                btnCreate.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
                ])
        } else {
            // Fallback on earlier versions
            NSLayoutConstraint.activate([
                btnCreate.heightAnchor.constraint(equalToConstant: 60),
                btnCreate.widthAnchor.constraint(equalToConstant: 60),
                btnCreate.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 20),
                btnCreate.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 20)
                ])
        }
    }
}
