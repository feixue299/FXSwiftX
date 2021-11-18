//
//  CodableX.swift
//  FXSwiftX
//
//  Created by Mr.wu on 2021/5/2.
//

import Foundation

public struct StringConvert: Codable, Hashable {
    public let value: String
    
    public init(value: String) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            self.value = "\(value)"
        } else {
            value = try container.decode(String.self)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
}
