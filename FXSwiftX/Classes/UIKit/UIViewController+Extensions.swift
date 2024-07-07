//
//  UIViewController+Extensions.swift
//  FXSwiftX
//
//  Created by hard on 2021/10/29.
//

#if os(iOS)
import Foundation
import UIKit

public extension UIViewController {
    func share(text: String? = nil, image: UIImage? = nil, url: URL? = nil, completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        var items: [Any] = []
        if let text = text {
            items.append(text)
        }
        if let image = image {
            items.append(image)
        }
        if let url = url {
            items.append(url)
        }
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.completionWithItemsHandler = completionWithItemsHandler
        
        present(activityVC, animated: true, completion: nil)
    }
    
    class func navigationController() -> UINavigationController {
        let vc = Self.init()
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }
}
#endif
