//
//  LinimasaAPI.swift
//  Networking
//
//  Created by wisnu bhakti on 27/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Moya
import Common

public enum LinimasaAPI {
    case getBannerInfos
    case getFeeds(page: Int, perPage: Int)
    case getJanjiPolitiks(page: Int, perPage: Int)
    case deleteJanjiPolitiks(id: String)
    case createJanjiPolitiks(title: String, body: String, image: UIImage?)
    case editJanjiPolitiks(title: String, image: UIImage?)
}

extension LinimasaAPI: TargetType {
    
    public var headers: [String : String]? {
        return [
            "Content-Type"  : "application/json",
            "Accept"        : "application/json",
        ]
    }
    
    public var baseURL: URL {
        return URL(string: "https://staging-pemilu.pantaubersama.com/linimasa" )!
    }
    
    public var path: String {
        switch self {
        case .getBannerInfos:
            return "/v1/banner_infos"
        case .getFeeds:
            return "/v1/feeds/pilpres"
        case .getJanjiPolitiks:
            return "/v1/janji_politiks"
        case .deleteJanjiPolitiks,
             .createJanjiPolitiks,
             .editJanjiPolitiks:
            return "/v1/janji_politiks"
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .getFeeds(let (page, perPage)):
            return [
                "page": page,
                "per_page": perPage
            ]
        case .getJanjiPolitiks(let (page, perPage)):
            return [
                "page": page,
                "per_page": perPage
            ]
        case .deleteJanjiPolitiks(let id):
            return [
                "id": id
            ]
        default:
            return nil
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getBannerInfos,
             .getFeeds,
             .getJanjiPolitiks:
            return .get
        case .deleteJanjiPolitiks:
            return .delete
        case .createJanjiPolitiks:
            return .post
        case .editJanjiPolitiks:
            return .put
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        
        switch self.method {
        case .post, .put:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    public var task: Task {
        switch self {
        case .createJanjiPolitiks,
             .editJanjiPolitiks:
            return .uploadMultipart(self.multipartBody ?? [])
        default:
            return .requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding)
        }
    }
    
    public var validate: Bool {
        switch self {
        default:
            return false
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var multipartBody: [MultipartFormData]? {
        switch self {
        
        case .createJanjiPolitiks(let (title, body, image)):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "title", value: title))
            multipartFormData.append(buildMultipartFormData(key: "body", value: body))
            if let image = image?.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(buildMultipartFormData(name: "image", value: image))
            }
            return multipartFormData
        case .editJanjiPolitiks(let (title, image)):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "title", value: title))
            if let image = image?.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(buildMultipartFormData(name: "image", value: image))
            }
            return multipartFormData
        default:
            return nil
        }
    }

}

extension LinimasaAPI {
    private func buildMultipartFormData(key: String, value: String) -> MultipartFormData {
        return MultipartFormData(provider: .data(value.data(using: String.Encoding.utf8, allowLossyConversion: true)!), name: key)
    }
    
    private func buildMultipartFormData(name: String? = nil, value: Data) -> MultipartFormData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyyHHmmss"
        return MultipartFormData(provider: .data(value), name: name ?? "image[]", fileName: "pantau-ios-\(dateFormatter.string(from: Date())).jpg", mimeType:"image/jpeg")
    }
}