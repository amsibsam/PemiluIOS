//
//  ArgumentRightCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Lottie
import Networking

class ArgumentRightCell: UITableViewCell {
    @IBOutlet weak var lbArgument: Label!
    @IBOutlet weak var lbCreatedAt: Label!
    @IBOutlet weak var lbReadEstimation: Label!
    @IBOutlet weak var viewClapLottie: UIView!
    @IBOutlet weak var btnClap: ImageButton!
    @IBOutlet weak var lbClapCount: Label!
    @IBOutlet weak var lbClapStatus: Label!
    
    lazy private var clapAnimation: LOTAnimationView = {
        let clapAnimation = LOTAnimationView(name: "clap")
        clapAnimation.translatesAutoresizingMaskIntoConstraints = false
        clapAnimation.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        clapAnimation.contentMode = .center
        clapAnimation.frame = viewClapLottie.bounds
        clapAnimation.loopAnimation = false
        
        return clapAnimation
    }()
    
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewClapLottie.addSubview(clapAnimation)
        configureConstraint()
        
        btnClap.rx.tap
            .bind{ [unowned self] in
                self.clapAnimation.play()
            }
            .disposed(by: disposeBag)
    }
    
    private func configureConstraint() {
        NSLayoutConstraint.activate([
            clapAnimation.trailingAnchor.constraint(equalTo: viewClapLottie.trailingAnchor),
            clapAnimation.topAnchor.constraint(equalTo: viewClapLottie.topAnchor),
            clapAnimation.leadingAnchor.constraint(equalTo: viewClapLottie.leadingAnchor),
            clapAnimation.bottomAnchor.constraint(equalTo: viewClapLottie.bottomAnchor)
            ])
    }
    
}

extension ArgumentRightCell: IReusableCell {
    struct Input {
        let word: Word
        let viewModel: LiveDebatViewModel
    }
    
    func configureCell(item: Input) {
        lbArgument.text = item.word.body
        lbReadEstimation.text = "\(item.word.readTime ?? 0) menit"
        lbCreatedAt.text = item.word.createdAt.timeAgoSinceDateForm2
    }
}
