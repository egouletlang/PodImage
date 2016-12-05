//
//  UniqueOperationDelegate.swift
//  Shared
//
//  Created by Etienne Goulet-Lang on 1/14/16.
//  Copyright © 2016 Heine Frifeldt. All rights reserved.
//

import Foundation

public protocol UniqueOperationDelegate: NSObjectProtocol {
    func complete(id: String?, result: AnyObject?)
}