//
//  Array_EXT.swift
//  bankroll
//
//  Created by Etienne Goulet-Lang on 7/3/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

public extension Array {
    
    public func foreach(_ block: (Element)->()) {
        for item in self {
            block(item)
        }
    }
    
    /// Returns the element or nil if the index was out of bounds
    /// NOTICE, if T is a nill-able element (like String?) that the return will be double nillable. Not sure how to deal with that
    public func get(_ index: Int) -> Element? {
        if self.count > index && index >= 0 {
            return self[index]
        } else {
            return nil
        }
    }
}
