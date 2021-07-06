//
//  SwiftUIX.swift
//  FXKit
//
//  Created by iMac on 2021/4/6.
//

import SwiftUI

/// See `View.onChange(of: value, perform: action)` for more information
@available(iOS 13.0, *)
public struct ChangeObserver<Base: View, Value: Equatable>: View {
    let base: Base
    let value: Value
    let action: (Value)->Void

    let model = Model()

    public var body: some View {
        if model.update(value: value) {
            DispatchQueue.main.async { self.action(self.value) }
        }
        return base
    }

    class Model {
        private var savedValue: Value?
        func update(value: Value) -> Bool {
            guard value != savedValue else { return false }
            savedValue = value
            return true
        }
    }
}

@available(iOS 13.0, *)
public extension View {
    /// Adds a modifier for this view that fires an action when a specific value changes.
    ///
    /// You can use `onChange` to trigger a side effect as the result of a value changing, such as an Environment key or a Binding.
    ///
    /// `onChange` is called on the main thread. Avoid performing long-running tasks on the main thread. If you need to perform a long-running task in response to value changing, you should dispatch to a background queue.
    ///
    /// The new value is passed into the closure. The previous value may be captured by the closure to compare it to the new value. For example, in the following code example, PlayerView passes both the old and new values to the model.
    ///
    /// ```
    /// struct PlayerView : View {
    ///   var episode: Episode
    ///   @State private var playState: PlayState
    ///
    ///   var body: some View {
    ///     VStack {
    ///       Text(episode.title)
    ///       Text(episode.showTitle)
    ///       PlayButton(playState: $playState)
    ///     }
    ///   }
    ///   .onChange(of: playState) { [playState] newState in
    ///     model.playStateDidChange(from: playState, to: newState)
    ///   }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - value: The value to check against when determining whether to run the closure.
    ///   - action: A closure to run when the value changes.
    ///   - newValue: The new value that failed the comparison check.
    /// - Returns: A modified version of this view
    func onChange<Value: Equatable>(of value: Value, perform action: @escaping (_ newValue: Value)->Void) -> ChangeObserver<Self, Value> {
        ChangeObserver(base: self, value: value, action: action)
    }
}

@available(iOS 13.0, *)
public struct SegmentView: UIViewRepresentable {
    public typealias UIViewType = SegmentControl
    
    public typealias SegmentCallBack = (Int) -> Void
    
    public class SegmentControl: UIView {
        let segmentCallBack: SegmentCallBack?
        
        let segmentControl: UISegmentedControl
        
        init(items: [Any]?, segmentCallBack: SegmentCallBack? = nil) {
            self.segmentCallBack = segmentCallBack
            segmentControl = UISegmentedControl(items: items)
            super.init(frame: .zero)
            
            segmentControl.addTarget(self, action: #selector(valueChanged(sender:)), for: .valueChanged)
            
            addSubview(segmentControl)
            
            segmentControl.translatesAutoresizingMaskIntoConstraints = false
            
            segmentControl.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            segmentControl.topAnchor.constraint(equalTo: topAnchor).isActive = true
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            segmentControl.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc private func valueChanged(sender: UISegmentedControl) {
            segmentCallBack?(sender.selectedSegmentIndex)
        }
    }
    
    let items: [Any]?
    let segmentCallback: SegmentCallBack?
    
    public init(items: [Any]? = nil, segmentCallback: SegmentCallBack? = nil) {
        self.items = items
        self.segmentCallback = segmentCallback
    }
    
    public func makeUIView(context: Context) -> SegmentControl {
        let view = SegmentControl(items: items, segmentCallBack: segmentCallback)
        view.segmentControl.selectedSegmentIndex = 0
        return view
    }
    
    public func updateUIView(_ uiView: SegmentControl, context: Context) {
        
    }
    
}
