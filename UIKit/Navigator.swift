//
//  Navigator.swift
//  

import SwiftUI
import UIKit

public enum Navigator {}

public extension Navigator {
    
    static func replace(viewController: UIViewController, animated: Bool = true) {
        assert(visibleNavigationController != nil)
        visibleNavigationController?.replace(viewController: viewController, animated: animated)
    }
    
    @available(iOS 13.0, *)
    static func replace<V: View>(view: V, animated: Bool = true) {
        assert(visibleNavigationController != nil)
        let viewController = UIHostingController(rootView: view)
        visibleNavigationController?.replace(viewController: viewController, animated: animated)
    }
    
    static func push(viewController: UIViewController, animated: Bool = true) {
        assert(visibleNavigationController != nil)
        visibleNavigationController?.pushViewController(viewController, animated: animated)
    }
    
    @available(iOS 13.0, *)
    static func push<V: View>(view: V, animated: Bool = true) {
        assert(visibleNavigationController != nil)
        let viewController = UIHostingController(rootView: view)
        visibleNavigationController?.pushViewController(viewController, animated: animated)
    }
    
    static func present(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        assert(visibleVC != nil)
        visibleVC?.present(viewController, animated: animated, completion: completion)
        
    }
    
    @available(iOS 13.0, *)
    static func present<V: View>(view: V, animated: Bool = true, completion: (() -> Void)? = nil) {
        assert(visibleVC != nil)
        let viewController = UIHostingController(rootView: view)
        visibleVC?.present(viewController, animated: animated, completion: completion)
    }
    
    static func pushOrPop(viewController: UIViewController, animated: Bool = true) {
        assert(visibleNavigationController != nil)
        if let vc = visibleNavigationController?.viewControllers.first(where: { $0.isKind(of: viewController.classForCoder) }) {
            visibleNavigationController?.popToViewController(vc, animated: true)
        } else {
            visibleNavigationController?.pushViewController(viewController, animated: animated)
        }
    }
    
    static func pop(animated: Bool = true) {
        assert(visibleNavigationController != nil)
        visibleNavigationController?.popViewController(animated: animated)
    }
    
    static func popToRootViewController(animated: Bool = true) {
        assert(visibleNavigationController != nil)
        visibleNavigationController?.popToRootViewController(animated: animated)
    }
    
}

public extension Navigator {
    
    private static var targetWindow: UIWindow? {
        let keyWindow: UIWindow?
        if let window = UIApplication.shared.delegate?.window?.flatMap({ $0 }) {
            keyWindow = window
        } else {
            if #available(iOS 13.0, *) {
                if let window = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.delegate as? UIWindowSceneDelegate)?.window {
                    keyWindow = window
                } else {
                    keyWindow = UIApplication.shared.keyWindow
                }
            } else {
                keyWindow = UIApplication.shared.windows.first
            }
        }
        
        return keyWindow
    }
    
    private static var rootVC: UIViewController? {
        targetWindow?.rootViewController
    }
    
    static var visibleVC: UIViewController? {
        guard let rootVC = rootVC else { return nil }
        return rootVC.topMostPresentedVC?.topMostVC
        ?? rootVC.topMostVC
    }
    
    static var visibleNavigationController: UINavigationController? {
        guard let rootVC = rootVC else { return nil }
        var vc = rootVC.topMostPresentedVC ?? rootVC
        while let presentingVC = vc.presentingViewController, vc.topMostVC.navigationController == nil {
            vc = presentingVC
        }
        return vc.topMostVC.navigationController
    }
}

extension UIViewController {
    
    @objc
    open var topMostVC: UIViewController { self }
    
    var topMostPresentedVC: UIViewController? {
        guard var presentedVC = presentedViewController else { return nil }
        while let next = presentedVC.presentedViewController {
            presentedVC = next
        }
        return presentedVC
    }
}

extension UINavigationController {
    
    override open var topMostVC: UIViewController {
        topViewController?.topMostVC ?? self
    }
}

extension UITabBarController {
    
    override open var topMostVC: UIViewController {
        selectedViewController?.topMostVC ?? self
    }
}
