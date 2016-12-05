//
//  GifDecoder.h
//  Shared
//
//  Created by Etienne Goulet-Lang on 1/6/16.
//  Copyright © 2016 Heine Frifeldt. All rights reserved.
//

#ifndef GifDecoder_h
#define GifDecoder_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

FOUNDATION_EXTERN NSString * const kGifDecoderErrorDomain;
typedef enum {
    kGifDecoderErrorInvalidArgs = 0, //used
    kGifDecoderErrorInvalidGIFImage,
    kGifDecoderErrorAlreadyProcessing,
    kGifDecoderErrorBufferingFailed,
    kGifDecoderErrorInvalidResolution,
    kGifDecoderErrorTimedOut,
} kGifDecoderError;

typedef void (^kGifDecoderCompleted) (int frameCount, CGSize size, UIImage* img, NSError* error);

@interface GifDecoder: NSObject

+ (void) convertData: (NSData*) data completed: (kGifDecoderCompleted) handler;
+ (UIImage*) getCoverImage: (NSData*) data;
+ (int) getImageCount: (NSData*) data;

@end



#endif /* GifDecoder_h */
