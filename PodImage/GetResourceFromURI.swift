//
//  GetResourceFromURI.swift
//  Shared
//
//  Created by Etienne Goulet-Lang on 1/14/16.
//  Copyright © 2016 Heine Frifeldt. All rights reserved.
//

import Foundation
import BaseUtils

/// This operation will either fetch a resource or check if the resource has changed - pass in checkForUpdatesOnly to
/// to choose the behavior.
///
/// The fetch path forcefully checks for an update by passing in ReloadIgnoringLocalCacheData for the caching parameter
/// on the request object.
///
/// The check for update path tries to attach the Etag and Last-Modified headers stored in the ImageHelperRef's cache
/// object.
///
/// - MP4 resources create an MP4ResourceDescriptor object
/// - Animated Resources create a GIFResourceDescriptor object
/// - Non-animated Resources create a UIImage object
class GetResourceFromURI: UniqueOperation {
    
    // MARK: - Unique id -
    // required for UniqueOperationQueue
    override func getUniqueId() -> String? {
        return self.uri
    }
    
    // MARK: - Initialization -
    // GIF & MP4 uris are downloaded to the phone's disk - for offline purposes - on a separate process.
    // This can be time consuming, and eat up cpu. The stillImage flag provides a way
    // to bypass this process when it is unnecessary
    // checkForUpdateOnly causes this operation to only create UIImage objs if the object has changed on the server.
    convenience init(uri: String, checkForUpdateOnly: Bool, etag: String?, lastModified: String?) {
        self.init()
        self.uri = uri
        self.checkForUpdateOnly = checkForUpdateOnly
        self.etag = etag
        self.lastModified = lastModified
    }
    
    // MARK: - Convenience Variables -
    private var uri: String?
    private var checkForUpdateOnly = false
    private var etag: String?
    private var lastModified: String?
    
    private static let networkQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "get.resource.from.uri"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // MARK: - Starting and Completing the Operation -
    override func run() {
        guard let u = uri, !u.isEmpty else {
            complete(result: nil)
            return
        }
        getResource(uri: u)
    }
    
    private func complete(result: ImageResponse?) {
        self.deactivate(result: result)
    }
    
    // MARK: - Operation -
    // MARK: IMPORTANT: Remember to call complete(..) whether or not the operation was successful. Otherwise,
    // MARK: it will descrease the bandwidth on the operation queue. The AsynchronousOperation will eventually
    // MARK: timeout and the queue will recover, however performance will be reduced for a time. -
    
    private func getResource(uri: String) {
        // Select a handler
        if uri.endsWith(".mp4") {
            MP4Handler(uri: uri)
        } else {
            defaultHandler(uri: uri)
        }
    }
    
    private func MP4Handler(uri: String) {
        // TODO: build MP4 resource
        self.complete(result: nil)
    }
    private func defaultHandler(uri: String) {
        // Ignore stillImage and downloadToDisk only apply to MP4 and GIF handlers.
        
        // Download the image
        guard let url = URL(string: uri) else {
            complete(result: nil)
            return
        }
        
        self.makeRequest(url: url) { (data: Data?, etag: String?, lastModified: String?) -> Void in
            guard let d = data else {
                // If request was to check for updated content only, this makeRequest is expected to return nil
                // However, if we wanted some contents and didn't get any, log the error
                self.complete(result: nil)
                return
            }
            
            let imageResponse = ImageResponse.web(key: uri, image: GifDecoder.getCoverImage(d))
            imageResponse.etag = etag
            imageResponse.lastModified = lastModified
            self.complete(result: imageResponse)
        }
        
    }
    
    private func makeRequest(url: URL, completion: @escaping (Data?, String?, String?)->Void) {
        
        // .ReloadIgnoringLocalCacheData --- Skip the local cache to actually go check with the server.
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5)
        
        // TODO: Handle cache-control header - might be a good place to start: http://www.mobify.com/blog/beginners-guide-to-http-cache-headers/
        // Check the cache for etag & lastModified. Only set the headers if checkForUpdateOnly is set.
        if self.checkForUpdateOnly {
            if let etag = self.etag {
                request.addValue(etag, forHTTPHeaderField: "If-None-Match")
            }
            if let lastModified = self.lastModified {
                request.addValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
            }
        }
        
        // make the request to the server
        // 200 means that the data has changed.
        // 304 means that the resource is unchanged based on the Etag and last modified at, the copy in the
        // NSURLCache can be used.
        
        // NOTE: NSURLSession does not seem to work in the extension... this call will continue to be use
        
        let session = URLSession(configuration: URLSessionConfiguration.default,
                                 delegate: nil,
                                 delegateQueue: GetResourceFromURI.networkQueue)
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let res = response as? HTTPURLResponse {
                switch (res.statusCode) {
                    
                // if the response from the server is 200, the resource has been fetched successfully
                case 200:
                    completion(data, res.allHeaderFields["Etag"] as? String, res.allHeaderFields["Last-Modified"] as? String)
                    
                    
                // if the response from the server is 304, the resource has not been updated.
                case 304:
                    completion(nil, nil, nil)
                    
                default:
                    completion(nil, nil, nil)
                }
            } else {
                completion(nil, nil, nil)
            }
        }
        task.resume()
    }
    
}
