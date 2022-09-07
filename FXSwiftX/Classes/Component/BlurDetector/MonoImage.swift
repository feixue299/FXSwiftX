//
//  MonoImage.swift
//  AccelerateBlurDetection
//
//  Created by aria on 2022/9/7.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import UIKit
import Accelerate

@available(iOS 13.0, *)
public class MonoImage {
  /*
   The Core Graphics image representation of the source asset.
   */
  public let image: UIImage
  /*
   The format of the source asset.
   */
  public private(set) var format: vImage_CGImageFormat?
  /*
   The vImage buffer containing a scaled down copy of the source asset.
   */
  public private(set) var sourceBuffer: vImage_Buffer?
  /*
   The 1-channel, 8-bit vImage buffer used as the operation destination.
   */
  public private(set) var destinationBuffer: vImage_Buffer?
  public private(set) var monoImage: UIImage?
  
  public init(image: UIImage) {
    if let cgImage = image.cgImage,
       let format = vImage_CGImageFormat(cgImage: cgImage),
       let sourceBuffer = Self.getBuffer(cgImage: cgImage, format: format) {
      self.format = format
      self.sourceBuffer = sourceBuffer
      self.destinationBuffer = Self.getDestinationBuffer(sourceBuffer: sourceBuffer)
    }
    self.image = image
    convertToMonoImage()
  }
  
  /// 释放内存
  public func free() {
    sourceBuffer?.free()
    destinationBuffer?.free()
  }
  
  private static func getBuffer(cgImage: CGImage, format: vImage_CGImageFormat) -> vImage_Buffer? {
    guard
      var sourceImageBuffer = try? vImage_Buffer(cgImage: cgImage,
                                                 format: format),
      
        var scaledBuffer = try? vImage_Buffer(width: Int(sourceImageBuffer.height / 3),
                                              height: Int(sourceImageBuffer.width / 3),
                                              bitsPerPixel: format.bitsPerPixel) else {
      return nil
    }
    
    defer {
      sourceImageBuffer.free()
    }
    
    vImageScale_ARGB8888(&sourceImageBuffer,
                         &scaledBuffer,
                         nil,
                         vImage_Flags(kvImageNoFlags))
    
    return scaledBuffer
  }
  
  private static func getDestinationBuffer(sourceBuffer: vImage_Buffer) -> vImage_Buffer? {
    guard let destinationBuffer = try? vImage_Buffer(width: Int(sourceBuffer.width),
                                                     height: Int(sourceBuffer.height),
                                                     bitsPerPixel: 8) else {
      return nil
    }
    
    return destinationBuffer
  }
  
  private func convertToMonoImage() {
    guard var sourceBuffer = sourceBuffer, var destinationBuffer = destinationBuffer else { return }
    
    // Declare the three coefficients that model the eye's sensitivity
    // to color.
    let redCoefficient: Float = 0.2126
    let greenCoefficient: Float = 0.7152
    let blueCoefficient: Float = 0.0722
    
    // Create a 1D matrix containing the three luma coefficients that
    // specify the color-to-grayscale conversion.
    let divisor: Int32 = 0x1000
    let fDivisor = Float(divisor)
    
    var coefficientsMatrix = [
      Int16(redCoefficient * fDivisor),
      Int16(greenCoefficient * fDivisor),
      Int16(blueCoefficient * fDivisor)
    ]
    
    // Use the matrix of coefficients to compute the scalar luminance by
    // returning the dot product of each RGB pixel and the coefficients
    // matrix.
    let preBias: [Int16] = [0, 0, 0, 0]
    let postBias: Int32 = 0
    
    vImageMatrixMultiply_ARGB8888ToPlanar8(&sourceBuffer,
                                           &destinationBuffer,
                                           &coefficientsMatrix,
                                           divisor,
                                           preBias,
                                           postBias,
                                           vImage_Flags(kvImageNoFlags))
    
    // Create a 1-channel, 8-bit grayscale format that's used to
    // generate a displayable image.
    guard let monoFormat = vImage_CGImageFormat(
      bitsPerComponent: 8,
      bitsPerPixel: 8,
      colorSpace: CGColorSpaceCreateDeviceGray(),
      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
      renderingIntent: .defaultIntent) else {
      return
    }
    
    // Create a Core Graphics image from the grayscale destination buffer.
    let result = try? destinationBuffer.createCGImage(format: monoFormat)
    
    // Display the grayscale result.
    if let result = result {
      monoImage = UIImage(cgImage: result)
    }
    
  }
  
}

