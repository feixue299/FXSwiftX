//
//  CGSize+Extensions.swift
//  FXSwiftX
//
//  Created by aria on 2024/12/4.
//

import CoreGraphics

public extension CGSize {
    
    /// 按指定比例裁剪一个尺寸
    /// - Parameters:
    ///   - aspectRatio: 目标宽高比（宽 / 高）
    /// - Returns: 裁剪后的尺寸
    func cropSizeToAspectRatio(aspectRatio: CGFloat) -> CGSize {
        let originalAspectRatio = width / height
        
        if originalAspectRatio > aspectRatio {
            // 原始宽高比大于目标比例，需要裁剪宽度
            let newWidth = height * aspectRatio
            return CGSize(width: newWidth, height: height)
        } else {
            // 原始宽高比小于或等于目标比例，需要裁剪高度
            let newHeight = width / aspectRatio
            return CGSize(width: width, height: newHeight)
        }
    }
    
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
}
