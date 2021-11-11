//
//  PropertyWrapperX.swift
//  FXSwiftX
//
//  Created by hard on 2021/11/4.
//

import Foundation

@propertyWrapper
public struct UserDefault<T> {
    
    let key: String
    let defaultValue: T
    
    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
    
}
