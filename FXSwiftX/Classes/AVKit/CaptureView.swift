//
//  CaptureView.swift
//  
//
//  Created by aria on 2022/11/28.
//

import UIKit
import AVKit

open class CaptureView: UIView {
    
    public let previewLayer = AVCaptureVideoPreviewLayer()
    public var captureDevice: AVCaptureDevice?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = layer.bounds
    }
    
}
