//
//  UIViewController+Extensions.swift
//  FXSwiftX
//
//  Created by hard on 2021/10/29.
//

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
}
