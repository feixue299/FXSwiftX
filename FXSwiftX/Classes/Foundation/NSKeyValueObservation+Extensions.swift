//
//  NSKeyValueObservation+Extensions.swift
//  
//
//  Created by aria on 2022/10/14.
//

import Foundation

public extension NSKeyValueObservation {
  func disposeBy(bag: Reference<[Any]>) {
    bag.value.append(self)
  }
}
