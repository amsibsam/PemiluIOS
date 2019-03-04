//
//  GetChallengeResponse.swift
//  Networking
//
//  Created by wisnu bhakti on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct GetChallengeResponse: Codable {
    
    public let challenges: [Challenge]
    
}

public enum ProgressType {
    case liveNow
    case challenge
    case comingSoon
    case done
    
    public var text: String {
        switch self {
        case .liveNow:
            return "live_now"
        case .challenge:
            return "challenge"
        case .comingSoon:
            return "coming_soon"
        case .done:
            return "done"
        }
    }
}
