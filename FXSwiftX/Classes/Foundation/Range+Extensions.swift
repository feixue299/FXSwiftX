//
//  Range+Extensions.swift
//  FXSwiftX
//
//  Created by aria on 2022/9/27.
//

import Foundation

public extension Range where Bound == Double {
    var random: Double { Double.random(in: self) }
}
