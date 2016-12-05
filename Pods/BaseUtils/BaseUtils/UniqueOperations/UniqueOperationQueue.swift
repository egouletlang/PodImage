//
//  UniqueOperationQueue.swift
//  Shared
//
//  Created by Etienne Goulet-Lang on 1/14/16.
//  Copyright © 2016 Heine Frifeldt. All rights reserved.
//

import Foundation

/// This queue was designed to better manage image resource requests. NSOperations running are unique, multiple callbacks
/// can be associated with an NSOperation, based on a unique key.
open class UniqueOperationQueue<T>: OperationQueue, UniqueOperationDelegate {
    
    public typealias UniqueOperationQueueCompletionBlock = (T?) -> Void
    
    public convenience init(name: String, concurrentCount: Int) {
        self.init()
        self.name = name
        self.maxConcurrentOperationCount = concurrentCount
    }
    
    private var callbackMap = [String: [UniqueOperationQueueCompletionBlock]]()
    private var lock = Lock()
    
    
    open func addOperation(op: UniqueOperation, callback: @escaping (T?)->Void) {
        var startOperation = false
        lock.withLock { () -> () in
            if let id = op.getUniqueId() {
                if self.callbackMap[id] != nil {
                    self.callbackMap[id]?.append(callback)
                } else {
                    self.callbackMap[id] = [callback]
                    startOperation = true
                }
            }
        }
        
        if startOperation {
            op.delegate = self
            super.addOperation(op)
        }
        
    }
    
    
    // MARK: - UniqueOperationDelegate Methods -
    open func complete(id: String?, result: AnyObject?) {
        
        var operationCallbacks = [UniqueOperationQueueCompletionBlock]()
        lock.withLock { () -> () in
            if  let i = id,
                let callbacks = self.callbackMap[i] {
                    operationCallbacks = callbacks
                    self.callbackMap.removeValue(forKey: i)
            }
        }
        
        // Handle the callbacks
        let res = result as? T
        for callback in operationCallbacks {
            ThreadHelper.executeOnBackgroundThread() {
                callback(res)
            }
        }
    }
    
}
