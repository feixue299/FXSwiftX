//
//  File.swift
//
//
//  Created by aria on 2023/4/6.
//

import Foundation
import AVKit
import Combine

#if os(iOS)
open class CaptureModel: NSObject {
    
    public enum ErrorType: Error {
        case noCamera
    }
    
    public enum CameraType: Codable, CaseIterable {
        /// 微距
        case microLens
        /// 广角
        case wideAngle
        /// 长焦
        case longFocus
        /// 三摄
        case tripleCamera
    }
    
    public private(set) static var opticalZoom: Int?
    
    @Published
    public private(set) var device: AVCaptureDevice?
    @Published
    public private(set) var session: AVCaptureSession?
    @Published
    public private(set) var cameraType: CameraType?
    @Published
    public private(set) var cameraPosition: AVCaptureDevice.Position = .back
    
    public private(set) var photoOutput = AVCapturePhotoOutput()
    public private(set) var videoOutput = AVCaptureMovieFileOutput()
    private var isRunning = true
    
    public override init() {
        super.init()
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification).sink { [weak self] _ in
            guard let self else { return }
            if self.isRunning {
                self.__stopRunning()
            }
        }.store(in: &observationBagRef.value)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).sink { [weak self] _ in
            guard let self else { return }
            if self.isRunning {
                self.__startRunning()
            }
        }.store(in: &observationBagRef.value)
        
        do {
            let devices = Self.availableCameraType()
            if Self.opticalZoom == nil, devices.contains(.longFocus) {
                
                var wideAngleFocalLength: CGFloat?
                var longFocusFocalLength: CGFloat?
                
                if devices.contains(.wideAngle) {
                    let device = try Self.getDeviceFromCamera(.wideAngle)
                    try selectFormat(device: device)
                    wideAngleFocalLength = CGFloat(getmmEquivalentFocalLength(format: device.activeFormat))
                }
                do {
                    let device = try Self.getDeviceFromCamera(.longFocus)
                    try selectFormat(device: device)
                    longFocusFocalLength = CGFloat(getmmEquivalentFocalLength(format: device.activeFormat))
                }
                if let wideAngleFocalLength, let longFocusFocalLength {
                    Self.opticalZoom = Int(round(longFocusFocalLength / wideAngleFocalLength))
                }
                
            }
        } catch {
            print("FocalLength error:\(error)")
        }
    }
    
    open class func requestAccess() async -> AVAuthorizationStatus {
        _ = await AVCaptureDevice.requestAccess(for: .video)
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    open func requestAccess() async -> AVAuthorizationStatus {
        await CaptureModel.requestAccess()
    }
    
    open func setupCamera(_ cameraType: CameraType = .wideAngle, position: AVCaptureDevice.Position = .back, format: ((AVCaptureDevice) throws -> ())? = nil) throws {
        let device = try Self.getDeviceFromCamera(cameraType, position: position)
        try setupDevice(device)
        let session = try getSession(device: device, format: format)
        
        self.cameraType = cameraType
        self.cameraPosition = position
        self.device = device
        self.session = session
    }
    
    open func changeCamera(_ cameraType: CameraType, position: AVCaptureDevice.Position = .back, format: ((AVCaptureDevice) throws -> ())? = nil) throws {
        guard (cameraType != self.cameraType || position != self.cameraPosition) else { return }
        print("changeCamera:\(cameraType)")
        let device = try Self.getDeviceFromCamera(cameraType, position: position)
        try setupDevice(device)
        
        if let session {
            session.beginConfiguration()
            
            if let format {
                try format(device)
            } else {
                try selectFormat(device: device)
            }
            
            let deviceInput = try AVCaptureDeviceInput(device: device)
            
            // 移除当前输入设备
            for input in session.inputs {
                session.removeInput(input)
            }
            
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            } else {
                throw NSError(domain: Bundle.main.bundleIdentifier ?? "", code: -1)
            }
            
            session.commitConfiguration()
        }
        
        self.cameraType = cameraType
        self.cameraPosition = position
        self.device = device
    }
    
    private func setupDevice(_ device: AVCaptureDevice) throws {
        
        try device.lockForConfiguration()
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        
        device.unlockForConfiguration()
        
    }
    
    private func getmmEquivalentFocalLength(format : AVCaptureDevice.Format) -> Float {
        // get reported field of view. Documentation says this is the horizontal field of view
        var fov = format.videoFieldOfView
        // convert to radians
        fov *= Float.pi/180.0
        // angle and opposite of right angle triangle are half the fov and half the width of
        // 35mm film (ie 18mm). The adjacent value of the right angle triangle is the equivalent
        // focal length. Using some right angle triangle math you can work out focal length
        let focalLen = 18 / tan(fov/2)
        return focalLen
    }
    
    private func getSession(device: AVCaptureDevice, format: ((AVCaptureDevice) throws -> ())? = nil) throws -> AVCaptureSession {
        let session = AVCaptureSession()
        
        session.beginConfiguration()
        
        let input = try AVCaptureDeviceInput(device: device)
        
        if session.canAddInput(input) {
            session.addInput(input)
        } else {
            throw NSError(domain: Bundle.main.bundleIdentifier ?? "", code: -1)
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        } else {
            throw NSError(domain: Bundle.main.bundleIdentifier ?? "", code: -2)
        }
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        } else {
            throw NSError(domain: Bundle.main.bundleIdentifier ?? "", code: -2)
        }
        
        if let format {
            try format(device)
        } else {
            try selectFormat(device: device)
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            session.startRunning()
        }
        
        return session
    }
    
    open class func getDeviceFromCamera(_ cameraType: CameraType, position: AVCaptureDevice.Position = .back) throws -> AVCaptureDevice {
        var device: AVCaptureDevice?
        switch cameraType {
        case .microLens:
            let devices = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInUltraWideCamera],
                mediaType: .video,
                position: position
            ).devices
            device = devices.first
        case .wideAngle:
            //      let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices
            
            device = AVCaptureDevice.default(for: .video)
            //      print("wideAngle devices:\(devices), device:\(String(describing: device))")
        case .longFocus:
            let devices = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInTelephotoCamera],
                mediaType: .video,
                position: position
            ).devices
            device = devices.first
        case .tripleCamera:
            let devices = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInTripleCamera, .builtInDualWideCamera, .builtInDualCamera, .builtInWideAngleCamera],
                mediaType: .video,
                position: position
            ).devices
            print("devices:\(devices)")
            device = devices.first
        }
        guard let device else { throw ErrorType.noCamera }
        return device
    }
    
    open func startRunning() {
        isRunning = true
        __startRunning()
    }
    
    open func stopRunning() {
        isRunning = false
        __stopRunning()
    }
    
    private func __startRunning() {
        DispatchQueue.global().async {
            if self.session?.isRunning == false {
                self.session?.startRunning()
            }
        }
    }
    
    private func __stopRunning() {
        DispatchQueue.global().async {
            if self.session?.isRunning == true {
                self.session?.stopRunning()
            }
        }
    }
    
    open func selectFormat(device: AVCaptureDevice) throws { }
    
}

public extension CaptureModel {
    
    class func availableCameraType() -> [CameraType] {
        CameraType.allCases.filter({ (try? getDeviceFromCamera($0)) != nil  }).compactMap({ $0 })
    }
    
}

#endif
