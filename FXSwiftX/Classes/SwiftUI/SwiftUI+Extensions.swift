//
//  File.swift
//  
//
//  Created by aria on 2022/9/1.
//

#if os(iOS)
import Foundation
import UIKit
import SwiftUI


@available(iOS 13.0, *)
public struct UIViewControllerPreview<VC: UIViewController>: UIViewControllerRepresentable {
    
    public let builder: () -> VC
    
    public init(builder: @escaping () -> VC) {
        self.builder = builder
    }
    
    public func makeUIViewController(context: Context) -> VC { builder() }
    public func updateUIViewController(_ uiViewController: VC, context: Context) {}
}


@available(iOS 13.0, *)
public extension Image {
    init(uiImage: UIImage?) {
        if let uiImage {
            self.init(uiImage: uiImage)
        } else {
            self.init(uiImage: UIImage())
        }
    }
}



@available(iOS 13.0, *)
public struct FXViewPreview<ContentView: UIView>: UIViewRepresentable {
    public typealias UIViewType = UIView
    
    public let builder: () -> ContentView
    public let updater: ((ContentView) -> Void)?
    
    public init(builder: @escaping () -> ContentView, updater: ((ContentView) -> Void)? = nil) {
        self.builder = builder
        self.updater = updater
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let customView = builder()
        
        customView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customView)
        
        NSLayoutConstraint.activate([
            customView.widthAnchor.constraint(equalTo: view.widthAnchor),
            customView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) { 
        if let view = uiView.subviews.first as? ContentView {
          updater?(view)
        }
    }
    
}

#endif
