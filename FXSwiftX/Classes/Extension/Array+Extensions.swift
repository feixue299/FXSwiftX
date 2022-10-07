//
//  Array+Extensions.swift
//  InstagramUtilities
//
//  Created by aria on 2022/10/7.
//

import Foundation

public extension Array where Element == UInt8 {
    var hexString: String {
        return self.compactMap { String(format: "%02x", $0).uppercased() }
        .joined(separator: "")
    }
}
