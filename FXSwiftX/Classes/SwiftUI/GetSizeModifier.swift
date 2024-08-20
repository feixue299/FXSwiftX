//
//  GetSizeModifier.swift
//
//
//  Created by aria on 2023/7/24.
//

import SwiftUI

@available(iOS 14.0, *)
public struct GetSizeModifier: ViewModifier {
  
  @Binding
  public var currentSize: CGSize
  
  public init(currentSize: Binding<CGSize>) {
    self._currentSize = currentSize
  }
  
  public func body(content: Content) -> some View {
    content
      .background(
        GeometryReader { geometry in
          Color.clear
            .onAppear {
              currentSize = geometry.size
            }
            .onChange(of: geometry.size) { newSize in
              currentSize = newSize
            }
        }
      )
  }
  
}

