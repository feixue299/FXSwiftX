//
//  EdgePresentContainerView.swift
//  FXSwiftX
//
//  Created by aria on 2025/8/24.
//

import SwiftUI

// 1. 定义一个 EnvironmentKey
private struct EdgeDismissKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

// 2. 给 EnvironmentValues 扩展属性
public extension EnvironmentValues {
    var edgeDismiss: () -> Void {
        get { self[EdgeDismissKey.self] }
        set { self[EdgeDismissKey.self] = newValue }
    }
}

public struct EdgePresentContainerView<Item, Content: View>: View {
    
    let mainView: (Item) -> Content
    let alignment: Alignment
    @Binding
    var item: Item?
    
    public init(item: Binding<Item?>, alignment: Alignment = .bottom, @ViewBuilder content: @escaping (Item) -> Content) {
        self._item = item
        self.alignment = alignment
        self.mainView = content
    }
    
    public var body: some View {
        
        ZStack(alignment: alignment) {
            if let item {
                
                mainView(item)
                    .environment(\.edgeDismiss) {
                        self.item = nil
                    }
                    .transition(.move(edge: edge()))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut, value: item != nil)
    }
    
    private func edge() -> Edge {
        switch alignment {
        case .top:
            return .top
        case .leading:
            return .leading
        case .bottom:
            return .bottom
        case .trailing:
            return .trailing
        default:
            return .bottom
        }
    }
}

public extension EdgePresentContainerView where Item == Int {
    init(isShowing: Binding<Bool>, alignment: Alignment = .bottom, @ViewBuilder mainView: @escaping () -> Content) {
        let binding = Binding(get: { isShowing.wrappedValue ? 1 : nil }, set: { isShowing.wrappedValue = $0 != nil })
        self.init(item: binding, alignment: alignment, content: { _ in mainView() })
    }
}
