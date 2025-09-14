//
//  LUT3D.swift
//  FXSwiftX
//
//  Created by aria on 2025/9/8.
//

import Foundation

public struct LUT3D {
    public let size: Int
    public let data: [Float]
    
    public init(size: Int, data: [Float]) {
        self.size = size
        self.data = data
    }
    
    public init(url: URL) throws {
        let content = try String(contentsOf: url, encoding: .utf8)
        var size = 0
        var values: [Float] = []
        
        for line in content.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            
            if trimmed.uppercased().hasPrefix("LUT_3D_SIZE") {
                let parts = trimmed.split(separator: " ")
                if let num = Int(parts.last!) {
                    size = num
                }
            } else {
                let comps = trimmed.split(separator: " ")
                if comps.count >= 3 {
                    if let r = Float(comps[0]),
                       let g = Float(comps[1]),
                       let b = Float(comps[2]) {
                        values.append(contentsOf: [r, g, b, 1.0]) // RGBA
                    }
                }
            }
        }
        
        self.init(size: size, data: values)
    }
}
