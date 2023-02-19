//
//  APP+Extensions.swift
//  FXSwiftX
//
//  Created by aria on 2021/11/4.
//

import Foundation

public struct APP {
    public static var version: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    public static var buildVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
}
