//
//  PHAsset+Extensions.swift
//  FXSwiftX
//
//  Created by aria on 2025/6/1.
//

import Photos

public extension PHAsset {
    
    var isLivePhoto: Bool {
        mediaSubtypes.contains(.photoLive)
    }
    
    var isGIF: Bool {
        let resources = PHAssetResource.assetResources(for: self)
        return resources.contains { resource in
            resource.uniformTypeIdentifier == "com.compuserve.gif"
            || resource.uniformTypeIdentifier == "public.gif"
        }
    }
}
