//
//  QuestionModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 27/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import Networking

public struct QuestionModel {
    let id, body: String
    let createdAt: CreatedAt
    let created: String
    let likeCount: Int
    let user: User
    
    init(question: QuestionsResponse.DataClass.Question) {
        self.id = question.id
        self.body = question.body
        self.createdAt = CreatedAt(iso8601: question.createdAt.iso8601,
                                 en: question.createdAt.en,
                                 id: question.createdAt.id)
        self.created = question.created
        self.likeCount = question.likeCount
        self.user = User(id: question.user.id,
                         email: question.user.email,
                         firstName: question.user.firstName,
                         lastName: question.user.lastName,
                         username: question.user.username ?? "",
                         avatar: User.Avatar(url: question.user.avatar.url ?? "",
                                             thumbnail: User.Avatar.ImageSize(url: question.user.avatar.thumbnail.url ?? ""),
                                             thumbnailSquare: User.Avatar.ImageSize(url: question.user.avatar.thumbnailSquare.url ?? ""),
                                             medium: User.Avatar.ImageSize(url: question.user.avatar.medium.url ?? ""),
                                             mediumSquare: User.Avatar.ImageSize(url: question.user.avatar.mediumSquare.url ?? "")),
                         verified: question.user.verified,
                         about: question.user.about ?? "")
        
    }
    
    public struct CreatedAt {
        let iso8601, en, id: String
    }
    
    public struct User: Codable {
        let id, email, firstName, lastName: String
        let username: String
        let avatar: Avatar
        let verified: Bool
        let about: String
        
        public struct Avatar: Codable {
            let url: String
            let thumbnail, thumbnailSquare, medium, mediumSquare: ImageSize
            
            struct ImageSize: Codable {
                let url: String
            }
        }
    }
}
