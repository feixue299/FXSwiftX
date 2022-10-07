//
//  Optional+Extensions.swift
//  InstagramUtilities
//
//  Created by aria on 2022/10/7.
//

import Foundation

public extension Optional {
    func `let`(_ closure: (Wrapped) -> Void) {
        switch self {
        case .some(let value):
            closure(value)
        case .none:
            break
        }
    }
}
