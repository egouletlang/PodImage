//
//  JSONHelper.swift
//  BaseUtils
//
//  Created by Etienne Goulet-Lang on 3/1/17.
//  Copyright © 2017 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

open class JSONHelper {
    open class func concat(list: [String], split: String = " ") -> String {
        return list.joined(separator: split)
    }
    
    open class func toJsonString(obj: AnyObject) -> String? {
        var err: NSError?
        var data: Data?
        do {
            data = try JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions())
        } catch let error as NSError {
            err = error
            data = nil
        }
        
        if err != nil {
            return nil
        } else {
            return NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
        }
    }
    
    open class func jsonStringToDict(str: String?) -> [String: AnyObject] {
        if  let s = str,
            let d = s.data(using:String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
            do {
                if let r = try JSONSerialization.jsonObject(with: d, options: .allowFragments) as? [String : AnyObject] {
                    return r
                }
            } catch {}
        }
        return [:]
    }
}
