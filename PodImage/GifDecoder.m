//
//  GifDecoder.m
//  Shared
//
//  Created by Etienne Goulet-Lang on 1/6/16.
//  Copyright © 2016 Heine Frifeldt. All rights reserved.
//

#import "GifDecoder.h"


NSString * const kGifDecoderErrorDomain = @"GifDecoderError";

@implementation GifDecoder

+ (void) convertData: (NSData*) data completed: (kGifDecoderCompleted) handler {
    
    [self processGIFData: data completed: handler];
}

+ (int) getImageCount: (NSData*) data {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    int count;
    if (CGImageSourceGetStatus(source) != kCGImageStatusComplete) {
        count = 0;
    } else {
        count = (int)CGImageSourceGetCount(source);
    }
    CFRelease(source);
    
    return count;
}

+ (UIImage*) getCoverImage: (NSData*) data {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    UIImage* result;
    if (CGImageSourceGetStatus(source) != kCGImageStatusComplete) {
        result = nil;
    } else {
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        result = [UIImage imageWithCGImage:image scale:1 orientation:UIImageOrientationUp];
        
        CGImageRelease(image);
    }

    CFRelease(source);
    return result;
}

+ (void) processGIFData: (NSData*) data
              completed: (kGifDecoderCompleted) completionHandler {
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    unsigned char *bytes = (unsigned char*)data.bytes;
    NSError* error = nil;
    
    if (CGImageSourceGetStatus(source) != kCGImageStatusComplete) {
        error = [NSError errorWithDomain: kGifDecoderErrorDomain
                                    code: kGifDecoderErrorInvalidGIFImage
                                userInfo: nil];
        CFRelease(source);
        completionHandler(0, CGSizeZero, nil, error);
        return;
    }
    
    size_t sourceWidth = bytes[6] + (bytes[7]<<8), sourceHeight = bytes[8] + (bytes[9]<<8);
    CGSize size = CGSizeMake((CGFloat) sourceWidth, (CGFloat) sourceHeight);
    
    if (error) {
        CFRelease(source);
        completionHandler(0, CGSizeZero, nil, error);
        return;
    }
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            duration += [self frameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:1 orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    completionHandler((int)count, size, animatedImage, nil);
    
    CFRelease(source);
};

+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}


@end
