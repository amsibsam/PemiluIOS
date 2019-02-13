//
//  OpenChallengeViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking

class OpenChallengeViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let refreshI: AnyObserver<Void>
        let kajianI: AnyObserver<Bool>
        let pernyataanI: AnyObserver<Bool>
        let dateTimeI: AnyObserver<Bool>
        let saldoI: AnyObserver<Bool>
        let kajianButtonI: AnyObserver<Void>
        let hintKajianI: AnyObserver<Void>
        let statusKajian: BehaviorSubject<Bool>
        let pernyataanTextInput: BehaviorRelay<String>
        let hintPernyataanI: AnyObserver<Void>
        let statusPernyataan: AnyObserver<String>
    }
    
    struct Output {
        let itemsO: Driver<[SectionOfTantanganData]>
        let meO: Driver<User>
        let kajianSelected: Driver<BidangKajianResult>
        let hintKajianO: Driver<Void>
        let enablePernyataanO: Driver<Bool>
        let hintPernyataanO: Driver<Void>
        let statusPernyataanO: Driver<String>
    }
    
    private let backS = PublishSubject<Void>()
    private let refreshS = PublishSubject<Void>()
    private let kajianS = PublishSubject<Bool>()
    private let pernyataanS = PublishSubject<Bool>()
    private let dateTimeS = PublishSubject<Bool>()
    private let saldoS = PublishSubject<Bool>()
    private let kajianButtonS = PublishSubject<Void>()
    private let hintKajianS = PublishSubject<Void>()
    private let statusKajianS = BehaviorSubject<Bool>(value: false)
    private let pernyataanTextS = BehaviorRelay<String>(value: "")
    private let hintPernyataanS = PublishSubject<Void>()
    private let statusPernyataanS = PublishSubject<String>()
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    private var navigator: OpenChallengeNavigator
    
    init(navigator: OpenChallengeNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(backI: backS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      kajianI: kajianS.asObserver(),
                      pernyataanI: pernyataanS.asObserver(),
                      dateTimeI: dateTimeS.asObserver(),
                      saldoI: saldoS.asObserver(),
                      kajianButtonI: kajianButtonS.asObserver(),
                      hintKajianI: hintKajianS.asObserver(),
                      statusKajian: statusKajianS.asObserver(),
                      pernyataanTextInput: pernyataanTextS,
                      hintPernyataanI: hintPernyataanS.asObserver(),
                      statusPernyataan: statusPernyataanS.asObserver())
        
        
        let item = Observable.combineLatest(kajianS, pernyataanS, dateTimeS, saldoS)
            .flatMapLatest { (valueKajian, valuePernyataan, valueData, valueSaldo) -> Observable<[SectionOfTantanganData]> in
                return Observable.just([
                    SectionOfTantanganData(items: [TantanganData.bidangKajian], isHide: valueKajian, isActive: valueKajian),
                    SectionOfTantanganData(items: [TantanganData.pernyataan], isHide: valuePernyataan, isActive: valuePernyataan),
                    SectionOfTantanganData(items: [TantanganData.dateTime], isHide: valueData, isActive: valueData),
                    SectionOfTantanganData(items: [TantanganData.saldoTime], isHide: valueSaldo, isActive: valueSaldo),
                    ])
        }
        
        let items = item
            .map { (a) -> [SectionOfTantanganData] in
                return a.filter({ $0.isHide == false })
            }
            .asDriverOnErrorJustComplete()
        
        let me = refreshS
            .flatMapLatest { [unowned self] (_) -> Observable<User> in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI.me,
                                   c: BaseResponse<UserResponse>.self)
                    .map({ $0.data.user })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
                    .catchErrorJustComplete()
            }
        
        let kajian = kajianButtonS
            .flatMapLatest({ navigator.launchBidangKajian() })
            .asDriverOnErrorJustComplete()
        
        let hintKajian = hintKajianS
            .flatMapLatest({ navigator.launchHint(type: .kajian )})
            .asDriverOnErrorJustComplete()
        
        let hintPernyataan = hintPernyataanS
            .flatMapLatest({ navigator.launchHint(type: .pernyataan )})
            .asDriverOnErrorJustComplete()
        
        let enablePernyataan = pernyataanTextS
            .map { (s) -> Bool in
                return s.count > 0 && !s.containsInsensitive("Tulis pernyataanmu di sini...")
            }.startWith(false)
            .asDriverOnErrorJustComplete()
        
        output = Output(itemsO: items,
                        meO: me.asDriverOnErrorJustComplete(),
                        kajianSelected: kajian,
                        hintKajianO: hintKajian,
                        enablePernyataanO: enablePernyataan,
                        hintPernyataanO: hintPernyataan,
                        statusPernyataanO: statusPernyataanS.asDriverOnErrorJustComplete())
    }
    
}
