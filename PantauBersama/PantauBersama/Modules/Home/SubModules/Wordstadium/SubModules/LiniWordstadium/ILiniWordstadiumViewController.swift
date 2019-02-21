//
//  ILiniWordstadiumViewViewController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 22/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Common

protocol ILiniWordstadiumViewController where Self: UIViewController {
    var viewModel: ILiniWordstadiumViewModel! { get }
    var disposeBag: DisposeBag { get }
    
    func registerCells(with tableView: UITableView)
    func bind(headerView: BannerHeaderView, with viewModel: ILiniWordstadiumViewModel)
    func bind(tableView: UITableView, with viewModel: ILiniWordstadiumViewModel)
}

extension ILiniWordstadiumViewController {
    func registerCells(with tableView: UITableView) {
        tableView.registerReusableCell(WordstadiumViewCell.self)
        tableView.registerReusableCell(SectionViewCell.self)
        tableView.registerReusableCell(SectionViewCell2.self)
        tableView.registerReusableCell(SeeMoreCell.self)
        tableView.registerReusableCell(WordstadiumItemViewCell.self)
    }
    
    func bind(tableView: UITableView, with viewModel: ILiniWordstadiumViewModel){
        
        viewModel.output.moreSelectedO
            .asObservable()
            .flatMapLatest({ [weak self] (wordstadium) -> Observable<WordstadiumType> in
                return Observable.create({ (observer) -> Disposable in
                    
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let salin = UIAlertAction(title: "Salin Tautan", style: .default, handler: { (_) in
                        observer.onNext(WordstadiumType.salin(data: wordstadium))
                        observer.on(.completed)
                    })
                    let bagikan = UIAlertAction(title: "Bagikan", style: .default, handler: { (_) in
                        observer.onNext(WordstadiumType.bagikan(data: wordstadium))
                        observer.on(.completed)
                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: nil)
                    
                    alert.addAction(salin)
                    alert.addAction(bagikan)
                    alert.addAction(cancel)
                    DispatchQueue.main.async {
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    return Disposables.create()
                })
            })
            .bind(to: viewModel.input.moreMenuI)
            .disposed(by: disposeBag)
        
        viewModel.output.moreMenuSelectedO
            .filter { !$0.isEmpty }
            .drive(onNext: { (message) in
                UIAlertController.showAlert(withTitle: "", andMessage: message)
            })
            .disposed(by: disposeBag)
    }
    
    func bind(headerView: BannerHeaderView, with viewModel: ILiniWordstadiumViewModel) {
        viewModel.output.bannerO
            .drive(onNext: { (banner) in
                headerView.config(banner: banner, viewModel: self.viewModel.headerViewModel)
            })
            .disposed(by: disposeBag)

    }
}
