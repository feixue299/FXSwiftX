//
//  ImagePickerManager.swift
//  LightMagic
//
//  Created by aria on 2025/5/14.
//

import Foundation
import Photos
import UIKit

@MainActor
open class ImagePickerManager: NSObject, ObservableObject {
    
    public enum AlbumType: Equatable {
        case all
        case selectAlbum(PHAssetCollection)
        case favorite
    }
    
    @Published
    public private(set) var assets: [PHAsset] = []
    public var imageAssets: [PHAsset] { assets.filter({ $0.mediaType == .image }) }
    @Published
    public private(set) var videoAssets: [PHAsset] = []
    
    var assetCover: [PHAsset: UIImage?] = [:]
    @Published
    public var selectAsset: Set<PHAsset> = []
    @Published
    var dragAssets: ArraySlice<PHAsset> = []
    
    @Published
    var timestamp: CFTimeInterval = 0
    private var displayLink: Timer?
    @Published
    var timeCache: [Int: Int] = [:]
    @Published
    public var albumType = AlbumType.all {
        didSet {
            guard oldValue != albumType else { return }
            updateAssets()
        }
    }
    @Published
    public private(set) var albums: [PHAssetCollection] = []
    private var allAlbumAsset: [PHAsset] = []
    private var albumAsset: [PHAssetCollection: [PHAsset]] = [:]
    private var favoriteAsset: [PHAsset] = []
    
    public func fetchAsset() {
        allAlbumAsset = AlbumModel.fetchAllAsset().reversed()
        
        albums = AlbumModel.fetchUserAlbums()
        for album in albums {
            let result = AlbumModel.fetchAssets(with: album)
            albumAsset[album] = result.objects(at: IndexSet(integersIn: 0..<result.count)).reversed()
        }
        favoriteAsset = AlbumModel.fetchAllAsset(subtype: .smartAlbumFavorites).reversed()
        
        updateAssets()
    }
    
    private func updateAssets() {
        switch albumType {
        case .all:
            assets = allAlbumAsset
            updateVideoAssets()
        case .selectAlbum(let album):
            assets = albumAsset[album] ?? []
            updateVideoAssets()
        case .favorite:
            assets = favoriteAsset
        }
    }
    
    private func updateVideoAssets() {
        videoAssets = assets.filter({ $0.mediaType == .video })
    }
    
    open func fetchCover(asset: PHAsset) async -> UIImage? {
        if let image = assetCover[asset] {
            return image
        } else {
            let image = await AlbumModel.requestImage(for: asset, targetSize: CGSize(sideLength: 200))
            assetCover[asset] = image
            return image
        }
    }
    
    func start() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.timestamp = Date().timeIntervalSince1970
                let key = Int(self.timestamp)
                self.timeCache[key] = (self.timeCache[key] ?? 0) + 1
                print("update self.timeCache:\(self.timeCache.sorted(by: { $0.key < $1.key }))")
            }
        }
        displayLink = timer
        displayLink?.fireDate = .distantPast
        displayLink?.fire()
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func fetchOriginData(asset: PHAsset) async -> AVURLAsset? {
        return await AlbumModel.requestOriginData(for: asset) as? AVURLAsset
    }
    
}

public extension ImagePickerManager {
    
    @discardableResult
    static func cropVideo(_ asset: AVAsset, to outputMovieURL: URL, startTime: CMTime, endTime: CMTime, composition: AVVideoComposition? = nil) async throws -> URL {
        
        //Create trim range
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        
        //delete any old file
        try? FileManager.default.removeItem(at: outputMovieURL)
        
        //create exporter
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else { throw NSError.client(description: "create exporter failed") }
        
        //configure exporter
        exporter.videoComposition = composition
        exporter.outputURL = outputMovieURL
        exporter.outputFileType = .mp4
        exporter.timeRange = timeRange
        
        //export!
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { c in
                exporter.exportAsynchronously(completionHandler: { [weak exporter] in
                    if let error = exporter?.error {
                        print("failed \(error.localizedDescription)")
                        c.resume(throwing: error)
                    } else {
                        print("Video saved to \(outputMovieURL)")
                        c.resume(returning: outputMovieURL)
                    }
                })
            }
        } onCancel: {
            exporter.cancelExport()
        }
    }
    
    static func assetDurationFormat(asset: PHAsset) -> String? {
        guard asset.mediaType == .video else { return nil }
        return String(format: "%02d:%02d", Int(asset.duration) / 60, Int(asset.duration) % 60)
    }
    
    static func fetchVideo(
        asset: PHAsset,
        maxDuration: Int? = nil,
        progressHandler: ((Double) -> Void)? = nil,
        startCropVideoHandler: (() async throws -> Void)? = nil
    ) async throws -> AVURLAsset? {
        
        guard let assetURL = await AlbumModel.requestOriginData(for: asset, configOptions: { options in
            options.deliveryMode = .highQualityFormat
            options.progressHandler = { (progress, error, stop, info) in
                progressHandler?(progress)
            }
        }) as? AVURLAsset else { return nil }
        
        if let maxDuration {
            let outputMovieURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
            
            return try await withCheckedThrowingContinuation { c in
                DispatchQueue.global().async {
                    Task {
                        do {
                            try await startCropVideoHandler?()
                            let asset = AVURLAsset(url: try await self.cropVideo(assetURL, to: outputMovieURL, startTime: .zero, endTime: CMTime(seconds: Double(maxDuration), preferredTimescale: assetURL.duration.timescale)))
                            c.resume(returning: asset)
                        } catch {
                            c.resume(throwing: error)
                        }
                    }
                }
            }
        } else {
            return assetURL
        }
        
    }
}
