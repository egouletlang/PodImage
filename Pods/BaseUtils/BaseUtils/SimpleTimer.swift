//
//  Timer.swift
//  BaseUtils
//
//  Created by Etienne Goulet-Lang on 2/23/17.
//  Copyright © 2017 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

open class SimpleTimer<T>: NSObject {
    open var fire: ((T?)->Void)?
    
    private var timer: Timer?
    private var selector: Selector!
    private var delay: TimeInterval!
    private var touch: UITouch!
    private var value: T?
    
    
    public init(delay: TimeInterval) {
        self.delay = delay
    }
    
    open func start(value: T?) {
        self.stop()
        self.value = value
        timer = Timer.scheduledTimer(timeInterval: self.delay, target: self, selector: #selector(SimpleTimer.timerFired), userInfo: nil, repeats: false)
    }
    open func stop() {
        timer?.invalidate()
    }
    
    open func timerFired() {
        self.fire?(self.value)
    }
}
