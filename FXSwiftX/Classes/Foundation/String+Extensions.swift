//
//  String+Extensions.swift
//  FXSwiftX
//
//  Created by aria on 2022/10/12.
//

import Foundation

public extension String {
    var jsonObject: Any? {
        return jsonData.map({ try? JSONSerialization.jsonObject(with: $0) })?.flatMap({ $0 })
    }
    
    var jsonData: Data? {
        data(using: .utf8)
    }
}
