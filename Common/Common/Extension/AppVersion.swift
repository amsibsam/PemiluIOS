//
//  AppVersion.swift
//  Common
//
//  Created by Hanif Sugiyanto on 18/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public func versionString() -> String {
    let dictionary = Bundle.main.infoDictionary!
    let version = dictionary["CFBundleShortVersionString"] as! String
    let build = dictionary["CFBundleVersion"] as! String
    return "Versi \(version).\(build)"
}
