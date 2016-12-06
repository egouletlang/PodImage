//
//  ImageLRUCache.swift
//  PodImage
//
//  Created by Etienne Goulet-Lang on 12/4/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation
import BaseUtils

open class ImageLRUCache: LRUCache<String, UIImage> {
    
    public init(lruName: String) {
        super.init()
        self.lruName = lruName
        self.load()
    }
    
    open var lruName: String!
    
    open func get(entryForKey key: String) -> ImageCacheEntry? {
        return self.get(objForKey: key) as? ImageCacheEntry
    }
    
    open func get(imageForKey key: String) -> UIImage? {
        return self.get(objForKey: key)?.value
    }
    
    open func get(etagForKey key: String) -> String? {
        return (self.get(objForKey: key) as? ImageCacheEntry)?.etag
    }
    
    open func get(lastModifiedForKey key: String) -> String? {
        return (self.get(objForKey: key) as? ImageCacheEntry)?.lastModified
    }
    
    open func put(key: String, image: UIImage) {
        self.put(key: key, obj: ImageCacheEntry(image: image))
    }
    
    open func put(key: String, image: UIImage, etag: String?, lastModified: String?) {
        self.put(key: key, obj: ImageCacheEntry(image: image, etag: etag, lastModified: lastModified))
    }
    
    open func save() {
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: self.getCache())
        do {
            let fileURL = try FileManager.default.url(
                                    for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: true).appendingPathComponent(lruName)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print(error)
        }
    }
    
    open func load() {
        do {
            let fileURL = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true).appendingPathComponent(lruName)
            
            let data = try Data(contentsOf: fileURL)
            let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : ImageCacheEntry]
            self.setCache(cache: dictionary)
        } catch {
            print(error)
        }
        
    }
    
    
    
}
