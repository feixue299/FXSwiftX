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

    
    public var key: String {
        return _key()
    }
    private let _key: () -> String
    public let defaultValue: T
    
    public init(_ key: @autoclosure @escaping () -> String, defaultValue: T) {
        self._key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            var value: T = defaultValue
            if let objectValue = UserDefaults.standard.object(Wrapper<T>.self, with: key)?.wrapped {
                value = objectValue
            }
            
            return value
        }
        set {
            UserDefaults.standard.set(object: Wrapper(wrapped: newValue), forKey: key)
        }
    }
    
}
