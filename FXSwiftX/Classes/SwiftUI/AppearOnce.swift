//
//  AppearOnce.swift
//
//
//  Created by aria on 2024/8/16.
//

import SwiftUI

public struct AppearOnce: ViewModifier {
    @State
    var isFirst = true
    let perform: (Bool) -> Void
    
    public init(perform action: @escaping (_ isFirst: Bool) -> Void) {
        self.perform = action
    }
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                perform(isFirst)
                if isFirst {
                    isFirst = false
                }
            }
        
    }
}
