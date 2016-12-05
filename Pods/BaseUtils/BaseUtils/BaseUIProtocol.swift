//
//  BaseUIProtocol.swift
//  BaseUtils
//
//  Created by Etienne Goulet-Lang on 12/3/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation
import UIKit

public protocol BaseUIProtocol {
    
    func initialize()
    func createAndAddSubviews()
    func addGestureRecognition()
    func removeGestureRecognition()
    func frameUpdate()
    func addTap(_ view: UIView, selector: Selector)
    func addLongPress(_ view: UIView, selector: String)
    func animate(_ block: @escaping ()->Void)
    
}
