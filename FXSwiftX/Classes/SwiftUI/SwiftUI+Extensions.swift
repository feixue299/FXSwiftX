//
//  File.swift
//  
//
//  Created by aria on 2022/9/1.
//

import Foundation
import UIKit
import SwiftUI

@available(iOS 13.0, *)
public extension View {
    
    func onTapGestureForced(
        count: Int = 1,
        perform action: @escaping () -> Void
    ) -> some View {
        self
            .contentShape(Rectangle())
            .onTapGesture(count: count, perform: action)
    }
}

@available(iOS 13.0, *)
public struct UIViewPreview<V: UIView>: UIViewRepresentable {
    
    public let size: CGSize?
    public let builder: () -> V
    
    public init(size: CGSize? = nil, builder: @escaping () -> V) {
        self.size = size
        self.builder = builder
    }
    
    public func makeUIView(context: Context) -> some UIView {
        let view = builder()
        if let size {
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: size.width),
                view.heightAnchor.constraint(equalToConstant: size.height),
            ])
        }
        return view
    }
    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}

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
public extension View {
    func asyncTask(_ action: @Sendable @escaping () async -> Void) -> some View {
        var task: Task<Void, Error>?
        
        return self
            .onAppear {
                task = Task {
                    await action()
                }
            }
            .onDisappear {
                task?.cancel()
            }
    }
}

@available(iOS 13.0, *)
public struct FXViewPreview: UIViewRepresentable {
  public typealias UIViewType = UIView
  
  public let builder: () -> UIView

  public init(builder: @escaping () -> UIView) {
    self.builder = builder
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
  
  public func updateUIView(_ uiView: UIView, context: Context) { }
  
}

