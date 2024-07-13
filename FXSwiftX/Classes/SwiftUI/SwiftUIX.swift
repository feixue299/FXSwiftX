//
//  SwiftUIX.swift
//  FXKit
//
//  Created by iMac on 2021/4/6.
//

#if os(iOS) && canImport(SwiftUI)
import SwiftUI

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
#endif
