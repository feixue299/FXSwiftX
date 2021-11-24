//
//  CacheX.swift
//  FXSwiftX
//
//  Created by hard on 2021/11/11.
//

import Foundation

@propertyWrapper
public struct UserDefaultCache<T: Codable> {
    
    public enum ExpiredDate {
        case second(Int)
        case minutes(Int)
        case hour(Int)
        case day(Int)
    }
    
    public var key: String {
        return _key()
    }
    private let _key: () -> String
    public let defaultValue: T
    public let expiredDate: ExpiredDate
    private var dateKey: String { return "\(key)_date" }
    
    public init(_ key: @autoclosure @escaping () -> String, defaultValue: T, expiredDate: ExpiredDate) {
        self._key = key
        self.defaultValue = defaultValue
        self.expiredDate = expiredDate
    }
    
    public var wrappedValue: T {
        get {
            let value = UserDefaults.standard.object(T.self, with: key) ?? defaultValue
            if lastUpdateDate != nil {
                if isExpired {
                    expired()
                    return defaultValue
                } else {
                    return value
                }
            } else {
                return value
            }
        }
        set {
            UserDefaults.standard.set(object: newValue, forKey: key)
            lastUpdateDate = Date()
        }
    }
    
    public var isExpired: Bool {
        guard let lastUpdateDate = lastUpdateDate else { return true }
        let now = Date()
        let timeInterval = Int(now.timeIntervalSince1970 - lastUpdateDate.timeIntervalSince1970)
        let isExpired: Bool
        switch expiredDate {
        case .second(let int):
            isExpired = timeInterval > int
        case .minutes(let int):
            isExpired = timeInterval > int * 60
        case .hour(let int):
            isExpired = timeInterval > int * 60 * 60
        case .day(let int):
            isExpired = timeInterval > int * 60 * 60 * 24
        }
        return isExpired
    }
    
    public private(set) var lastUpdateDate: Date? {
        set {
            UserDefaults.standard.setValue(Date(), forKey: dateKey)
        }
        get {
            return UserDefaults.standard.value(forKey: dateKey) as? Date
        }
    }
    
    public func expired() {
        UserDefaults.standard.set(nil, forKey: key)
        UserDefaults.standard.set(nil, forKey: dateKey)
    }
    
}

extension UserDefaults {
    /// SwifterSwift: Retrieves a Codable object from UserDefaults.
    ///
    /// - Parameters:
    ///   - type: Class that conforms to the Codable protocol.
    ///   - key: Identifier of the object.
    ///   - decoder: Custom JSONDecoder instance. Defaults to `JSONDecoder()`.
    /// - Returns: Codable object for key (if exists).
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }

    /// SwifterSwift: Allows storing of Codable objects to UserDefaults.
    ///
    /// - Parameters:
    ///   - object: Codable object to store.
    ///   - key: Identifier of the object.
    ///   - encoder: Custom JSONEncoder instance. Defaults to `JSONEncoder()`.
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        set(data, forKey: key)
    }
}
