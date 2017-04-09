//
//  CGColor_EXT.swift
//  Bankroll
//
//  Created by Etienne Goulet-Lang on 5/25/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGColor {
    
    public func toRGB() -> UIColorRGB {
        let components = self.components
        let red = Int((components?[0])! * 255)
        let green = Int((components?[1])! * 255)
        let blue = Int((components?[2])! * 255)
        
        return Int64((red<<16) | (green<<8) | (blue))
    }
    
    public func toColorComponents() -> [CGFloat] {
        let components = self.components
        
        return [
            CGFloat(components![0]),
            CGFloat(components![1]),
            CGFloat(components![2]),
            CGFloat(components![3])
        ]
    }
    
    public func toRGBString(_ prefixWithHash: Bool = true) -> String {
        guard let components = self.components, components.count >= 3  else {
            return ""
        }
        
        var r = NSString(format: "%X", UInt((components[0]) * 255))
        var g = NSString(format: "%X", UInt((components[1]) * 255))
        var b = NSString(format: "%X", UInt((components[2]) * 255))
        
        if r.length == 1 {r = NSString(string: "0" + (r as String)) }
        if g.length == 1 {g = NSString(string: "0" + (g as String)) }
        if b.length == 1 {b = NSString(string: "0" + (b as String)) }
        
        return (prefixWithHash ? "#" : "") + (r as String) + (g as String) + (b as String)
    }
}
