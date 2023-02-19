//
//  CMTime+Extensions.swift
//  
//
//  Created by aria on 2022/10/10.
//

import CoreMedia

public extension CMTime {
  var fps: CGFloat { CGFloat(timescale) / CGFloat(value) }
  var time: CGFloat { CMTimeGetSeconds(self) }
}
