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
    private var needResumePlay = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(playerLayer)
        playerLayer.videoGravity = .resizeAspectFill
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).sink { [weak self] _ in
            guard let self else { return }
            if self.needResumePlay {
                self.needResumePlay = false
                self.playerManager?.play()
            }
        }.dispose(by: bag)
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification).sink { [weak self] _ in
            guard let self, let playerManager = self.playerManager else { return }
            if playerManager.isPlaying {
                self.needResumePlay = true
                playerManager.pause()
            }
        }.dispose(by: bag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
}
