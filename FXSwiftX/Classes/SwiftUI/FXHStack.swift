//
//  FXHStack.swift
//
//
//  Created by aria on 2024/8/17.
//

import SwiftUI

public struct FXHStack<Content>: View where Content : View {
  
  let alignment: VerticalAlignment
  let spacing: CGFloat?
  let content: Content
  
  public init(alignment: VerticalAlignment = .center, spacing: CGFloat? = 0, @ViewBuilder content: () -> Content) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }
  
  public var body: some View {
    HStack(alignment: self.alignment, spacing: self.spacing) {
      content
    }
  }
}
