//
//  WithTry.swift
//
//
//  Created by aria on 2024/7/16.
//

import Foundation

public func withTry(file: String = #file, line: Int = #line, _ closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        print("file: \(file), line: \(line), error: \(error)")
    }
}

