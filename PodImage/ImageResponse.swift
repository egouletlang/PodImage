//
//  ImageResponse.swift
//  PodImage
//
//  Created by Etienne Goulet-Lang on 12/3/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

open class ImageResponse {
    
    fileprivate init() {}
    
    class func build(key: String, imageCacheEntry: ImageCacheEntry?) -> ImageResponse? {
        if let entry = imageCacheEntry {
            let ir = cached(key: key, image: entry.value)
            ir.etag = entry.etag
            ir.lastModified = entry.lastModified
            return ir
        }
        return nil
    }
    
    class func web(key: String?, image: UIImage?) -> ImageResponse {
        let ir = ImageResponse()
        ir.image = image
        ir.status = .Web
        return ir
    }
    class func cached(key: String?, image: UIImage?) -> ImageResponse {
        let ir = ImageResponse()
        ir.image = image
        ir.status = .Cached
        return ir
    }
    class func disk(key: String?, image: UIImage?) -> ImageResponse {
        let ir = ImageResponse()
        ir.image = image
        ir.status = .Disk
        return ir
    }
    
    class func noKey() -> ImageResponse {
        let ir = ImageResponse()
        ir.status = .NoKey
        return ir
    }
    
    class func error() -> ImageResponse {
        let ir = ImageResponse()
        ir.status = .Error
        return ir
    }
    
    public enum Status {
        case NoKey
        case Web
        case Disk
        case Cached
        case Error
    }
    
    open var status: Status!
    open var key: String?
    open var image: UIImage?
    
    open var etag: String?
    open var lastModified: String?
    
}
