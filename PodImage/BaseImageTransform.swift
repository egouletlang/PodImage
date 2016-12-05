//
//  BaseImageTransform.swift
//  PodImage
//
//  Created by Etienne Goulet-Lang on 12/3/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

open class BaseImageTransform {
    
    open func modifyKey(key: String) -> String {
        return key
    }
    
    open func transform(img: UIImage?) -> UIImage? {
        return nil
    }
    
}
