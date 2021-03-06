//
//  GroupProfileInfoData.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 24/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxDataSources
import Common

enum GroupProfileInfoData {
    case cluster
    case biodata
    case badge
    
    var title: String {
        switch self {
        case .cluster:
            return "Cluster"
        case .biodata:
            return "Biodata"
        case .badge:
            return "Badge"
        }
    }
}

struct SectionOfProfileData {
    var items: [Item]
}

extension SectionOfProfileData: SectionModelType {
    typealias Item = ICellConfigurator
    
    init(original: SectionOfProfileData, items: [ICellConfigurator]) {
        self = original
        self.items = items
    }
}
