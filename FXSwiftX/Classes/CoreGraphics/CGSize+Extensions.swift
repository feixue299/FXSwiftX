//
//  CGSize+Extensions.swift
//  FXSwiftX
//
//  Created by aria on 2024/12/4.
//

import CoreGraphics
import UIKit

public extension CGSize {
    
    init(sideLength: Int) {
        self.init(width: sideLength, height: sideLength)
    }
    
    init(sideLength: Double) {
        self.init(width: sideLength, height: sideLength)
    }
    
    init(sideLength: CGFloat) {
        self.init(width: sideLength, height: sideLength)
    }
    
    var aspectRatio: CGFloat { width / height }
    
    /// 按指定比例裁剪一个尺寸
    /// - Parameters:
    ///   - aspectRatio: 目标宽高比（宽 / 高）
    /// - Returns: 裁剪后的尺寸
    func cropSizeToAspectRatio(aspectRatio: CGFloat) -> CGSize {
        resizeAspectRatio(aspectRatio: aspectRatio, mode: .scaleAspectFit)
    }
    
    func resizeAspectRatio(aspectRatio: CGFloat, mode: UIView.ContentMode = .scaleAspectFit) -> CGSize {
        let originalRatio = width / height
        
        switch mode {
        case .scaleAspectFit:
            // Fit 模式：裁剪多余部分，保证内容完整（可能留白）
            if originalRatio > aspectRatio {
                // 原始更宽 → 裁剪宽度（保持高度）
                return CGSize(width: height * aspectRatio, height: height)
            } else {
                // 原始更高 → 裁剪高度（保持宽度）
                return CGSize(width: width, height: width / aspectRatio)
            }
            
        case .scaleAspectFill:
            // Fill 模式：扩展不足部分，保证填满（可能裁剪）
            if originalRatio > aspectRatio {
                // 原始更宽 → 扩展高度（裁剪宽度）
                return CGSize(width: width, height: width / aspectRatio)
            } else {
                // 原始更高 → 扩展宽度（裁剪高度）
                return CGSize(width: height * aspectRatio, height: height)
            }
        default:
            return self
        }
    }
}
