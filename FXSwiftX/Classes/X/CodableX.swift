//
//  CodableX.swift
//  FXSwiftX
//
//  Created by Mr.wu on 2021/5/2.
//

import Foundation

public struct StringConvert: Codable {
    public let value: String
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            self.value = "\(value)"
        } else {
            value = try container.decode(String.self)
        }
    }
}
