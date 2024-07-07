//
//  File.swift
//  
//
//  Created by aria on 2023/9/6.
//

import SwiftUI

@available(macOS 10.15, *)
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
    
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    func frame(sideLength: CGFloat) -> some View {
        self.frame(width: sideLength, height: sideLength)
    }
    
    func horizontal(alignment: HorizontalAlignment) -> some View {
      Group {
        if alignment == .leading {
          HStack(spacing: 0) {
            self
            Spacer()
          }
        } else if alignment == .trailing {
          HStack(spacing: 0) {
            Spacer()
            self
          }
        } else {
          HStack(spacing: 0) {
            Spacer()
            self
            Spacer()
          }
        }
      }
    }
    
    func vertical(alignment: VerticalAlignment) -> some View {
      Group {
        if alignment == .top {
          VStack(spacing: 0) {
            self
            Spacer()
          }
        } else if alignment == .bottom {
          VStack(spacing: 0) {
            Spacer()
            self
          }
        } else {
          VStack(spacing: 0) {
            Spacer()
            self
            Spacer()
          }
        }
      }
    }
    
}

@available(macOS 10.15, *)
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

#if canImport(UIKit)
public extension View {
  func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
#endif
