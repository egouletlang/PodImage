//
//  ThreadHelper.swift
//  Bankroll
//
//  Created by Etienne Goulet-Lang on 5/25/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

public class ThreadHelper {
    
    public class func executeOnMainThread(block: @escaping ()->Void) {
        DispatchQueue.main.async {
            block()
            return
        }
    }
    public class func executeOnBackgroundThread(block: @escaping ()->Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            block()
        }
    }
    
    /// Checks state of current thread. If foreground schedules block to be executed on background.
    /// If thread is not foreground, executes block on current thread
    public class func checkedExecuteOnBackgroundThread(block: @escaping ()->Void) {
        if !Thread.isMainThread {
            block()
        } else {
            executeOnBackgroundThread(block: block)
        }
    }
    
    public class func checkedExecuteOnMainThread(block: @escaping ()->Void) {
        if Thread.isMainThread {
            block()
        } else {
            executeOnMainThread(block: block)
        }
    }
    
    
    public class func delay(sec: Double, mainThread: Bool, block: @escaping ()->Void) {
        
        let delay = createDispatchTime(sec)
        
        if mainThread {
            DispatchQueue.main.asyncAfter(deadline: delay, execute: block)
        } else {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).asyncAfter(deadline: delay, execute: block)
        }
    }
    
    /// Creates a dispatch_time based on number of seconds after "now"
    fileprivate class func createDispatchTime(_ seconds: Double) -> DispatchTime {
        return DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    }
    
}
