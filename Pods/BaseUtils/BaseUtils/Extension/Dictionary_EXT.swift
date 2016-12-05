//
//  Dictionary_EXT.swift
//  bankroll
//
//  Created by Etienne Goulet-Lang on 7/4/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

public extension Dictionary {
    
    
    /// Returns the element or nil if the index was out of bounds
    /// NOTICE, if T is a nill-able element (like String?) that the return will be double nillable. Not sure how to deal with that
    public func get(_ key: Key) -> Value? {
        if let v = self[key] {
            return v
        }
        return nil
    }
    
    public func get(_ key: Key,_ def: Value?) -> Value? {
        if let v = self[key] {
            return v
        }
        return def
    }
}
