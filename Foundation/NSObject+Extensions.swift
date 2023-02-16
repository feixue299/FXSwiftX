//
//  NSObject+Extensions.swift
//  FXSwiftX
//
//  Created by aria on 2023/2/16.
//

import Foundation
import ObjectiveC

public extension NSObject {

  static func swizzleInstanceMethod(origin: Selector, swizzled: Selector) {
    guard
      let originMethod = class_getInstanceMethod(self, origin),
      let swizzledMethod = class_getInstanceMethod(self, swizzled)
    else {
      assertionFailure()
      return
    }
    swizzle(
      klass: self,
      origin: origin,
      originMethod: originMethod,
      swizzled: swizzled,
      swizzledMethod: swizzledMethod
    )
  }

  static func swizzleClassMethod(origin: Selector, swizzled: Selector) {
    guard
      let klass = object_getClass(self),
      let originMethod = class_getClassMethod(klass, origin),
      let swizzledMethod = class_getClassMethod(klass, swizzled)
    else {
      assertionFailure()
      return
    }
    swizzle(
      klass: klass,
      origin: origin,
      originMethod: originMethod,
      swizzled: swizzled,
      swizzledMethod: swizzledMethod
    )
  }

  private static func swizzle(
    klass: AnyClass,
    origin: Selector,
    originMethod: Method,
    swizzled: Selector,
    swizzledMethod: Method
  ) {
    let didAddMethod = class_addMethod(
      klass,
      origin,
      method_getImplementation(swizzledMethod),
      method_getTypeEncoding(swizzledMethod)
    )

    if didAddMethod {
      class_replaceMethod(
        klass,
        swizzled,
        method_getImplementation(originMethod),
        method_getTypeEncoding(originMethod)
      )
    } else {
      method_exchangeImplementations(
        originMethod,
        swizzledMethod
      )
    }
  }
}
