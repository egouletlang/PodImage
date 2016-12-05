//
//  UIColor_EXT.swift
//  Bankroll
//
//  Created by Etienne Goulet-Lang on 5/25/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation
import UIKit

/// Represents RGB color values (0xRRGGBB)
public typealias UIColorRGB = Int64

public extension UIColor {
    
    public convenience init(rgb: Int64) {
        if rgb > 0xFFFFFF { // there is some alpha component
            self.init(argb: rgb)
        } else {
            let red = CGFloat((rgb>>16)&0xFF) / 255
            let green = CGFloat((rgb>>8)&0xFF) / 255
            let blue = CGFloat(rgb&0xFF) / 255
            self.init(red: red, green: green, blue: blue, alpha: 1)
        }
    }
    
    public convenience init(argb: Int64) {
        if argb <= 0xFFFFFF {
            self.init(rgb: argb)
        } else {
            let alpha = CGFloat((argb>>24)&0xFF) / 255
            let red = CGFloat((argb>>16)&0xFF) / 255
            let green = CGFloat((argb>>8)&0xFF) / 255
            let blue = CGFloat(argb&0xFF) / 255
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    
    public convenience init?(hexString: String) {
        var r, g, b, a: CGFloat
        
        let scrubbedStr = hexString
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "0x", with: "").uppercased()
        
        
        let scanner = Scanner(string: scrubbedStr)
        var hexNumber: UInt64 = 0
        
        
        if scanner.scanHexInt64(&hexNumber) {
            a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            b = CGFloat(hexNumber & 0x000000ff) / 255
            
            if (scrubbedStr as NSString).length == 6 {
                a = 1
            }
            self.init(red: r, green: g, blue: b, alpha: a)
            return
        }
        
        return nil
    }
    
    public func toColorComponents() -> [CGFloat] {
        return self.cgColor.toColorComponents()
    }
    
    public func toRGB() -> UIColorRGB {
        return self.cgColor.toRGB()
    }
    
    public func toRGBString(_ prefixWithHash: Bool = true) -> String {
        return self.cgColor.toRGBString(prefixWithHash)
    }
    
}
