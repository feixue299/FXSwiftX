//
//  Int+Extensions.swift
//  InstagramUtilities
//
//  Created by aria on 2022/10/7.
//

import Foundation

public extension Int {
    var bcdValue: [UInt8] {
        let str = Array("\(self)")
        let snippetCount = (str.count / 2) + (str.count % 2 == 0 ? 0 : 1)
        let arr = (0..<snippetCount).reversed().map({ index -> UInt8 in
            let endIndex = Swift.min(index * 2, str.count - 1)
            let startIndex = Swift.max(endIndex - 1, 0)
            let string = String(str[startIndex...endIndex])
            let int = Int(string)!
            let uint8: UInt8 = UInt8(int / 10 * 16 + int % 10)
            return uint8
        })
        
        return arr.reversed()
    }
}
