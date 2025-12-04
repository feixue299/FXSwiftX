//
//  Observable+Extensions.swift
//  FXSwiftX
//
//  Created by aria on 2025/12/5.
//

import Observation
import Combine
import Foundation

@available(iOS 17.0, *)
public extension Observation.Observable where Self: AnyObject {
    func publisher<T>(keyPah: KeyPath<Self, T>) -> CurrentValueSubject<T, Never> {
        
        let initValue = self[keyPath: keyPah]
        
        let subject = CurrentValueSubject<T, Never>(initValue)
        
        observableTracking(object: subject) { [weak self, weak subject] in
            if let self {
                let value = self[keyPath: keyPah]
                subject?.send(value)
            }
        }
        
        return subject
    }
    
    func observableTracking<T>(object: AnyObject?, apply: @escaping () -> T) {
        _ = Observation.withObservationTracking {
            apply()
        } onChange: { [weak object, weak self] in
            guard object != nil else { return }
            DispatchQueue.main.async {
                self?.observableTracking(object: object, apply: apply)
            }
        }

    }
}
