//
//  AsyncToSync.swift
//  BaseUtils
//
//  Created by Etienne Goulet-Lang on 12/9/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

open class AsyncToSync<T> {
    
    private let SLEEP_TIME: TimeInterval = 0.1
    
    public init(timeout: TimeInterval = 5) {
        self.timeout = timeout
    }
    
    private var timeout: TimeInterval = 5
    private var isResultReady = false
    open var result: T? {
        didSet {
            self.isResultReady = true
        }
    }
    
    open func start(block: @escaping (AsyncToSync<T>)->Void) -> T? {
        ThreadHelper.checkedExecuteOnBackgroundThread {
            block(self)
        }
        
        var timeSlept: TimeInterval = 0
        while (!isResultReady && timeSlept < timeout) {
            Thread.sleep(forTimeInterval: SLEEP_TIME)
            timeSlept += SLEEP_TIME
        }
        
        return result
    }
    
    
    
}
