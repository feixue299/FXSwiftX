//
//  BlurDetectorCapture.swift
//
//
//  Created by aria on 2022/9/2.
//

#if os(iOS)
import Foundation
import AVFoundation
import Accelerate
import UIKit

// MARK: BlurDetectorResultsDelegate protcol

protocol BlurDetectorResultsDelegate: AnyObject {
    func itemProcessed(_ item: BlurDetectionResult)
    func finishedProcessing()
}



@available(iOS 13.0, *)
public class BlurDetectorCapture: NSObject {
    private var processedCount = 0
    
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    weak var resultsDelegate: BlurDetectorResultsDelegate?
    public let blurDetectorProtocol: BlurDetectorProtocol
    
    public init(blurDetectorProtocol: BlurDetectorProtocol) {
        self.blurDetectorProtocol = blurDetectorProtocol
        super.init()
    }
    
    func configure() {
        let interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        let sessionQueue = DispatchQueue(label: "session queue")
        
        sessionQueue.async {
            self.configureSession(interfaceOrientation: interfaceOrientation,
                                  sessionQueue: sessionQueue)
        }
    }
    
    private func configureSession(interfaceOrientation: UIInterfaceOrientation?, sessionQueue: DispatchQueue) {
        captureSession.beginConfiguration()
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        captureSession.sessionPreset = .hd1280x720
        
        if
            let interfaceOrientation = interfaceOrientation,
            let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation) {
            photoOutput.connections.forEach {
                $0.videoOrientation = videoOrientation
            }
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    fatalError("App requires camera access.")
                }
                sessionQueue.resume()
                return
            })
        default:
            fatalError("App requires camera access.")
        }
        
        guard
            let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                      for: .video,
                                                      position: .back),
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            fatalError("Can't create camera.")
        }
        
        if captureSession.canAddInput(videoDeviceInput) {
            captureSession.addInput(videoDeviceInput)
        }
        
        captureSession.commitConfiguration()
        
        captureSession.startRunning()
    }
    
    func takePhoto() {
        let pixelFormat: FourCharCode = {
            if photoOutput.availablePhotoPixelFormatTypes
                .contains(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
                return kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            } else if photoOutput.availablePhotoPixelFormatTypes
                .contains(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
                return kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
            } else {
                fatalError("No available YpCbCr formats.")
            }
        }()
        
        let exposureSettings = (0..<photoOutput.maxBracketedCapturePhotoCount).map { _ in
            AVCaptureAutoExposureBracketedStillImageSettings.autoExposureSettings(
                exposureTargetBias: AVCaptureDevice.currentExposureTargetBias)
        }
        
        let photoSettings = AVCapturePhotoBracketSettings(
            rawPixelFormatType: 0,
            processedFormat: [kCVPixelBufferPixelFormatTypeKey as String: pixelFormat],
            bracketedSettings: exposureSettings)
        
        processedCount = 0
        
        photoOutput.capturePhoto(with: photoSettings,
                                 delegate: self)
    }
}

// MARK: BlurDetector AVCapturePhotoCaptureDelegate extension

@available(iOS 13.0, *)
extension BlurDetectorCapture: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput,
                            didFinishProcessingPhoto photo: AVCapturePhoto,
                            error: Error?) {
        print("didFinishProcessingPhoto")
        if let error = error {
            fatalError("Error capturing photo: \(error).")
        }
        
        guard let pixelBuffer = photo.pixelBuffer else {
            fatalError("Error acquiring pixel buffer.")
        }
        
        blurDetectorProtocol.handleImage(photo: photo, pixelBuffer: pixelBuffer) { result in
            if let result = result {
                self.processedCount += 1
                self.resultsDelegate?.itemProcessed(result)
                
                if self.processedCount == photo.resolvedSettings.expectedPhotoCount {
                    self.resultsDelegate?.finishedProcessing()
                }
            }
        }
    }
    
}
#endif
