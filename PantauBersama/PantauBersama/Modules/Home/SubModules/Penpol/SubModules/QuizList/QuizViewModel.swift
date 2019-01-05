//
//  QuizViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class QuizViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let loadQuizTrigger: AnyObserver<Void>
        let nextPageTrigger: AnyObserver<Void>
        let openQuizTrigger: AnyObserver<Any>
        let shareTrigger: AnyObserver<Any>
        let infoTrigger: AnyObserver<Void>
        let shareTrendTrigger: AnyObserver<Any>
    }
    
    struct Output {
        let openQuizSelected: Driver<Void>
        let shareSelected: Driver<Void>
        let infoSelected: Driver<Void>
        let shareTrendSelected: Driver<Void>
        let laodingIndicator: Driver<Bool>
        let quizzes: BehaviorRelay<[QuizModel]>
    }
    
    // TODO: replace any with Quiz model
    private let loadQuizSubject = PublishSubject<Void>()
    private let nextPageSubject = PublishSubject<Void>()
    private let openQuizSubject = PublishSubject<Any>()
    private let shareSubject = PublishSubject<Any>()
    private let infoSubject = PublishSubject<Void>()
    private let shareTrendSubject = PublishSubject<Any>()
    private let quizRelay = BehaviorRelay<[QuizModel]>(value: [])
    
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    
    private let navigator: QuizNavigator
    private var currentPage = 0
    
    private let disposeBag = DisposeBag()
    
    init(navigator: PenpolNavigator) {
        self.navigator = navigator
        
        input = Input(
            loadQuizTrigger: loadQuizSubject.asObserver(),
            nextPageTrigger: nextPageSubject.asObserver(),
            openQuizTrigger: openQuizSubject.asObserver(),
            shareTrigger: shareSubject.asObserver(),
            infoTrigger: infoSubject.asObserver(),
            shareTrendTrigger: shareTrendSubject.asObserver())
        
        let openQuiz = openQuizSubject
            .flatMapLatest({navigator.openQuiz(quiz: $0)})
            .asDriver(onErrorJustReturn: ())
        let shareQuiz = shareSubject
            .flatMapLatest({navigator.shareQuiz(quiz: $0)})
            .asDriver(onErrorJustReturn: ())
        let info = infoSubject
            .flatMapLatest({navigator.openInfoPenpol(infoType: PenpolInfoType.Quiz)})
            .asDriver(onErrorJustReturn: ())
        let shareTrend = shareTrendSubject
            .flatMapLatest({navigator.shareTrend(trend: $0)})
            .asDriver(onErrorJustReturn: ())
        
        loadQuizSubject
            .flatMapLatest({ [weak self](_) -> Observable<[QuizModel]> in
                guard let weakSelf = self else { return Observable.empty() }
                return weakSelf.quizItems(resetPage: true)
                    .trackActivity(weakSelf.activityIndicator)
                    .trackError(weakSelf.errorTracker)
            })
            .filter({ !$0.isEmpty })
            .bind { [weak self](loadedItem) in
                guard let weakSelf = self else { return }
                weakSelf.quizRelay.accept(loadedItem)
            }
            .disposed(by: disposeBag)
        
        nextPageSubject
            .flatMapLatest({ [weak self](_) -> Observable<[QuizModel]> in
                guard let weakSelf = self else { return Observable.empty() }
                return weakSelf.quizItems()
            })
            .filter({ !$0.isEmpty })
            .bind { [weak self](loadedItem) in
                guard let weakSelf = self else { return }
                var newItem = weakSelf.quizRelay.value
                newItem.append(contentsOf: loadedItem)
                weakSelf.quizRelay.accept(newItem)
            }
            .disposed(by: disposeBag)
        
        output = Output(
            openQuizSelected: openQuiz,
            shareSelected: shareQuiz,
            infoSelected: info,
            shareTrendSelected: shareTrend,
            laodingIndicator: activityIndicator.asDriver(),
            quizzes: quizRelay)
    }
    
    private func quizItems(resetPage: Bool = false) -> Observable<[QuizModel]> {
        if resetPage {
            currentPage = 0
        }
        
        currentPage += 1
        return NetworkService.instance.requestObject(QuizAPI.getQuizzes(page: currentPage, perPage: 10, filterBy: .all), c: QuizzesResponse.self)
            .map { [weak self](response) -> [QuizModel] in
                guard let weakSelf = self else { return [] }
                return weakSelf.generateQuizzes(from: response)
            }
            .asObservable()
            .catchErrorJustReturn([])
    }
    
    private func generateQuizzes(from quizResponse: QuizzesResponse) -> [QuizModel] {
        return quizResponse.data.quizzes.map({ (quizResponse) -> QuizModel in
            return QuizModel(quiz: quizResponse)
        })
    }
    
}
