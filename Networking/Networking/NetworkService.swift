//
//  NetworkService.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Moya
import RxSwift
import Common

public struct NetworkService {
    
    public static let instance = NetworkService()
    fileprivate let provider: MoyaProvider<MultiTarget>
    
    private init() {
        self.provider = MoyaProvider<MultiTarget>(
            plugins: [
                RequestLoadingPlugin()
            ]
        )
    }
    
}

public extension NetworkService {
    
    public func requestObject<T: TargetType, C: Decodable>(_ t: T, c: C.Type) -> Single<C> {
        return provider.rx.request(MultiTarget(t))
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(c.self)
            .catchError({ (error)  in
                guard let errorResponse = error as? MoyaError else { return Single.error(NetworkError.IncorrectDataReturned) }
                switch errorResponse {
                case .underlying(let (e, _)):
                    print(e.localizedDescription)
                    return Single.error(NetworkError(error: e as NSError))
//                case .statusCode(let response):
//                    print(response.statusCode)
//                    if response.statusCode == 401 {
//                        let urlString = "\(AppContext.instance.infoForKey("DOMAIN_SYMBOLIC"))?client_id=\(AppContext.instance.infoForKey("CLIENT_ID"))&response_type=code&redirect_uri=\(AppContext.instance.infoForKey("REDIRECT_URI"))&scope=public+email"
//                        UIApplication.shared.open(URL(fileURLWithPath: urlString), options: [:], completionHandler: nil)
//                    }
                default:
                    let body = try
                        errorResponse.response?.map(ErrorResponse.self)
                    if let body = body {
                        print(body.error.errors)
                        return Single.error(NetworkError.SoftError(message: body.error.errors.first))
                    } else {
                        return Single.error(NetworkError.IncorrectDataReturned)
                    }
                }
//                return Single.error(NetworkError.Unknown)
            })
    }    
}
