//
//  Types.swift
//  BaseUtils
//
//  Created by Etienne Goulet-Lang on 12/4/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

open class Lock {
    
    public init() {}
    
    open func withLock(blk: ()->Void) {
        objc_sync_enter(self)
        blk()
        objc_sync_exit(self)
    }
}
