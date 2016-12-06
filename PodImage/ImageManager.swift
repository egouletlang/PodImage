//
//  ImageManager.swift
//  PodImage
//
//  Created by Etienne Goulet-Lang on 12/3/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation
import BaseUtils

open class ImageManager {
    
    //MARK: - Instantiation -
    /// Use the shared instance to ensure proper caching behavior
    open static let instance = ImageManager()
    fileprivate init() {
        NSKeyedUnarchiver.setClass(ImageCacheEntry.classForKeyedUnarchiver(), forClassName: "TestPods.ImageCacheEntry")
    }
    
    //MARK: - Image Sources Helpers -
    fileprivate enum ImageSource: String {
        case Asset = "Asset://"
        case Album = "Album://"
        case Http = "http://"
        case Https = "https://"
        
        static func isAsset(str: String) -> Bool {
            return str.startsWith(Asset.rawValue)
        }
        
        static func isAlbum(str: String) -> Bool {
            return str.startsWith(Album.rawValue)
        }
        
        static func isWeb(str: String) -> Bool {
            return str.startsWith(Http.rawValue) || str.startsWith(Https.rawValue)
        }
        
        static func removeImageSource(str: String) -> String {
            if let range = str.range(of: Asset.rawValue) {
                return str.replacingCharacters(in: range , with: "")
            } else if let range = str.range(of: Album.rawValue) {
                return str.replacingCharacters(in: range , with: "")
            }
            return str
        }
    }
    
    open class func buildAssetUri(name: String) -> String {
        return ImageSource.Asset.rawValue + name
    }
    open class func buildAlbumUri(name: String) -> String {
        return ImageSource.Album.rawValue + name
    }
    
    //MARK: - Caches -
    private lazy var assetCache: ImageLRUCache = {
        var cache = ImageLRUCache(lruName: "asset_image_cache")
        cache.totalCostLimitMB = 50 * 1204 * 1024
        return cache
    }()
    private let assetCacheLock = Lock()
    
    private lazy var albumCache: ImageLRUCache = {
        var cache = ImageLRUCache(lruName: "album_image_cache")
        cache.totalCostLimitMB = 50 * 1204 * 1024
        return cache
    }()
    private let albumCacheLock = Lock()
    
    private lazy var httpCache: ImageLRUCache = {
        var cache = ImageLRUCache(lruName: "http_image_cache")
        cache.totalCostLimitMB = 200 * 1204 * 1024
        return cache
    }()
    private let httpCacheLock = Lock()
    
    //MARK: - Operation Queue -
    private let uriQueue = UniqueOperationQueue<ImageResponse>(name: "image.queue.uri", concurrentCount: 5)
    
    fileprivate func getCache(source: ImageSource) -> ImageLRUCache {
        switch (source) {
            case .Asset:
                return assetCache
            case .Album:
                return albumCache
            case .Http, .Https:
                return httpCache
        }
    }
    fileprivate func getCacheLock(source: ImageSource) -> Lock {
        switch (source) {
        case .Asset:
            return assetCacheLock
        case .Album:
            return albumCacheLock
        case .Http, .Https:
            return httpCacheLock
        }
    }
    
    fileprivate func getCache(key: String, callback: @escaping (ImageLRUCache)->Void) {
        var source: ImageSource
        
        if (ImageSource.isAsset(str: key)) {
            source = .Asset
        } else if (ImageSource.isAlbum(str: key)) {
            source = .Album
        } else {
            source = .Https
        }
        
        ImageManager.instance.getCacheLock(source: source).withLock {
            callback(ImageManager.instance.getCache(source: source))
        }
        
    }
    
    func getHttpCache(callback: @escaping (ImageLRUCache)->Void) {
        self.getCacheLock(source: .Https).withLock {
            callback(self.getCache(source: .Https))
        }
        
    }
    
        
    open var httpCacheMaxMB = 200 * 1204 * 1024 {
        didSet {
            httpCache.totalCostLimitMB = self.httpCacheMaxMB
        }
    }
    
    //MARK: - Get Images -
    
//    fileprivate func getFromCache(key: String) -> UIImage? {
//        var image: UIImage?
//        self.getCache(key: key) { image = $0.get(imageForKey: key) }
//        return image
//    }
    
    fileprivate func getFromCache(key: String) -> ImageResponse? {
        var ir: ImageResponse?
        self.getCache(key: key) { ir = ImageResponse.build(key: key, imageCacheEntry: $0.get(entryForKey: key)) }
        return ir
    }
    
    fileprivate func fetch(key: String,
                           cachedResponse: ImageResponse?,
                           callback: @escaping (ImageResponse?) -> Void) {
        
        if ImageSource.isWeb(str: key) {
            let op = GetResourceFromURI(uri: key,
                                        checkForUpdateOnly: (cachedResponse != nil),
                                        etag: cachedResponse?.etag,
                                        lastModified: cachedResponse?.lastModified)
            uriQueue.addOperation(op: op, callback: callback)
        } else if ImageSource.isAsset(str: key) && cachedResponse == nil,
            let image = UIImage(named: ImageSource.removeImageSource(str: key)) {
            callback(ImageResponse.disk(key: key, image: image))
        }
        
    }
    
    open func cleanup() {
        self.getHttpCache() { $0.save() }
    }

    /// Get an [Assets, Library, Web] image. First check the cache, then
    /// check if the resource has been updated.
    open func get(request: ImageRequest,
                  callback: @escaping (ImageResponse) -> Void) {
        ThreadHelper.executeOnBackgroundThread {
            guard let originalKey = request.key else {
                callback(ImageResponse.noKey())
                return
            }
            
            // Create the transformed key
            let transformedKey = request.buildTransformedKey()!
            
            // Challenge the Cache with the transformed key, respond using the original image
            let cachedImageResponse = self.getFromCache(key: transformedKey)
            
            // Respond with the cached image if it exists, using the original key
            if let cachedImage = cachedImageResponse?.image {
                callback(ImageResponse.cached(key: originalKey, image: cachedImage))
            }
            
            // Fetch the new image to see if it has changed,
            // img: UIImage? will be nil if nothing has changed.
            self.fetch(key: originalKey, cachedResponse: cachedImageResponse) { (imageResponse: ImageResponse?) in
                guard let ir = imageResponse, let img = ir.image else { return }
                
                self.getCache(key: originalKey) { $0.put(key: originalKey, image: img, etag: ir.etag, lastModified: ir.lastModified) }
                
                let transformedImage = request.buildTransformedImage(image: img)
                
                if request.transforms != nil, transformedImage != nil {
                    self.getCache(key: transformedKey) { $0.put(key: transformedKey, image: transformedImage!, etag: ir.etag, lastModified: ir.lastModified) }
                }
                
                callback(ImageResponse.web(key: originalKey, image: transformedImage))
            }
        }
    }
    
}
