//
//  Common.swift
//
//
//  Created by aria on 2024/7/7.
//

import Foundation

#if os(iOS)
import UIKit
public typealias FXImage = UIImage
#elseif os(macOS)
import Cocoa
public typealias FXImage = NSImage
#endif
