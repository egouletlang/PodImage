//
//  UniqueOperation.swift
//  Shared
//
//  Created by Etienne Goulet-Lang on 1/14/16.
//  Copyright © 2016 Heine Frifeldt. All rights reserved.
//

import Foundation


private let COUNT_MAX = 300
private let SLEEP_TIME: TimeInterval = 0.1

/// The UniqueOperation expects its operations to depend on other threads -- that may run asynchronously. These operations
/// once started must be explicitly stopped by calling the deactive(...) method. The delegate is called with the result
/// arguement.
///
/// The 'COUNT_MAX' and 'SLEEP_TIME' are part of a fail-safe mechanism to prevent any child Operation
/// from blocking a queue, if the thread is left active for any reason.
///
/// - Usage: Override the run method and call 'deactivate(...)' when you're done.
open class UniqueOperation: Operation {
    open func getUniqueId() -> String? {
        return nil
    }
    
    open weak var delegate: UniqueOperationDelegate?
    
    open var operationActive = false
    
    // Helper methods to start and end the operation.
    open func activate() {
        self.operationActive = true
    }
    open func deactivate(result: AnyObject?) {
        self.operationActive = false
        self.delegate?.complete(id: getUniqueId(), result: result)
    }
    
    /// Helper that will clean up the operation, when either
    ///
    /// - deactivate(...) is called
    ///
    /// - the TTL (COUNT_MAX * SLEEP_TIME) is exceeded.
    ///
    /// Note -- if TTL is exceeded, the operation is NOT cancelled.  If you do not override run(...), this method will be
    /// called automatically.
    open func waitForDeactivate() {
        var count = 0
        while (operationActive && count < COUNT_MAX) {
            Thread.sleep(forTimeInterval: SLEEP_TIME)
            count += 1
        }
    }
    
    /// Override me and treat as main(...)
    open func run() {
        deactivate(result: nil)
    }
    
    override open func main() {
        self.activate()
        self.run()
        self.waitForDeactivate()
    }
    
    
}
