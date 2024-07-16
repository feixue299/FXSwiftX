//
//  WithTry.swift
//
//
//  Created by aria on 2024/7/16.
//

import Foundation

public func withTry(_ closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        print("\(Bundle.main.bundleIdentifier ?? "") error: \(error)")
    }
}
