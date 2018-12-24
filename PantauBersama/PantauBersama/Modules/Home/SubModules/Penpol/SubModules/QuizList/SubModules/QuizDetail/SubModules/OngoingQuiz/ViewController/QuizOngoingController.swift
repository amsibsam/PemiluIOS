//
//  QuizOngoingController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxCocoa
import RxSwift

class QuizOngoingController: UIViewController {
    @IBOutlet weak var btnAChoice: Button!
    @IBOutlet weak var btnBChoice: Button!
    @IBOutlet weak var tvBChoice: UITextView!
    @IBOutlet weak var tvAChoice: UITextView!
    @IBOutlet weak var lbQuestion: Label!
    @IBOutlet weak var ivQuiz: UIImageView!
    
    private(set) var disposeBag = DisposeBag()
    var viewModel: QuizOngoingViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAChoice.rx
            .tap
            .bind(to: viewModel.input.answerATrigger)
            .disposed(by: disposeBag)
        
        btnBChoice.rx
            .tap
            .bind(to: viewModel.input.answerBTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.answerA
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.answerB
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.back
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.question
            .drive(onNext: { [unowned self]questions in
                self.tvAChoice.text = questions[0]
                self.tvBChoice.text = questions[1]
            }).disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let quizIndex = UIBarButtonItem(title: "Pertanyaan no 10 dari 10", style: .plain, target: self, action: nil)
        quizIndex.tintColor = .white
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = back
        self.navigationItem.rightBarButtonItem = quizIndex
        self.navigationController?.navigationBar.configure(with: .transparent)
        
        back.rx.tap
            .bind(to: viewModel.input.backTrigger).disposed(by: disposeBag)
    }
}
