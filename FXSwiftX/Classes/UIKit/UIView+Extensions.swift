//
//  UIView+Extensions.swift
//  FXSwiftX
//
//  Created by aria on 2023/2/16.
//

#if os(iOS)
import UIKit

public extension UIView {
    func capsule() {
      layer.cornerRadius = bounds.height / 2
      layer.masksToBounds = true
    }
}
#endif
