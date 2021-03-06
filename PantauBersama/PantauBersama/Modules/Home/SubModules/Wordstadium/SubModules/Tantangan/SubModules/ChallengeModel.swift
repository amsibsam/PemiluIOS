//
//  ChallengeModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

struct ChallengeModel {
    var tag: String?
    var statement: String?
    var source: String?
    var timeAt: String?
    var limitAt: String?
    var userId: String? = nil
    var screenName: String? = nil
    var timeString: String? = nil
    var userAvatar: String? = nil
    var dateString: String? = nil
    var opponentName: String? = nil
    var opponentUsername: String? = nil
    var opponentStatus: Bool? = false
    
    init(tag: String?, statement: String?, source: String?, timeAt: String, limitAt: String?, userId: String?, screenName: String?, timeString: String?, userAvatar: String?, dateString: String?, opponentName: String?, opponentUsername: String?, opponentStatus: Bool?) {
        self.tag = tag
        self.statement = statement
        self.source = source
        self.timeAt = timeAt
        self.limitAt = limitAt
        self.userId = userId
        self.screenName = screenName
        self.timeString = timeString
        self.userAvatar = userAvatar
        self.dateString = dateString
        self.opponentName = opponentName
        self.opponentUsername = opponentUsername
        self.opponentStatus = opponentStatus
    }
}
