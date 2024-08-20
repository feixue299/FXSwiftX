//
//  FXVStack.swift
//  
//
//  Created by aria on 2024/8/17.
//

import SwiftUI

public struct FXVStack<Content>: View where Content : View {
  
  let alignment: HorizontalAlignment
  let spacing: CGFloat?
  let content: Content
  
  public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = 0, @ViewBuilder content: () -> Content) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }
  
  public var body: some View {
    VStack(alignment: self.alignment, spacing: self.spacing) {
      content
    }
  }
}
