//
//  File.swift
//
//
//  Created by aria on 2024/8/17.
//

import Foundation

public extension Comparable {
    
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
    
}
