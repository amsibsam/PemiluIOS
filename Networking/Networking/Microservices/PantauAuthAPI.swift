//
//  PantauAuthAPI.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//



// MARK:
// Function Pantau Authorizations
// TODO:- Get access token from Pantau

import Moya
import Common

public enum PantauAuthAPI {
    case callback(code: String, provider: String)
    
    public enum UserListFilter: String {
        case userVerifiedAll = "verified_all"
        case userVerifiedTrue = "verified_true"
        case userVerifiedFalse = "verified_false"
    }
    
    public enum GrantType: String {
        case refreshToken = "refresh_token"
    }
    
    case refresh(type: GrantType)
    case revoke
    case me
    case verifications
    case putKTP(ktp: String)
    case putSelfieKTP(image: UIImage?)
    case putFotoKTP(image: UIImage?)
    case putSignature(image: UIImage?)
    case badges(page: Int, perPage: Int)
    case meInformant
    case meAvatar(avatar: UIImage?)
    case putMe(parameters: [String: Any])
    case putInformants(parameters: [String: Any])
    case achievedBadges(id: String)
    case clusters(q: String, page: Int, perPage: Int, filterValue: String)
    case categories(q: String, page: Int, perPage: Int)
    case createCategories(t: String)
    case createCluster(name: String, id: String, desc: String, image: UIImage?)
    case votePreference(vote: Int, party: String)
    case deleteCluster
    case clusterMagicLink(id: String, enable: Bool)
    case clusterInvite(emails: String)
    case accountsConnect(type: String, oauthToken: String, oauthSecret: String)
    case accountDisconnect(type: String)
    case users(page: Int, perPage: Int, query: String, filterBy: UserListFilter)
    case firebaseKeys(deviceToken: String, type: String)
    case politicalParties(page: Int, perPage: Int)
    case getUserSimple(id: String)
    case getUserBadges(id: String, page: Int, perPage: Int)
}

extension PantauAuthAPI: TargetType {
    
    public var headers: [String: String]? {
        let token = KeychainService.load(type: NetworkKeychainKind.token) ?? ""
        return [
            "Content-Type"  : "application/json",
            "Accept"        : "application/json",
            "Authorization" : token
        ]
    }
    
    public static var isLoggedIn: Bool {
        let token = KeychainService.load(type: NetworkKeychainKind.token) ?? ""
        
        return !token.isEmpty
    }
    
    public var baseURL: URL {
        return URL(string: AppContext.instance.infoForKey("URL_API_AUTH"))!
    }
    
    public var path: String {
        switch self {
        case .callback:
            return "/v1/callback"
        case .refresh:
            return "/oauth/token"
        case .revoke:
            return "/ouath/revoke"
        case .me, .putMe:
            return "/v1/me"
        case .verifications:
            return "/v1/me/verifications"
        case .putKTP:
            return "/v1/verifications/ktp_number"
        case .putSelfieKTP:
            return "/v1/verifications/ktp_selfie"
        case .putFotoKTP:
            return "/v1/verifications/ktp_photo"
        case .putSignature:
            return "/v1/verifications/signature"
        case .badges:
            return "/v1/badges"
        case .meInformant:
            return "/v1/me/informants"
        case .meAvatar:
            return "/v1/me/avatar"
        case .putInformants:
            return "/v1/informants"
        case .achievedBadges(let id):
            return "/v1/achieved_badges/\(id)"
        case .clusters,
             .createCluster:
            return "/v1/clusters"
        case .categories,
             .createCategories:
            return "/v1/categories"
        case .votePreference:
            return "/v1/me/vote_preference"
        case .deleteCluster:
            return "/v1/me/clusters"
        case .clusterMagicLink(let (id, _)):
            return "/v1/clusters/\(id)/magic_link"
        case .clusterInvite:
            return "/v1/clusters/invite"
        case .accountsConnect:
            return "/v1/accounts/connect"
        case .accountDisconnect:
            return "/v1/accounts/disconnect"
        case .users:
            return "/v1/users"
        case .firebaseKeys:
            return "/v1/me/firebase_keys"
        case .politicalParties:
            return "/v1/political_parties"
        case .getUserSimple(let id):
            return "/v1/users/\(id)/simple"
        case .getUserBadges(let (id,_,_)):
            return "/v1/badges/user/\(id)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .refresh,
             .revoke,
             .createCategories,
             .createCluster,
             .clusterMagicLink,
             .clusterInvite,
             .accountsConnect:
            return .post
        case .putKTP,
             .putSelfieKTP,
             .putFotoKTP,
             .putSignature,
             .meAvatar,
             .putMe,
             .putInformants,
             .votePreference,
             .firebaseKeys:
            return .put
        case .deleteCluster,
             .accountDisconnect:
            return .delete
        default:
            return .get
        }
    }

    public var parameters: [String: Any]? {
        switch self {
        case .callback(let (_, provider)):
            return [
                "provider_token": provider
            ]
        case .refresh(let type):
            let t = KeychainService.load(type: NetworkKeychainKind.refreshToken) ?? ""
            return [
                "grant_type": type.rawValue,
                "client_id": AppContext.instance.infoForKey("CLIENT_ID_AUTH"),
                "client_secret": AppContext.instance.infoForKey("CLIENT_SECRET_AUTH"),
                "refresh_token": t
            ]
        case .revoke:
            let t = KeychainService.load(type: NetworkKeychainKind.token) ?? ""
            return [
                "client_id": AppContext.instance.infoForKey("CLIENT_ID_AUTH"),
                "client_secret": AppContext.instance.infoForKey("CLIENT_SECRET_AUTH"),
                "token": t
            ]
        case .badges(let (page, perPage)):
            return [
                "page": page,
                "per_page": perPage
            ]
        case .putMe(let parameters):
            return parameters
        case .putInformants(let parameters):
            return parameters
        case .clusters(let (q, page, perPage, filterValue)):
            return [
                "q": q,
                "page": page,
                "per_page": perPage,
                "filter_by": "category_id",
                "filter_value": filterValue
            ]
        case .categories(let (q, page, perPage)):
            return [
                "name": q,
                "page": page,
                "per_page": perPage
            ]
        case .createCategories(let t):
            return [
                "name": t
            ]
        case .accountDisconnect(let type):
            return [
                "account_type": type
            ]
        case .users(let page, let perPage, let query, let filterBy):
            return [
                "page": page,
                "per_page": perPage,
                "q": query,
                "filter_by": filterBy.rawValue
            ]
        case .getUserBadges(let (_, page, perPage)):
            return [
                "page": page,
                "per_page": perPage
            ]
        default:
            return nil
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        switch self.method {
        case .put, .post:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    public var task: Task {
        switch self {
        case .putKTP,
             .putSelfieKTP,
             .putFotoKTP,
             .putSignature,
             .meAvatar,
             .createCluster,
             .votePreference,
             .clusterMagicLink,
             .clusterInvite,
             .accountsConnect,
             .firebaseKeys:
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
        case .putKTP(let ktp):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "ktp_number", value: ktp))
            return multipartFormData
        case .putSelfieKTP(let image):
            var multipartFormData = [MultipartFormData]()
            if let selfie = image, let d = selfie.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(buildMultipartFormData(name: "ktp_selfie", value: d))
                }
            return multipartFormData
        case .putFotoKTP(let image):
            var multipartFormData = [MultipartFormData]()
            if let selfie = image, let d = selfie.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(buildMultipartFormData(name: "ktp_photo", value: d))
            }
            return multipartFormData
        case .putSignature(let image):
            var multipartFormData = [MultipartFormData]()
            if let selfie = image, let d = selfie.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(buildMultipartFormData(name: "signature", value: d))
            }
            return multipartFormData
        case .meAvatar(let image):
            var multipartFormData = [MultipartFormData]()
            if let avatar = image, let d = avatar.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(buildMultipartFormData(name: "avatar", value: d))
            }
            return multipartFormData
        case .createCluster(let (name, id, desc, image)):
            var multipartFormData = [MultipartFormData]()
            if let avatar = image, let d = avatar.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(buildMultipartFormData(name: "image", value: d))
            }
            multipartFormData.append(buildMultipartFormData(key: "name", value: name))
            multipartFormData.append(buildMultipartFormData(key: "category_id", value: id))
            multipartFormData.append(buildMultipartFormData(key: "description", value: desc))
            return multipartFormData
        case .votePreference(let (vote, party)):
            var multipartFormData = [MultipartFormData]()
            if vote == 0 {
                multipartFormData.append(buildMultipartFormData(key: "political_party_id", value: party))
            } else if party == "" {
                multipartFormData.append(buildMultipartFormData(key: "vote_preference", value: "\(vote)"))
            } else {
                multipartFormData.append(buildMultipartFormData(key: "vote_preference", value: "\(vote)"))
                multipartFormData.append(buildMultipartFormData(key: "political_party_id", value: party))
            }
            return multipartFormData
        case .clusterMagicLink(let (_, enable)):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "enable", value: "\(enable)"))
            return multipartFormData
        case .clusterInvite(let emails):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "emails", value: emails))
            return multipartFormData
        case .accountsConnect(let (type, token, secret)):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "account_type", value: type))
            multipartFormData.append(buildMultipartFormData(key: "oauth_access_token", value: token))
            multipartFormData.append(buildMultipartFormData(key: "oauth_access_token_secret", value: secret))
            return multipartFormData
        case .firebaseKeys(let (token, type)):
            var multipartFormData = [MultipartFormData]()
            multipartFormData.append(buildMultipartFormData(key: "firebase_key", value: token))
            multipartFormData.append(buildMultipartFormData(key: "firebase_key_type", value: type))
            return multipartFormData
        default:
            return nil
        }
    }
}


extension PantauAuthAPI {
    
    private func buildMultipartFormData(key: String, value: String) -> MultipartFormData {
        return MultipartFormData(provider: .data(value.data(using: String.Encoding.utf8, allowLossyConversion: true)!), name: key)
    }
    
    private func buildMultipartFormData(name: String? = nil, value: Data) -> MultipartFormData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyyHHmmss"
        return MultipartFormData(provider: .data(value), name: name ?? "image[]", fileName: "pantau-ios-\(dateFormatter.string(from: Date())).jpg", mimeType:"image/jpeg")
    }
}
