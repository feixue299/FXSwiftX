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

public extension NSObject {
    
    @available(iOS 13.0, *)
    var observationBagRef: Reference<[AnyCancellable]> {
        if let bagRef = objc_getAssociatedObject(self, &key) as? Reference<[AnyCancellable]> {
            return bagRef
        } else {
            let bagRef = Reference<[AnyCancellable]>([])
            objc_setAssociatedObject(self, &key, bagRef, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bagRef
        }
    }
    
    var bagRef: Reference<[Any]> {
        if let bagRef = objc_getAssociatedObject(self, &bagKey) as? Reference<[Any]> {
            return bagRef
        } else {
            let bagRef = Reference<[Any]>([])
            objc_setAssociatedObject(self, &bagKey, bagRef, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bagRef
        }
    }
    
}

public protocol DisposeBagProtocol {}

public extension DisposeBagProtocol {
    var bag: DisposeBag {
        if let bag = objc_getAssociatedObject(self, &disposeBagKey) as? DisposeBag {
            return bag
        } else {
            let bag = DisposeBag()
            objc_setAssociatedObject(self, &disposeBagKey, bag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bag
        }
    }
}

extension NSObject: DisposeBagProtocol { }

@available(iOS 13.0, *)
public extension ObservableObject where Self: AnyObject {
    var bag: DisposeBag {
        if let bag = objc_getAssociatedObject(self, &disposeBagKey) as? DisposeBag {
            return bag
        } else {
            let bag = DisposeBag()
            objc_setAssociatedObject(self, &disposeBagKey, bag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bag
        }
    }
}


private var key = true
private var bagKey = true
private var disposeBagKey = true
