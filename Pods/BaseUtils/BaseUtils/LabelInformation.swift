//
//  LabelInformation.swift
//  BaseUIClasses
//
//  Created by Etienne Goulet-Lang on 11/19/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

open class LabelInformation: NSObject {
    open var attr: NSAttributedString?
    open var links: [URL] = []
    open var ranges: [NSRange] = []
}
