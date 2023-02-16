//
//  PlayerView.swift
//  
//
//  Created by aria on 2022/11/2.
//

import UIKit
import AVKit

@available(iOS 13.0, *)
public class PlayerView: UIView {
    
    public let playerLayer = AVPlayerLayer()
    public var playerManager: PlayerManager? {
        didSet {
            playerLayer.player = playerManager?.player
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(playerLayer)
        playerLayer.videoGravity = .resizeAspectFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
}
