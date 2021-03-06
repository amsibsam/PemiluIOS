//
//  CreateChallengeResponse.swift
//  Networking
//
//  Created by Hanif Sugiyanto on 23/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

public struct CreateChallengeResponse: Codable {
    
    public let challenge: Challenge
    
}

public struct Challenge: Codable {
    public let id: String
    public let type: ChallengeType
    public let source: String?
    public let statement: String?
    public let showTimeAt: String?
    public let timeLimit: Int?
    public let progress: ChallengeProgress
    public let condition: ChallengeCondition
    public let topic: [String]?
    public let createdAt: String?
    public let audiences: [Audiences]
    public let reason: String?
    public let clapCount: Int
    public var likeCount: Int?
    public var isLiked: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case id, type, statement, progress, condition, audiences
        case source = "statement_source"
        case showTimeAt = "show_time_at"
        case timeLimit = "time_limit"
        case topic = "topic_list"
        case createdAt = "created_at"
        case reason = "reason_rejected"
        case clapCount = "clap_count"
        case likeCount = "like_count"
        case isLiked = "is_liked"
    }
    
}

public struct Audiences: Codable {
    public let id: String
    public let role: AudienceRole
    public let userId: String?
    public let email: String?
    public let fullName: String?
    public let username: String?
    public let avatar: Avatar?
    public let about: String?
    public let clapCount: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id, role, email, avatar, about, username
        case userId = "user_id"
        case fullName = "full_name"
        case clapCount = "clap_count"
    }
}

public enum AudienceRole: String, Codable {
    case challenger = "challenger"
    case opponentCandidate = "opponent_candidate"
    case audience = "audience"
    case opponent = "opponent"
}
