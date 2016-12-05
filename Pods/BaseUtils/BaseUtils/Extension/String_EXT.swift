//
//  String_EXT.swift
//  bankroll
//
//  Created by Etienne Goulet-Lang on 6/29/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

public extension String {
    
    public func contains(_ text: String) -> Bool {
        return self.range(of: text) != nil
    }
    
    public func startsWith(_ text: String) -> Bool {
        return CFStringHasPrefix(self as CFString!, text as CFString!)
    }
    
    public func endsWith(_ text: String) -> Bool {
        return CFStringHasSuffix(self as CFString!, text as CFString!)
    }
}
