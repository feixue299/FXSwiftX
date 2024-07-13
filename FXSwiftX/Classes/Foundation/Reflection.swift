//
//  Reflection.swift
//
//
//  Created by aria on 2024/7/14.
//

import Foundation

public struct Reflection {
    
    public static func printProperties<T>(_ object: T) -> String {
        let mirror = Mirror(reflecting: object)
        var dic: [String: Any] = [:]
        for child in mirror.children {
            if let propertyName = child.label {
                dic[propertyName] = child.value
            }
        }
        return "object:\(object), property:\(dic)"
    }
    
}
