//
//  PropertyWrapperX.swift
//  FXSwiftX
//
//  Created by hard on 2021/11/4.
//

import Foundation

@propertyWrapper
public struct UserDefault<T: Codable> {

    struct Wrapper<T> : Codable where T : Codable {
        let wrapped : T
    }

    
    let key: String
    let defaultValue: T
    
    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            var value: T = defaultValue
            if let objectValue = UserDefaults.standard.object(T.self, with: key) {
                value = objectValue
            } else if let objectValue = UserDefaults.standard.object(Wrapper<T>.self, with: key)?.wrapped {
                value = objectValue
            }
            
            return value
        }
        set {
            UserDefaults.standard.set(object: Wrapper(wrapped: newValue), forKey: key)
        }
    }
    
}
