//
//  PlayerManager.swift
//  
//
//  Created by aria on 2022/11/2.
//

import Foundation
import AVKit
import Combine

@available(iOS 13.0, *)
public class PlayerManager: NSObject {
    public enum PlayStatus {
        case none
        /// 区间循环
        case runloopRange(range: ClosedRange<Double>)
        /// 从start到结束循环
        case runloopWithStart(start: Double)
        /// 从开始到end循环
        case runloopToEnd(end: Double)
        /// 取帧到time
        case seek(time: Double)
        /// 播放到第几秒然后暂停
        case playTo(time: Double)
        /// 循环
        case runloop
    }
    
    private var duration: CMTime? { player.currentItem?.duration }
    public var player: AVPlayer { return queuePlayer }
    private let url: URL
    private let queuePlayer: AVQueuePlayer
    public let isAutoPlay: Bool
    private var needPlay = false
    public var playStatus: PlayStatus = .none {
        didSet {
            updatePlayStatus()
        }
    }
    private var looper: AVPlayerLooper?
    public var playToClosure: (() -> Void)?
    public var updateStatus: Bool = true
    
    public init(url: URL, isAutoPlay: Bool = false) {
        self.url = url
        queuePlayer = AVQueuePlayer(url: url)
        self.isAutoPlay = isAutoPlay
        super.init()
        observePlayer(player)
    }
    
    private func observePlayer(_ player: AVPlayer) {
        bagRef.value.removeAll()
        player.observe(\.status, changeHandler: { [weak self] player, _ in
            guard let self else { return }
            switch player.status {
            case .unknown:
                print("视频加载遇到未知问题:AVPlayerStatusUnknown")
            case .readyToPlay:
                if self.isAutoPlay || self.needPlay {
                    self.play()
                }
            case .failed:
                print("视频加载失败")
            @unknown default:
                break
            }
        }).disposeBy(bag: bagRef)
        
        player.periodicTimePublisher(for: CMTime(value: 1, timescale: 10), queue: .main).sink { [weak self] time in
            guard let self, self.updateStatus else { return }
            self.updatePlayStatus()
        }.store(in: &observationBagRef.value)
    }
    
    public func play() {
        if player.status == .readyToPlay {
            needPlay = false
            if updatePlayStatus() {
                player.play()
            }
        } else {
            needPlay = true
        }
    }
    
    public func pause() {
        if player.status == .readyToPlay {
            if player.rate != 0 {
                player.pause()
            }
        } else {
            needPlay = false
        }
    }
    
    @discardableResult
    private func updatePlayStatus() -> Bool {
        let currentTime = player.currentTime().time
        guard let totalTime = duration?.time else { return true }
        switch playStatus {
        case .runloop:
            break
        default:
            looper = nil
        }
        
        switch playStatus {
        case .none:
            return true
        case .runloopRange(let range):
            if currentTime < range.lowerBound {
                seekToTime(range.lowerBound)
            } else if currentTime > range.upperBound {
                seekToTime(range.lowerBound)
            } else if currentTime > totalTime {
                seekToTime(range.lowerBound)
            }
            return true
        case .runloopWithStart(let start):
            if currentTime < start {
                seekToTime(start)
            } else if currentTime > totalTime {
                seekToTime(start)
            }
            return true
        case .runloopToEnd(let end):
            if currentTime > end {
                seekToTime(0)
            } else if currentTime > totalTime {
                seekToTime(0)
            }
            return true
        case .seek(let time):
            seekToTime(time)
            return true
        case .playTo(let time):
            if currentTime >= time {
                /*
                 息屏之后视频会跳到整数秒的帧，目前不知道为什么，所以强制seek到对应的帧
                 */
                seekToTime(time)
                
                pause()
                playToClosure?()
                return false
            } else {
                return true
            }
        case .runloop:
            if looper == nil {
                looper = AVPlayerLooper(player: queuePlayer, templateItem: AVPlayerItem(url: url))
            }
            return true
        }
    }
    
    private func seekToTime(_ time: CGFloat) {
        Task {
            let currentTime = player.currentTime()
            let cmTime = CMTime(value: CMTimeValue(time * CGFloat(currentTime.timescale)), timescale: currentTime.timescale)
            await player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }
    
}
