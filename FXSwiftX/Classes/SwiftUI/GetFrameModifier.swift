//
//  GetFrameModifier.swift
//
//
//  Created by aria on 2023/7/20.
//

import SwiftUI

// 这个Modifier比较危险(容易死循环)，谨慎使用
@available(iOS 14.0, *)
public struct GetFrameModifier: ViewModifier {
  
  @Binding
  public var currentFrame: CGRect
  let coordinateSpace: CoordinateSpace
  
  public init(currentFrame: Binding<CGRect>, coordinateSpace: CoordinateSpace = .global) {
    self._currentFrame = currentFrame
    self.coordinateSpace = coordinateSpace
  }
  
  public func body(content: Content) -> some View {
    content
      .background(
        GeometryReader { geometry in
          Color.clear
            .onAppear {
              currentFrame = geometry.frame(in: coordinateSpace)
            }
            .onChange(of: geometry.frame(in: coordinateSpace)) { newFrame in
              currentFrame = newFrame
            }
        }
      )
  }
  
}
