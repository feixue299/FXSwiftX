//
//  UINavigationController+Replace.swift
//

#if os(iOS)
import UIKit

public extension UINavigationController {

  func replace(viewController: UIViewController, animated: Bool) {
    var viewControllers = self.viewControllers
    guard !viewControllers.isEmpty else { return }
    viewControllers.removeLast()
    viewControllers.append(viewController)
    setViewControllers(viewControllers, animated: animated)
  }
}

#endif
