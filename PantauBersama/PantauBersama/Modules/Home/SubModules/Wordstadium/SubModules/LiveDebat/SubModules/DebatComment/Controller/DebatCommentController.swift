//
//  DebatCommentController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 19/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import RxDataSources
import Networking

class DebatCommentController: UIViewController {
    @IBOutlet weak var viewInputContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var staticNavigationBar: UINavigationBar!
    @IBOutlet weak var btnClose: UIBarButtonItem!
    @IBOutlet weak var tvComment: UITextView!
    @IBOutlet weak var btnSend: ImageButton!
    var viewModel: DebatCommentViewModel!
    
    private let disposeBag = DisposeBag()
    private var animatedDataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Word>>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 70))
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(DebatCommentCell.self)
        
        
        animatedDataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Word>> (configureCell: { dataSouce, tableView, indexPath, word in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as DebatCommentCell
            cell.configureCell(item: DebatCommentCell.Input(word: word))
            return cell
        })
        
        viewModel.output.commentsO
            .map({ word in
                [AnimatableSectionModel(model: "Section", items: word)]
            })
            .asObservable()
            .bind(to: tableView.rx.items(dataSource: animatedDataSource))
            .disposed(by: disposeBag)
        
        
        btnSend.rx.tap
            .map({ self.tvComment.text.trimmingCharacters(in: .whitespacesAndNewlines) })
            .filter({ (content) -> Bool in
                return !content.isEmpty && self.tvComment.textColor != .lightGray
            })
            .do(onNext: { [unowned self](_) in
                self.tvComment.text = ""
            })
            .bind(to: self.viewModel.input.sendCommentI)
            .disposed(by: disposeBag)
        
        viewModel.output.loadCommentsO
            .drive()
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .distinctUntilChanged()
            .flatMapLatest { [unowned self] (offset) -> Observable<Void> in
                if offset.y > self.tableView.contentSize.height - (self.tableView.frame.height * 2) {
                    return Observable.just(())
                } else {
                    return Observable.empty()
                }
            }
            .bind(to: viewModel.input.nextI)
            .disposed(by: disposeBag)
        
        viewModel.output.sendCommentO
            .map({ word in
                [AnimatableSectionModel(model: "Section", items: [word])]
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.newCommentO
            .map({ word in
                [AnimatableSectionModel(model: "Section", items: [word])]
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.input.loadCommentI.onNext(())
        configureInputView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        staticNavigationBar.isTranslucent = true
        staticNavigationBar.barTintColor = .clear
        staticNavigationBar.setBackgroundImage(UIImage(), for: .default)
        staticNavigationBar.shadowImage = UIImage()
        staticNavigationBar.tintColor = .black
        
        btnClose.rx.tap
            .bind { [unowned self](_) in
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
    
//    private func scrollToBottom(animated: Bool = true) {
//        if (self.tableView.indexPathsForVisibleRows?.count ?? 0) != 0 {
//            self.tableView.scrollToRow(at: IndexPath(row: self.viewModel.output.commentsO.value.count - 1, section: 0), at: .bottom, animated: animated)
//        }
//    }
    
    private func configureInputView() {
        viewModel.output.viewTypeO
            .drive(onNext: { [unowned self]viewType in
                switch viewType {
                case .done, .participant:
                    self.viewInputContainer.isHidden = true
                    break
                default:
                    self.viewInputContainer.isHidden = false
                    break
                }
            })
            .disposed(by: disposeBag)
        
        tvComment.text = "Tulis Komentar"
        tvComment.textColor = .lightGray
        
        tvComment.rx.didBeginEditing.bind { [unowned self]in
            if self.tvComment.textColor == .lightGray {
                self.tvComment.text = nil
                self.tvComment.textColor = Color.primary_black
            }
            }
            .disposed(by: disposeBag)
        
        tvComment.rx.didEndEditing.bind { [unowned self]in
            if self.tvComment.text.isEmpty {
                self.tvComment.text = "Tulis Komentar"
                self.tvComment.textColor = .lightGray
            }
            }
            .disposed(by: disposeBag)
    }
}

//extension DebatCommentController: UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.output.commentsO.value.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let word = self.viewModel.output.commentsO.value[indexPath.row]
//        let cell = tableView.dequeueReusableCell() as DebatCommentCell
//        cell.configureCell(item: DebatCommentCell.Input(word: word))
//
//        return cell
//    }
//}
//
//
//extension DebatCommentController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row == self.viewModel.output.commentsO.value.count - 1 {
//            self.viewModel.input.nextI.onNext(())
//        }
//    }
//
//}
