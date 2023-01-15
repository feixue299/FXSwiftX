//
//  Reference.swift
//  FXSwiftX
//
//  Created by aria on 2023/1/12.
//

import Foundation

public final class Reference<Value> {
  public var value: Value

  public init(_ value: Value) {
    self.value = value
  }
}

extension Reference: Equatable where Value: Equatable {

  public static func == (lhs: Reference<Value>, rhs: Reference<Value>) -> Bool {
    lhs.value == rhs.value
  }
}

extension Reference: Hashable where Value: Hashable {

  public func hash(into hasher: inout Hasher) {
    value.hash(into: &hasher)
  }
}

extension Reference: Codable where Value: Codable {

  public convenience init(from decoder: Decoder) throws {
    try self.init(Value(from: decoder))
  }

  public func encode(to encoder: Encoder) throws {
    try value.encode(to: encoder)
  }
}

public extension Reference where Value: ExpressibleByDictionaryLiteral {

  convenience init() {
    self.init([:])
  }
}

public extension Reference where Value: ExpressibleByArrayLiteral {

  convenience init() {
    self.init([])
  }
}
