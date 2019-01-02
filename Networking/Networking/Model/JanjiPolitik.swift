//
//  JanjiPolitik.swift
//  Networking
//
//  Created by wisnu bhakti on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public struct JanjiPolitik: Codable {
    
    public let id: String
    public var title: String
    public var body: String
    public var image: Image?
    public var createdAt: String
    public var user: UserPantau
    
    enum CodingKeys: String, CodingKey {
        case id, title, body, image, user
        case createdAt = "created_at"
    }
    
}
