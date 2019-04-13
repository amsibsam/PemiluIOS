//
//  DetailTPSDPRViewModel.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

struct SectionTotalValue {
    var section: Int
    var totalValue: Int
}

class DetailTPSDPRViewModel: ViewModelType {
    
    struct Input {
        let backI: AnyObserver<Void>
        let refreshI: AnyObserver<String>
        let counterI: AnyObserver<CandidatePartyCount>
        let invalidCountI: AnyObserver<Int>
        let counterPartyI: AnyObserver<PartyCount>
        let viewWillAppearI: AnyObserver<Void>
        let bufferPartyI: AnyObserver<PartyCount>
        let simpanI: AnyObserver<Void>
        let suarahSahI: AnyObserver<Int>
        let footerCountI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
        let nameDapilO: Driver<String>
        let errorO: Driver<Error>
        let invalidO: Driver<Int>
        let initialValueO: Driver<Void>
        let itemsSections: Driver<[SectionModelCalculations]>
        let bufferPartyO: Driver<PartyCount>
        let simpanO: Driver<Void>
        let totalSuaraSahO: Driver<Int>
        let totalSuaraO: Driver<Int>
    }
    
    var input: Input
    var output: Output!
    
    private let navigator: DetailTPSDPRNavigator
    private let realCount: RealCount
    private let type: TingkatPemilihan
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    private let backS = PublishSubject<Void>()
    private let detailTPSS = PublishSubject<Void>()
    private let refreshS = PublishSubject<String>()
    private let counterS = PublishSubject<CandidatePartyCount>()
    private let invalidCountS = PublishSubject<Int>()
    private let counterPartyS = PublishSubject<PartyCount>()
    private let viewWillAppearS = PublishSubject<Void>()
    private let bufferPartyS = PublishSubject<PartyCount>()
    private let simpanS = PublishSubject<Void>()
    private let suarahSahS = PublishSubject<Int>()
    private let footerCountS = PublishSubject<Void>()
    
    private let itemRelay = BehaviorRelay<[SectionModelCalculations]>(value: [])
    
    private var candidatesPartyValue = BehaviorRelay<[CandidatePartyCount]>(value: [])
    private let partyValue = BehaviorRelay<[PartyCount]>(value: [])
    
    private var bufferItemActor = BehaviorRelay<[ItemActor]>(value: [])
    private var bufferPartyActor = BehaviorRelay<[ItemActor]>(value: [])
    private var bufferFooterCount = BehaviorRelay<[Int]>(value: [])
    
    private(set) var disposeBag = DisposeBag()
    
    init(navigator: DetailTPSDPRNavigator, realCount: RealCount, type: TingkatPemilihan) {
        self.navigator = navigator
        self.realCount = realCount
        self.type = type
        
        input = Input(backI: backS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      counterI: counterS.asObserver(),
                      invalidCountI: invalidCountS.asObserver(),
                      counterPartyI: counterPartyS.asObserver(),
                      viewWillAppearI: viewWillAppearS.asObserver(),
                      bufferPartyI: bufferPartyS.asObserver(),
                      simpanI: simpanS.asObserver(),
                      suarahSahI: suarahSahS.asObserver(),
                      footerCountI: footerCountS.asObserver())
        
        
        /// MARK
        /// GET Name Dapil
        let nameDapil = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<String> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI.getDapils(provinceCode: self.realCount.provinceCode,
                                                       regenciCode: self.realCount.regencyCode,
                                                       districtCode: self.realCount.districtCode,
                                                       tingkat: self.type),
                                   c: BaseResponse<DapilRegionResponse>.self)
                    .map({ $0.data.nama })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
            }.asDriverOnErrorJustComplete()
        
        /// MARK
        /// GET Data based Dapils to GET Candidates
        /// Then transform to SectionModelsCalculations
        let itemsSection = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<[CandidateResponse]> in
                guard let `self` = self else { return Observable.empty() }
                return self.getDapils(tingkat: self.type)
            }
            .flatMapLatest { [weak self] (response) -> Observable<[SectionModelCalculations]> in
                guard let `self` = self else { return Observable.empty() }
                return self.transformToSectionsCalculations(response: response)
            }
//            .flatMapLatest { [weak self] (sectioned) -> Observable<[SectionModelCalculations]> in
//                guard let `self` = self else { return Observable.empty() }
////                var footerSection: [Int] = []
////                for sections in sectioned {
////                    let sumCandidatesItem = sections.items.map({ $0.value }).reduce(0, +)
////                    print("SUM TOTAL EACH SECTION: \(sumCandidatesItem)")
////                    footerSection.append(sumCandidatesItem)
////                }
//                var latestSectioned = sectioned
//                let sum = latestSectioned.map({ $0.items.map({ $0.value}).reduce(0, +)})
//                var footer = latestSectioned.map({ $0.footerCount })
//                footer = sum
//                latestSectioned.map({ $0.footerCount }) = footer
////                self.bufferFooterCount.accept(footerSection)
//                return Observable.just(latestSectioned)
//        }
        
        
        /// MARK
        /// TODO: Update ITEMS based on counter button
        let itemsUpdate = counterS
            .flatMapLatest { [weak self] (candidateCount) -> Observable<[SectionModelCalculations]> in
                guard let `self` = self else { return Observable.empty() }
                
                /// TODO
                /// Latest candidates use fo sum each row and append into sections models
                var latestCandidates = self.candidatesPartyValue.value
                /// filter if id is match, remove and append with latest values
                if latestCandidates.contains(where: { $0.id == candidateCount.id }) {
                    guard let index = latestCandidates.index(where: { current -> Bool in
                        return current.id == candidateCount.id
                    }) else { return Observable.empty() }
                    latestCandidates.remove(at: index)
                    latestCandidates.append(candidateCount)
                } else {
                    latestCandidates.append(candidateCount)
                }
                self.candidatesPartyValue.accept(latestCandidates)
                
                
                /// TODO
                /// Match latest value for section tableview, this func will keep cell [Items]
                /// based on his values
                var latestItems = self.itemRelay.value
                /// then match candidates with sections models
                var currentCandidates = latestItems[candidateCount.indexPath.section]
                /// find index of sections
                guard let index = currentCandidates.items.index(where: { current -> Bool in
                    return current.id == candidateCount.id
                }) else { return Observable.empty() }
                /// updated candidates
                var updateCandidate = currentCandidates.items.filter{ (candidate) -> Bool in
                    return candidate.id == candidateCount.id
                }.first
                
                if updateCandidate != nil {
                    /// assign updated candidates value
                    updateCandidate?.value = candidateCount.totalVote
                    currentCandidates.items[index] = updateCandidate!
                    // after assign row and section, then keep into Relay Sections Models
                    let currentPartyHeader = latestItems[candidateCount.indexPath.section].headerCount
                    var totalValueCandidates = currentCandidates.items.map({ $0.value }).reduce(0, +)
                    totalValueCandidates += currentPartyHeader
                    /// assign footer value with header count and each row value
                    currentCandidates.footerCount = totalValueCandidates
                    latestItems[candidateCount.indexPath.section] = currentCandidates
                    self.itemRelay.accept(latestItems)
                }
                return Observable.just(latestItems)
        }
        
        
        /// MARK
        /// Update Header counter
        let headerUpdates = counterPartyS
            .flatMapLatest { [weak self] (partyCount) -> Observable<[SectionModelCalculations]> in
                guard let `self` = self else { return Observable.empty() }
                
                /// TODO
                /// assign each value for Party Count
                var latestPartyCount = self.partyValue.value
                if latestPartyCount.contains(where: { $0.number == partyCount.number }) {
                    guard let index = latestPartyCount.index(where: { current -> Bool in
                        return current.number == partyCount.number
                    }) else { return Observable.empty() }
                    latestPartyCount.remove(at: index)
                    latestPartyCount.append(partyCount)
                } else {
                    latestPartyCount.append(partyCount)
                }
                self.partyValue.accept(latestPartyCount)
                
                
                /// Match with latest items sections
                var latestItems = self.itemRelay.value
                /// Match with current sections
                var currentParty = latestItems[partyCount.section]
                currentParty.headerCount = partyCount.value
                /// Calculate footer with all sum in row
                let latestCandidate = latestItems[partyCount.section].items
                var totalValueFooter = latestCandidate.map({ $0.value }).reduce(0, +)
                totalValueFooter += partyCount.value
                /// Assign value footer
                currentParty.footerCount = totalValueFooter

                /// Assign latest values with current party
                latestItems[partyCount.section] = currentParty
                latestItems[partyCount.section].items = latestItems[partyCount.section].items
                
                self.itemRelay.accept(latestItems)
                return Observable.just(latestItems)
        }
        
        /// TODO
        /// Get data realcount calculations saved
        /**
         initial value will triggered whenever view is appear
         - returns: candidates array and parties array, each
         candidates represent as Item Actor: have id, and total value
         we must store this id and value and match will some array of data in SectionModelDPR items
         **/
        let initialValue = viewWillAppearS
            .flatMapLatest { [weak self] (_) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI.getCalculations(hitungRealCountId: self.realCount.id,
                                                             tingkat: self.type),
                                   c: BaseResponse<RealCountResponse>.self)
                    .map({ $0.data })
                    .do(onSuccess: { (response) in
                        print("Response candidates: \(response.calculation.candidates ?? [])")
                        self.bufferItemActor.accept(response.calculation.candidates ?? [])
                        self.bufferPartyActor.accept(response.calculation.parties ?? [])
                        let lastValueCandidate = response.calculation.candidates?.map({ $0.totalVote ?? 0 }).reduce(0, +)
                        let lastValueParty = response.calculation.parties?.map({ $0.totalVote ?? 0 }).reduce(0, +)
                    })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
                    .mapToVoid()
            }.asDriverOnErrorJustComplete()
        
        /// TODO
        /// updates section with latest footer counts
        let initial = footerCountS
            .flatMapLatest { [weak self] (_) -> Observable<[SectionModelCalculations]> in
                guard let `self` = self else { return Observable.empty() }
                var latestItems = self.itemRelay.value
                var latestFooter = self.bufferFooterCount.value
                print("ALL SUM FOOTER: \(latestFooter)")
                
                
                return Observable.just(latestItems)
            }
        
        
        /// MARK
        /// Merge all Observable sections: It will contains 3 observable
        let mergeItems = Observable.merge(itemsSection, itemsUpdate, headerUpdates)
            .asDriverOnErrorJustComplete()
        
        let invalid = invalidCountS
        .asDriverOnErrorJustComplete()
        
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        
        /// MARK
        /// Handle All valid suara
        let totalSuaraSah = suarahSahS
            .asDriverOnErrorJustComplete()
        /// MARK
        /// Handle All Suara
        let totalSuara = Observable.combineLatest(suarahSahS.asObservable().startWith(0),
                                                  invalidCountS.asObservable().startWith(0))
            .flatMapLatest { (a,b) -> Observable<Int> in
                return Observable.just(a + b)
            }.asDriverOnErrorJustComplete()
        
        /// MARK
        /// Handle Save
        let simpan = simpanS
            .withLatestFrom(Observable.combineLatest(invalidCountS.asObservable().startWith(0),
                                                     self.candidatesPartyValue,
                                                     self.partyValue,
                                                     self.bufferItemActor,
                                                     self.bufferPartyActor))
            .flatMapLatest { [weak self] (invalid, candidates, party, initialData, initialParty) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                
                return NetworkService.instance
                    .requestObject(HitungAPI.putCalculationsCandidatesAndParty(id: self.realCount.id,
                                                                       type: self.type,
                                                                       invalidVote: invalid,
                                                                       candidates: candidates,
                                                                       parties: party,
                                                                       initialData: initialData, initialPartyData: initialParty),
                                   c: BaseResponse<RealCountResponse>.self)
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
                    .mapToVoid()
            }.asDriverOnErrorJustComplete()
    
        
        output = Output(backO: back,
                        nameDapilO: nameDapil,
                        errorO: errorTracker.asDriver(),
                        invalidO: invalid,
                        initialValueO: initialValue,
                        itemsSections: mergeItems,
                        bufferPartyO: bufferPartyS.asDriverOnErrorJustComplete(),
                        simpanO: simpan,
                        totalSuaraSahO: totalSuaraSah,
                        totalSuaraO: totalSuara)
    }
}


extension DetailTPSDPRViewModel {
    /// MARK: - Get Dapils Location
    private func getDapils(tingkat: TingkatPemilihan) -> Observable<[CandidateResponse]> {
        return NetworkService.instance
            .requestObject(HitungAPI.getDapils(provinceCode: self.realCount.provinceCode,
                                               regenciCode: self.realCount.regencyCode,
                                               districtCode: self.realCount.districtCode,
                                               tingkat: tingkat),
                           c: BaseResponse<DapilRegionResponse>.self)
            .map({ $0.data })
            .trackError(self.errorTracker)
            .trackActivity(self.activityIndicator)
            .flatMapLatest({ self.getCandidates(idDapils: $0.id, tingkat: tingkat) })
            .asObservable()
    }
    /// MARK: - Handle List All Candidates
    private func getCandidates(idDapils: Int, tingkat: TingkatPemilihan) -> Observable<[CandidateResponse]> {
        return NetworkService.instance
            .requestObject(HitungAPI.getCandidates(dapilId: idDapils, tingkat: tingkat),
                           c: BaseResponses<CandidateResponse>.self)
            .map({ $0.data })
            .trackError(self.errorTracker)
            .trackActivity(self.activityIndicator)
            .asObservable()
    }
    /// Mark: - Generate candidates Actor
    private func generateCandidates(data: CandidateResponse) -> [CandidateActor] {
        var candidate: [CandidateActor] = []

        for datas in data.candidates {
            let initialValue = self.bufferItemActor.value.filter({ $0.actorId == "\(datas.id)" }).first?.totalVote
            candidate.append(CandidateActor(id: datas.id,
                                            name: datas.name ?? "",
                                            value: initialValue ?? 0))
        }
        
        return candidate
    }
    
    
    /// MARK: - Transform response into SectionModelsCalculations
    private func transformToSectionsCalculations(response: [CandidateResponse]) -> Observable<[SectionModelCalculations]> {
        var items: [SectionModelCalculations] = []
        
        for item in response {
            let headerCount = self.bufferPartyActor.value.filter({ $0.actorId == "\(item.serialNumber)"}).first?.totalVote
            /// TODO: Calculate footer
            /// ...
            items.append(SectionModelCalculations(header: item.name,
                                                  headerCount: headerCount ?? 0,
                                                  headerNumber: item.serialNumber,
                                                  headerLogo: item.logo?.thumbnail.url ?? "",
                                                  items: self.generateCandidates(data: item),
                                                  footerCount: headerCount ?? 0))
        }
        
        self.itemRelay.accept(items)
        return Observable.just(items)
    }
    
    
}


func + (left: Int?, right: Int?) -> Int? {
    return left != nil ? right != nil ? left! + right! : left : right
}
