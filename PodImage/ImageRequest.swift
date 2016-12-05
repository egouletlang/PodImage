//
//  ImageRequest.swift
//  PodImage
//
//  Created by Etienne Goulet-Lang on 12/3/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

open class ImageRequest {
    public init(key: String?, transforms: [BaseImageTransform]?) {
        self.key = key
        self.transforms = transforms
    }
    
    open var key: String?
    open var transforms: [BaseImageTransform]?
    
    open var skipCache = false
    open var saveToCache = true
    
}
