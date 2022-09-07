//
//  CodeExecutionTime.swift
//  
//
//  Created by aria on 2022/9/6.
//

import Foundation

public class CodeExecutionTime {
  private var count: Int = 0
  private let startTime = CFAbsoluteTimeGetCurrent()
  
  public var prefix: String = ""
  public var isPrint: Bool = true
  
  public init() { }
  
  public func printTime(_ segment: String? = nil) {
    
    var str: String
    if let segment = segment {
      str = segment
    } else {
      count += 1
      str = "\(count)"
    }
    if isPrint {
      print("\(prefix) Linked \(str) in \((CFAbsoluteTimeGetCurrent() - startTime) * 1000.0) ms")
    }
  }
}
