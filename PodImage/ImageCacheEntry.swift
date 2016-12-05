//
//  ImageCacheEntry.swift
//  PodImage
//
//  Created by Etienne Goulet-Lang on 12/4/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation
import BaseUtils

open class ImageCacheEntry: LRUCacheEntry<UIImage> {
    
    public init(image: UIImage) {
        super.init(value: image, cost: UIImageJPEGRepresentation(image, 1.0)?.count ?? (1024 * 1024))
    }
    
    public convenience init(image: UIImage, etag: String?, lastModified: String?) {
        self.init(image: image)
        self.etag = etag
        self.lastModified = lastModified
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        etag = aDecoder.decodeObject(forKey: "etag") as? String
        lastModified = aDecoder.decodeObject(forKey: "lastModified") as? String
    }
    
    override open func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(etag, forKey: "etag")
        aCoder.encode(lastModified, forKey: "lastModified")
    }
    
    
    open var etag: String?
    open var lastModified: String?
    
}
