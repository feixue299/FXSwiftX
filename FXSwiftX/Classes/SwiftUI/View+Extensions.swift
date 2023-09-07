//
//  File.swift
//  
//
//  Created by aria on 2023/9/6.
//

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

#if canImport(UIKit)
public extension View {
  func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
#endif
