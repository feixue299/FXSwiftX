//
//  NSError+Extensions.swift
//  LightMagic
//
//  Created by aria on 2025/5/14.
//

import Foundation

public extension NSError {

  static func client(description: String) -> NSError {
    NSError(
      domain: Bundle.main.bundleIdentifier ?? "",
      code: 0,
      userInfo: [
        NSLocalizedDescriptionKey: description,
      ]
    )
  }
  
  static func clientJustThrow() -> NSError {
    client(description: "")
  }
}
