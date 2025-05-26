//
//  AlbumModel.swift
//  LightMagic
//
//  Created by aria on 2025/5/14.
//

import Photos
import UIKit

open class AlbumModel {
    
    open class func requestAccess() async -> PHAuthorizationStatus {
        await withCheckedContinuation { c in
            PHPhotoLibrary.requestAuthorization { status in
                c.resume(returning: status)
            }
        }
    }
    
    open class func authorizationStatus() -> PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    open func requestAccess() async -> PHAuthorizationStatus {
        await AlbumModel.requestAccess()
    }
    
    open class func fetchAllAsset(assetMediaType: PHAssetMediaType? = nil, subtype: PHAssetCollectionSubtype = .smartAlbumUserLibrary) -> [PHAsset] {
        
        // 获取所有相册
        let allAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtype, options: nil)
        
        var dataSource: [PHAsset] = []
        
        for i in 0..<allAlbums.count {
            let album = allAlbums[i]
            let assets = fetchAssets(with: album, assetMediaType: assetMediaType)
            
            dataSource.append(contentsOf: Array(_immutableCocoaArray: assets))
        }
        
        return dataSource
    }
    
    open class func fetchUserAlbums() -> [PHAssetCollection] {
        var allAlbums: [PHAssetCollection] = []
        // 获取所有用户创建的相簿
        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .any,
            options: nil
        )
        let userAlbums = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .any,
            options: nil
        )
        
        for i in 0..<smartAlbums.count {
            let album = smartAlbums[i]
            allAlbums.append(album)
        }
        
        for i in 0..<userAlbums.count {
            let album = userAlbums[i]
            allAlbums.append(album)
        }
        
        return allAlbums
    }
    
    public static func fetchAssets(with album: PHAssetCollection, assetMediaType: PHAssetMediaType? = nil) -> PHFetchResult<PHAsset> {
        let fetchOptions = PHFetchOptions()
        if let assetMediaType {
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", assetMediaType.rawValue)
        }
        
        let assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
        
        return assets
    }
    
    public static func requestImage(for asset: PHAsset, targetSize: CGSize = CGSize(width: 100, height: 100)) async -> UIImage? {
        // 设置请求选项
        let options = PHImageRequestOptions()
        //    options.deliveryMode = .fastFormat
        
        // 使用 PHImageManager 请求封面图
        return await withCheckedContinuation { c in
            var isFisrt = true
            PHCachingImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, info) in
                //        print("image:\(String(describing: image)), info:\(String(describing: info))")
                let resultIsDegraded = info?[PHImageResultIsDegradedKey] as? Int
                
                if isFisrt, (resultIsDegraded.map { $0 == 0 } ?? true) {
                    c.resume(returning: image)
                    isFisrt = false
                }
            }
            
        }
    }
    
    open class func requestOriginData(for asset: PHAsset, configOptions: ((PHVideoRequestOptions) -> ())? = nil) async -> AVAsset? {
        if asset.mediaType == .video {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            configOptions?(options)
            
            return await withCheckedContinuation { c in
                var isFisrt = true
                PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: options) { asset, audioMix, info in
                    print("asset:\(String(describing: asset)), audioMix:\(String(describing: audioMix)), info:\(String(describing: info))")
                    if isFisrt {
                        c.resume(returning: asset)
                        isFisrt = false
                    }
                }
            }
        } else {
            return nil
        }
    }
    
}
