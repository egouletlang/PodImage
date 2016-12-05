//
//  LRUCacheEntry.swift
//  BaseUtils
//
//  Created by Etienne Goulet-Lang on 12/4/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

open class LRUCacheEntry<K> {
    
    public init(value: K, cost: Int) {
        self.value = value
        self.cost = cost
    }
    
    open var value: K
    open var cost: Int
    
}
