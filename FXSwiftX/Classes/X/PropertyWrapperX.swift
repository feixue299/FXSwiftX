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
    private var _storeKey: String
    public let defaultValue: T
    private var _wrappedValue: T?
    
    public init(_ key: @autoclosure @escaping () -> String, defaultValue: T) {
        self._key = key
        self._storeKey = key()
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        mutating get {
            if _storeKey != key {
                _storeKey = key
            } else if let _wrappedValue = _wrappedValue {
                return _wrappedValue
            }
            var value: T = defaultValue
            if let objectValue = UserDefaults.standard.object(Wrapper<T>.self, with: key)?.wrapped {
                value = objectValue
            }
            _wrappedValue = value
            return value
        }
        set {
            _wrappedValue = newValue
            UserDefaults.standard.set(object: Wrapper(wrapped: newValue), forKey: key)
        }
    }
    
}

@propertyWrapper
public struct AssociatedObject<T: AnyObject> {
    private var key: String = "AssociatedObject.key"
    
    public let defaultValue: T
    public init(defaultValue: T) {
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        set {
            objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        mutating get {
            let model: T
            if let aModel = objc_getAssociatedObject(self, &key) as? T {
                model = aModel
            } else {
                model = defaultValue
                self.wrappedValue = model
            }
            return model
        }
    }
}
