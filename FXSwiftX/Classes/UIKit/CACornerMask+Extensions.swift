//
//  CACornerMask+Extensions.swift
//  FXSwiftX
//
//  Created by aria on 2023/2/16.
//

import Foundation
import QuartzCore

public extension CACornerMask {
  static let all: CACornerMask = [.top, .bottom]
  static let top: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  static let bottom: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
  static let left: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
  static let right: CACornerMask = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
}
