//
//  CombineX.swift
//  FXSwiftX
//
//  Created by aria on 2022/6/8.
//

import Foundation
import Combine

public class DisposeBag {
    private var cancelGroup: [Any] = []
    
    public init() { }
    
    func insert(_ value: Any) {
        cancelGroup.append(value)
    }
}
