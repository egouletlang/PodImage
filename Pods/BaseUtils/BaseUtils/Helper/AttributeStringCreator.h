//
//  AttributeStringCreator.h
//  Phoenix
//
//  Created by Etienne Goulet-Lang on 9/23/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

#ifndef AttributeStringCreator_h
#define AttributeStringCreator_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AttributeStringCreator : NSObject

+ (NSMutableAttributedString *) build:(NSString*)raw :(int)textSize :(NSMutableArray*)links :(NSMutableArray*)linkLocations :(NSString*)baseColor;
@end


#endif /* AttributeStringCreator_h */
