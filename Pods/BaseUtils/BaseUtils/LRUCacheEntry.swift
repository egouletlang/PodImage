//
//  LRUCacheEntry.swift
//  BaseUtils
//
//  Created by Etienne Goulet-Lang on 12/4/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

open class LRUCacheEntry<K>: NSObject, NSCoding {
    
    public init(value: K, cost: Int) {
        self.value = value
        self.cost = cost
    }
    
    public required init(coder aDecoder: NSCoder) {
        cost = aDecoder.decodeInteger(forKey: "cost")
        value = aDecoder.decodeObject(forKey: "value") as! K
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(cost, forKey: "cost")
        aCoder.encode(value, forKey: "value")
    }
    
    
    open var value: K
    open var cost: Int
    
}
