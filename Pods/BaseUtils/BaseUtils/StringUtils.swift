//
//  StringUtils.swift
//  BaseUtils
//
//  Created by Etienne Goulet-Lang on 12/2/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

class StringUtils {
    
    open class func formatString(_ raw: String?,
                                 withTextSize ts: Int = 14,
                                 withLinks: Bool = true,
                                 withColor: String? = nil) -> LabelInformation? {
        
        let links = NSMutableArray()
        let linkLocations = NSMutableArray()
        let li = LabelInformation()
        li.attr = NSMutableAttributedString(string: "")
        
        if let _raw = raw {
            li.attr = AttributeStringCreator.build(_raw, Int32(ts), links, linkLocations, withColor)
        }
        
        if withLinks {
            for obj in links {
                if let link = obj as? NSString {
                    if let url = URL(string: link as String) {
                        li.links.append(url)
                    }
                }
            }
            
            for obj in linkLocations {
                if let range = (obj as AnyObject).rangeValue {
                    li.ranges.append(range)
                }
            }
        }
        return li
    }
    
    open class func stripOutTags(_ raw: String?) -> String? {
        let li = formatString(raw)
        return li?.attr?.string
    }
    
}
