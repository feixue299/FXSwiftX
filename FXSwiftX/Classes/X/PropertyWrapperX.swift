//
//  PropertyWrapperX.swift
//  FXSwiftX
//
//  Created by hard on 2021/11/4.
//

import Foundation

@propertyWrapper
public struct UserDefault<T: Codable> {
    
    public var key: String {
        return _key()
    }
    private let _key: () -> String
    public let defaultValue: T
    private var _wrappedValue: T?
    
    public init(_ key: @autoclosure @escaping () -> String, defaultValue: T) {
        self._key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        mutating get {
            if let _wrappedValue = _wrappedValue {
                return _wrappedValue
            }
            var value: T = defaultValue
            if let objectValue = UserDefaults.standard.object(CodableWrapper<T>.self, with: key)?.wrapped {
                value = objectValue
            }
            _wrappedValue = value
            return value
        }
        set {
            _wrappedValue = newValue
            UserDefaults.standard.set(object: CodableWrapper(wrapped: newValue), forKey: key)
        }
    }
    
}
