//
//  AVPlayer+Extensions.swift
//  FXSwiftX
//
//  Created by aria on 2023/2/17.
//

import Foundation
import AVFoundation
import Combine

@available(iOS 13.0, *)
public extension AVPlayer {
    func periodicTimePublisher(for interval: CMTime, queue: DispatchQueue?) -> some Publisher<CMTime, Never> {
        Publishers.makePublisher { [weak self] subject in
            guard let self else {
                return AnyCancellable { }
            }
            let observer = self.addPeriodicTimeObserver(forInterval: interval, queue: queue) { time in
                subject.send(time)
            }
            return AnyCancellable { [weak self] in
                self?.removeTimeObserver(observer)
            }
        }
    }
}
