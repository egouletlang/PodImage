//
//  BaseState.swift
//  BaseUtils
//
//  Created by Etienne Goulet-Lang on 2/25/17.
//  Copyright © 2017 Etienne Goulet-Lang. All rights reserved.
//

import Foundation


open class BaseState {
    
    private var userDefaults: UserDefaults?
    
    public init() {
        userDefaults = UserDefaults(suiteName: getFiletName())
        if !(userDefaults?.synchronize() ?? false) {
            print("NSUserDefaults failed to synchronize content")
        }
        
    }
    
    open func getFiletName() -> String {
        return "BASE-STATE"
    }
    
    //MARK: - Boolean -
    private let NO_VALUE = 0
    private let TRUE_VALUE = 1
    private let FALSE_VALUE = 2
    open func getValue(key: String,_ def: Bool) -> Bool {
        let val = getValue(key: key, NO_VALUE)
        if val == NO_VALUE { return def }
        return val == TRUE_VALUE
    }
    open func setValue(key: String,_ val: Bool) {
        userDefaults?.set((val) ? (TRUE_VALUE) : (FALSE_VALUE), forKey: key)
    }
    
    //MARK: - Integer -
    open func getValue(key: String,_ def: Int) -> Int {
        if let val = userDefaults?.integer(forKey: key) {
            return val
        }
        return def
    }
    open func setValue(key: String,_ val: Int) {
        userDefaults?.set(val, forKey: key)
    }
    
    //MARK: - Double -
    open func getValue(key: String,_ def: Double) -> Double {
        if let val = userDefaults?.double(forKey: key) {
            return val
        }
        return def
    }
    open func setValue(key: String,_ val: Double) {
        userDefaults?.set(val, forKey: key)
    }
    
    //MARK: - String -
    open func getValue(key: String,_ def: String?) -> String? {
        if let val = userDefaults?.string(forKey: key) {
            return val
        }
        return def
    }
    open func setValue(key: String,_ val: String?) {
        if let _val = val {
            userDefaults?.set(_val, forKey: key)
        } else {
            userDefaults?.removeObject(forKey: key)
        }
    }
    
}
