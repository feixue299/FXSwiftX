//
//  UINavigationController+Extensions.swift
//  FXSwiftX
//
//  Created by aria on 2022/10/14.
//

import SwiftUI

@available(iOS 13.0, *)
public extension UINavigationController {
    class func createBy<T: View>(view: T) -> Self {
        let vc = UIHostingController(rootView: view)
        let nav = Self.init(rootViewController: vc)
        return nav
    }
}
