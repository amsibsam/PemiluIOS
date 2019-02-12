//
//  BannerInfo.swift
//  Networking
//
//  Created by wisnu bhakti on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct BannerInfo: Codable {
    
    public let id: String
    public var pageName: BannerPage
    public var title: String
    public var body: String
    public var headerImage: Image
    public var image: Image
    
    enum CodingKeys: String, CodingKey {
        case id, title, body, image
        case pageName = "page_name"
        case headerImage = "header_image"
    }
    
}

public struct BannerInfoResponse: Codable {
    
    public var bannerInfo: BannerInfo
    
    private enum CodingKeys: String, CodingKey {
        case bannerInfo = "banner_info"
    }
    
}

public enum BannerPage: String, Codable {
    case pilpres = "pilpres"
    case janji_politik = "janji politik"
    case tanya = "tanya"
    case kuis = "kuis"
    case debat = "debat"
    case unknown
    
    public var title: String? {
        switch self {
        case .pilpres:
            return "Pilpres"
        case .janji_politik:
            return "Janji Politik"
        case .tanya:
            return "Tanya"
        case .kuis:
            return "Kuis"
        case .debat:
            return "Debat"
        default:
            return nil
        }
    }
    
    public static func type(title: String?) -> BannerPage {
        guard let title = title else { return .unknown }
        switch title {
        case "Pilpres":
            return .pilpres
        case "Janji Politik":
            return .janji_politik
        case "Tanya":
            return .tanya
        case "Kuis":
            return .kuis
        case "Debat":
            return .debat
        default:
            return .unknown
        }
    }
}
