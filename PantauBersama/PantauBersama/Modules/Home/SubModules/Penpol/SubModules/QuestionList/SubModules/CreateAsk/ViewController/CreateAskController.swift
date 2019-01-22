//
//  CreateAskController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import Lottie

class CreateAskController: UIViewController {
    
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lbFullname: Label!
    @IBOutlet weak var tvQuestion: UITextView!
    @IBOutlet weak var lbQuestionLimit: Label!
    
    lazy var loadingAnimation: LOTAnimationView = {
        let loadingAnimation = LOTAnimationView(name: "loading-pantau")
        loadingAnimation.translatesAutoresizingMaskIntoConstraints = false
        loadingAnimation.loopAnimation = true
        loadingAnimation.contentMode = .center
        
        return loadingAnimation
    }()
    
    var viewModel: CreateAskViewModel!
    lazy var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(loadingAnimation)
        loadingAnimation.isHidden = true
        configureConstraint()
        
        title = "Buat Pertanyaan"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        let done = UIBarButtonItem(image: #imageLiteral(resourceName: "icDoneRed"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem = done
        navigationController?.navigationBar.configure(with: .white)
        tvQuestion.delegate = self
        tvQuestion.text = "Tulis pertanyaan terbaikmu di sini!"
        tvQuestion.textColor = UIColor.lightGray
        // MARK
        // bind View Model
        back.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
        
        done.rx.tap
            .filter({ [unowned self](_) -> Bool in
                return !self.tvQuestion.text.isEmpty
            })
            .do(onNext: { [unowned self](_) in
                self.loadingAnimation.isHidden = false
                self.loadingAnimation.play()
            })
            .bind(to: viewModel.input.createTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.createSelected
            .drive()
            .disposed(by: disposeBag)
        
        let a = viewModel.output.userData
        a.drive (onNext: { [weak self]user in
            guard let weakSelf = self else { return }
            // TODO: set avatar when user have avatar property
            if let thumbnail = user?.user.avatar.thumbnail.url {
                self?.ivAvatar.af_setImage(withURL: URL(string: thumbnail)!)
            }
            weakSelf.lbFullname.text = (user?.user.fullName ?? "")
        })
        .disposed(by: disposeBag)
        
        tvQuestion.rx.text
            .orEmpty
            .map { "\($0.count)/260" }
            .asDriverOnErrorJustComplete()
            .drive(lbQuestionLimit.rx.text)
            .disposed(by: disposeBag)
        
        let value = BehaviorRelay<String>(value: "")
        
        tvQuestion.rx.text
            .orEmpty
            .bind(to: viewModel.input.questionInput)
            .disposed(by: disposeBag)
        
        
        value
            .asObservable()
            .subscribe { text in
                print("this is the text \(text)")
            }
            .disposed(by: disposeBag)
    }
    
    private func configureConstraint() {
        NSLayoutConstraint.activate([
            // MARK: consraint loadingAnimation
            loadingAnimation.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            loadingAnimation.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loadingAnimation.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            loadingAnimation.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
            ])
    }

}

extension CreateAskController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 261
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = Color.primary_black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tulis pertanyaan terbaikmu di sini!"
            textView.textColor = UIColor.lightGray
        }
    }
}
