//
//  CreateAskViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class CreateAskViewModel: ViewModelType {
    var input: Input
    var output: Output!
    
    struct Input {
        let backTrigger: AnyObserver<Void>
        let createTrigger: AnyObserver<Void>
        let questionInput: AnyObserver<String>
        let refreshTrigger: AnyObserver<String>
        let nextTrigger: AnyObserver<Void>
        let itemSelectedTrigger: AnyObserver<IndexPath>
        let buttonRecentI: AnyObserver<QuestionModel>
    }
    
    struct Output {
        let createSelected: Driver<Void>
        let userData: Driver<UserResponse?>
        let loadingIndicator: Driver<Bool>
        let enableO: Driver<Bool>
        let itemsO: Driver<[QuestionModel]>
        let itemSelectedO: Driver<Void>
        let buttonRecentO: Driver<Void>
    }
    
    private let createSubject = PublishSubject<Void>()
    private let backSubject = PublishSubject<Void>()
    private let questionRelay = PublishSubject<String>()
    private let refreshSubject = PublishSubject<String>()
    private let nextSubject = PublishSubject<Void>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    private let buttonRecentS = PublishSubject<QuestionModel>()
    
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    private let disposeBag = DisposeBag()
    
    var navigator: CreateAskNavigator
    
    init(navigator: CreateAskNavigator) {
        self.navigator = navigator
        
        input = Input(backTrigger: backSubject.asObserver(),
                      createTrigger: createSubject.asObserver(),
                      questionInput: questionRelay.asObserver(),
                      refreshTrigger: refreshSubject.asObserver(),
                      nextTrigger: nextSubject.asObserver(),
                      itemSelectedTrigger: itemSelectedS.asObserver(),
                      buttonRecentI: buttonRecentS.asObserver())
        
        
        // MARK
        // Get Recent QuestionModel
        let items = questionRelay
            .flatMapLatest { (s) -> Observable<[QuestionModel]> in
                print("current string : \(s)")
                if s.count == 0 {
                    return Observable.empty()
                } else {
                    return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable(), query: s)
                        .trackError(self.errorTracker)
                        .trackActivity(self.activityIndicator)
                        .catchErrorJustReturn([])
                }
            }
        
        let itemSelected = itemSelectedS
            .withLatestFrom(items) { (indexPath, question)  in
                return question[indexPath.row]
            }.flatMapLatest { (model) -> Observable<DetailAskResult> in
                return navigator.launchDetailAsk(data: model.id)
            }.mapToVoid()
            .asDriverOnErrorJustComplete()
        

        let create = createSubject
            .withLatestFrom(questionRelay)
            .flatMapLatest({ [unowned self] (s) -> Observable<QuestionModel> in
                return self.createQuestion(body: s)
            })
            .mapToVoid()
            .trackActivity(activityIndicator)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
        
        self.navigator.back = backSubject
        
        self.navigator.createComplete = create.asObservable()

        
        // MARK
        // Get user data from userDefaults
        let userData: Data? = UserDefaults.Account.get(forKey: .me)
        let userResponse = try? JSONDecoder().decode(UserResponse.self, from: userData ?? Data())
        let user = Observable.just(userResponse).asDriverOnErrorJustComplete()
        
        let enable = questionRelay
            .map { (s) -> Bool in
                return s.count > 0 && !s.containsInsensitive("Tulis pertanyaan terbaikmu di sini!")
                    && s != " "
            }.startWith(false)
            .asDriverOnErrorJustComplete()
        
        let recentSelected = buttonRecentS
            .flatMapLatest { (model) -> Observable<DetailAskResult> in
                return navigator.launchDetailAsk(data: model.id)
        }.mapToVoid()
        .asDriverOnErrorJustComplete()

        output = Output(createSelected: create,
                        userData: user,
                        loadingIndicator: activityIndicator.asDriver(),
                        enableO: enable,
                        itemsO: items.asDriverOnErrorJustComplete(),
                        itemSelectedO: itemSelected,
                        buttonRecentO: recentSelected)
    }
    
    private func createQuestion(body: String) -> Observable<QuestionModel> {
        return NetworkService.instance
            .requestObject(TanyaKandidatAPI.createQuestion(body: body), c: QuestionResponse.self)
            .map({ (questionResponse) -> QuestionModel in
                return QuestionModel(question: questionResponse.data.question)
            })
            .asObservable()
            .catchErrorJustComplete()
    }
    
    func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>,
        query: String) ->
        Observable<Page<[QuestionModel]>> {
            return NetworkService.instance
                .requestObject(TanyaKandidatAPI.getQuestions(query: query, page: batch.page, perpage: batch.limit, filteredBy: "user_verified_all", orderedBy: ""), c: QuestionsResponse.self)
                .map({ self.transformToPage(response: $0, batch: batch) })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[QuestionModel]>> in
                    return self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, query: query)
                })
                .share(replay: 1, scope: .whileConnected)
    }
    
    private func transformToPage(response: QuestionsResponse, batch: Batch) -> Page<[QuestionModel]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[QuestionModel]>(
            item: generateQuestions(from: response),
            batch: nextBatch
        )
    }
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>, query: String) -> Observable<[QuestionModel]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger, query: query)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func generateQuestions(from questionResponse: QuestionsResponse) -> [QuestionModel] {
        return questionResponse.data.questions.map({ (questionResponse) -> QuestionModel in
            return QuestionModel(question: questionResponse)
        })
    }
    
}
