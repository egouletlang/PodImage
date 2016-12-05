//
//  LRUCache.swift
//  BaseUtils
//
//  Created by Etienne Goulet-Lang on 12/4/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

open class LRUCache<T: Comparable & Hashable, K> {
    
    public init() {}
    
    private let recentKeys = LinkedList<T>()
    private var cache = [T: LRUCacheEntry<K>]()
    private var currentCost: Int = 0
    
    open var totalCostLimitMB = 100 * 1204 * 1024 {
        didSet {
            self.respectCostLimit()
        }
    }
    
    fileprivate func respectCostLimit() {
        var key: T!
        while (currentCost > totalCostLimitMB) {
            key = recentKeys.pop()
            currentCost -= cache.get(key)?.cost ?? 0
            cache.removeValue(forKey: key)
        }
    }
    
    open func get(objForKey key: T) -> LRUCacheEntry<K>? {
        recentKeys.addOrMove(value: key)
        return cache.get(key)
    }
    
    open func put(key: T, obj: LRUCacheEntry<K>) {
        currentCost += obj.cost
        
        recentKeys.addOrMove(value: key)
        cache[key] = obj
        
        self.respectCostLimit()
    }
    
    open func getCache() -> [T: LRUCacheEntry<K>] {
        return cache
    }
    
    open func setCache(cache: [T: LRUCacheEntry<K>]?) {
        if let c = cache {
            self.cache = c
            for (key, value) in self.cache {
                recentKeys.addOrMove(value: key)
                currentCost += value.cost
            }
        }
    }
}
