//
//  Combine+Extension.swift
//  FXSwiftX
//
//  Created by aria on 2022/6/8.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public extension AnyCancellable {
    func dispose(by bag: DisposeBag) {
        bag.insert(self)
    }
}
