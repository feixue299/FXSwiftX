//
//  BlurDetectorProtocol.swift
//  
//
//  Created by aria on 2022/9/2.
//

import Foundation
import CoreGraphics
import AVFoundation
import Accelerate

// MARK: BlurDetectionResult

public struct BlurDetectionResult {
  public var index: Int = 0
  public var imageData: Data?
  public let image: CGImage?
  public let laplacianImage: CGImage?
  public let score: Float
}

public class PixelInfo {
  
  let data: UnsafeMutableRawPointer
  let rowBytes: Int
  let width: Int
  let height: Int
  let orientation: UInt32?
  
  init(data: UnsafeMutableRawPointer, rowBytes: Int, width: Int, height: Int, orientation: UInt32?) {
    self.data = data
    self.rowBytes = rowBytes
    self.width = width
    self.height = height
    self.orientation = orientation
  }
  
  deinit {
    data.deallocate()
  }
}

public protocol BlurDetectorProtocol {
  
  func processImage(data: UnsafeMutableRawPointer,
                    rowBytes: Int,
                    width: Int,
                    height: Int,
                    orientation: UInt32?) -> BlurDetectionResult?
  
  func processImage(sourceBuffer: vImage_Buffer,
                    orientation: UInt32?) -> BlurDetectionResult?
}

public extension BlurDetectorProtocol {
  func getPixelInfo(orientation: UInt32?, pixelBuffer: CVPixelBuffer) -> PixelInfo {
    CVPixelBufferLockBaseAddress(pixelBuffer,
                                 CVPixelBufferLockFlags.readOnly)
    
    let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
    let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
    let count = width * height
    
    let lumaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
    let lumaRowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
    
    let lumaCopy = UnsafeMutableRawPointer.allocate(byteCount: count,
                                                    alignment: MemoryLayout<Pixel_8>.alignment)
    lumaCopy.copyMemory(from: lumaBaseAddress!,
                        byteCount: count)
    
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer,
                                   CVPixelBufferLockFlags.readOnly)
    return .init(
      data: lumaCopy,
      rowBytes: lumaRowBytes,
      width: width,
      height: height,
      orientation: orientation)
  }
  
  func handleImage(photo: AVCapturePhoto, pixelBuffer: CVPixelBuffer, completion: ((BlurDetectionResult?) -> Void)?) {
    handleImage(orientation: photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32, pixelBuffer: pixelBuffer) { result in
      var result = result
      result?.index = photo.sequenceCount
      completion?(result)
    }
  }
  
  func handleImage(orientation: UInt32?, pixelBuffer: CVPixelBuffer, completion: ((BlurDetectionResult?) -> Void)?) {
    let pixelInfo = getPixelInfo(orientation: orientation, pixelBuffer: pixelBuffer)
    
    DispatchQueue.global(qos: .utility).async {
      let result = self.processImage(
        data: pixelInfo.data,
        rowBytes: pixelInfo.rowBytes,
        width: pixelInfo.width,
        height: pixelInfo.height,
        orientation: pixelInfo.orientation)
      
      if let result = result {
        DispatchQueue.main.async {
          completion?(result)
        }
      } else {
        completion?(nil)
      }
    }
    
  }
  
  func handleImage(sourceBuffer: vImage_Buffer, orientation: UInt32?, completion: ((BlurDetectionResult?) -> Void)?) {
    DispatchQueue.global(qos: .utility).async {
      let result = self.processImage(sourceBuffer: sourceBuffer, orientation: orientation)
      if let result = result {
        DispatchQueue.main.async {
          completion?(result)
        }
      } else {
        completion?(nil)
      }
    }
  }
}
