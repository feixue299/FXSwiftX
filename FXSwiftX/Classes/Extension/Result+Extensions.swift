//
//  Result+Extensions.swift
//  FXSwiftX
//
//  Created by aria on 2023/1/11.
//

import Foundation

public extension Result {
    
    var value: Success? {
        switch self {
        case .success(let success):
            return success
        case .failure(let failure):
            return nil
        }
    }
}
