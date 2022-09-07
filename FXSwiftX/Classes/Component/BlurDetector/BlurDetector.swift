//
//  BlurDetector.swift
//  
//
//  Created by aria on 2022/9/2.
//
import AVFoundation
import Accelerate
import UIKit

// MARK: BlurDetector
@available(iOS 13.0, *)
public class BlurDetector: NSObject, BlurDetectorProtocol {
  
  
  private let laplacian: [Float] = [
    0, 1, 0,
    1, -4, 1,
    0, 1, 0
  ]
  
  public func processImage(sourceBuffer: vImage_Buffer, orientation: UInt32?) -> BlurDetectionResult? {
    let codeTime = CodeExecutionTime()
    codeTime.isPrint = false
    codeTime.prefix = "\(Int.random(in: 1...100))"
    
    var sourceBuffer = sourceBuffer
    let width: Int = Int(sourceBuffer.width)
    let height: Int = Int(sourceBuffer.height)
    var floatPixels: [Float]
    let count = width * height
    
    codeTime.printTime()
    
    // vDSP.integerToFloatingPoint耗时较长，使用else转换
    if sourceBuffer.rowBytes == width * MemoryLayout<Pixel_8>.stride && false {
      let start = sourceBuffer.data.assumingMemoryBound(to: Pixel_8.self)
      codeTime.printTime("1 - 1")
      floatPixels = vDSP.integerToFloatingPoint(
        UnsafeMutableBufferPointer(start: start,
                                   count: count),
        floatingPointType: Float.self)
      codeTime.printTime("if 2")
    } else {
      floatPixels = [Float](unsafeUninitializedCapacity: count) {
        buffer, initializedCount in
        var floatBuffer = vImage_Buffer(data: buffer.baseAddress,
                                        height: sourceBuffer.height,
                                        width: sourceBuffer.width,
                                        rowBytes: width * MemoryLayout<Float>.size)
        codeTime.printTime("1 - 1")
        
        vImageConvert_Planar8toPlanarF(&sourceBuffer,
                                       &floatBuffer,
                                       0, 255,
                                       vImage_Flags(kvImageNoFlags))
        
        initializedCount = count
      }
      codeTime.printTime("else 2")
    }
    
    // Convolve with Laplacian.
    vDSP.convolve(floatPixels,
                  rowCount: height,
                  columnCount: width,
                  with3x3Kernel: laplacian,
                  result: &floatPixels)
    
    // Calculate standard deviation.
    var mean = Float.nan
    var stdDev = Float.nan
    
    codeTime.printTime()
    
    
    vDSP_normalize(floatPixels, 1,
                   nil, 1,
                   &mean, &stdDev,
                   vDSP_Length(count))
    
    codeTime.printTime()
    
    let result = BlurDetectionResult(image: nil,
                                     laplacianImage: nil,
                                     score: stdDev * stdDev)
    
    codeTime.printTime()
    return result
  }
  
  public func processImage(data: UnsafeMutableRawPointer, rowBytes: Int, width: Int, height: Int, orientation: UInt32?) -> BlurDetectionResult? {
    let sourceBuffer = vImage_Buffer(data: data,
                                     height: vImagePixelCount(height),
                                     width: vImagePixelCount(width),
                                     rowBytes: rowBytes)
    return processImage(sourceBuffer: sourceBuffer, orientation: orientation)
  }
  
  
}

@available(iOS 13.0, *)
extension BlurDetector {
  /// Creates a grayscale `CGImage` from a array of pixel values, applying specified gamma.
  ///
  /// - Parameter pixels: The array of `UInt8` values representing the image data.
  /// - Parameter width: The image width.
  /// - Parameter height: The image height.
  /// - Parameter gamma: The gamma to apply.
  /// - Parameter orientation: The orientation of of the image.
  ///
  /// - Returns: A grayscale Core Graphics image.
  static func makeImage(fromPixels pixels: inout [Pixel_8],
                        width: Int,
                        height: Int,
                        gamma: Float,
                        orientation: CGImagePropertyOrientation) -> CGImage? {
    
    let alignmentAndRowBytes = try? vImage_Buffer.preferredAlignmentAndRowBytes(
      width: width,
      height: height,
      bitsPerPixel: 8)
    
    let image: CGImage? = pixels.withUnsafeMutableBufferPointer {
      var buffer = vImage_Buffer(data: $0.baseAddress!,
                                 height: vImagePixelCount(height),
                                 width: vImagePixelCount(width),
                                 rowBytes: alignmentAndRowBytes?.rowBytes ?? width)
      
      vImagePiecewiseGamma_Planar8(&buffer,
                                   &buffer,
                                   [1, 0, 0],
                                   gamma,
                                   [1, 0],
                                   0,
                                   vImage_Flags(kvImageNoFlags))
      
      return BlurDetector.makeImage(fromPlanarBuffer: buffer,
                                    orientation: orientation)
    }
    
    return image
  }
  
  /// Creates a grayscale `CGImage` from an 8-bit planar buffer.
  ///
  /// - Parameter sourceBuffer: The vImage containing the image data.
  /// - Parameter orientation: The orientation of of the image.
  ///
  /// - Returns: A grayscale Core Graphics image.
  static func makeImage(fromPlanarBuffer sourceBuffer: vImage_Buffer,
                        orientation: CGImagePropertyOrientation) -> CGImage? {
    
    guard  let monoFormat = vImage_CGImageFormat(bitsPerComponent: 8,
                                                 bitsPerPixel: 8,
                                                 colorSpace: CGColorSpaceCreateDeviceGray(),
                                                 bitmapInfo: []) else {
      return nil
    }
    
    var outputBuffer: vImage_Buffer
    var outputRotation: Int
    
    do {
      if orientation == .right || orientation == .left {
        outputBuffer = try vImage_Buffer(width: Int(sourceBuffer.height),
                                         height: Int(sourceBuffer.width),
                                         bitsPerPixel: 8)
        
        outputRotation = orientation == .right ?
        kRotate90DegreesClockwise : kRotate90DegreesCounterClockwise
      } else if orientation == .up || orientation == .down {
        outputBuffer = try vImage_Buffer(width: Int(sourceBuffer.width),
                                         height: Int(sourceBuffer.height),
                                         bitsPerPixel: 8)
        outputRotation = orientation == .down ?
        kRotate180DegreesClockwise : kRotate0DegreesClockwise
      } else {
        return nil
      }
    } catch {
      return nil
    }
    
    defer {
      outputBuffer.free()
    }
    
    var error = kvImageNoError
    
    withUnsafePointer(to: sourceBuffer) { src in
      error = vImageRotate90_Planar8(src,
                                     &outputBuffer,
                                     UInt8(outputRotation),
                                     0,
                                     vImage_Flags(kvImageNoFlags))
    }
    
    if error != kvImageNoError {
      return nil
    } else {
      return try? outputBuffer.createCGImage(format: monoFormat)
    }
  }
}



// Extensions to simplify conversion between orientation enums.
extension UIImage.Orientation {
  init(_ cgOrientation: CGImagePropertyOrientation) {
    switch cgOrientation {
    case .up:
      self = .up
    case .upMirrored:
      self = .upMirrored
    case .down:
      self = .down
    case .downMirrored:
      self = .downMirrored
    case .left:
      self = .left
    case .leftMirrored:
      self = .leftMirrored
    case .right:
      self = .right
    case .rightMirrored:
      self = .rightMirrored
    }
  }
}

extension AVCaptureVideoOrientation {
  init?(_ uiInterfaceOrientation: UIInterfaceOrientation) {
    switch uiInterfaceOrientation {
    case .unknown:
      return nil
    case .portrait:
      self = .portrait
    case .portraitUpsideDown:
      self = .portraitUpsideDown
    case .landscapeLeft:
      self = .landscapeLeft
    case .landscapeRight:
      self = .landscapeRight
    @unknown default:
      return nil
    }
  }
}
