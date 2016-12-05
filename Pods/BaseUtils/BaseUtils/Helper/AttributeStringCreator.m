//
//  AttributeStringCreator.m
//  Phoenix
//
//  Created by Etienne Goulet-Lang on 9/23/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//


#import "AttributeStringCreator.h"

@interface AttributeStringCreator()
+ (NSMutableAttributedString *) build:(NSString*)raw :(int)textSize :(NSMutableArray*)links :(NSMutableArray*)linkLocations :(NSString*)baseColor;
@end

@implementation AttributeStringCreator

static unichar const OPEN_TAG = '<';
static unichar const CLOSE_TAG = '>';
static unichar const SLASH_TAG = '/';
static unichar const DOUBLE_QUOTES_TAG = '"';
static unichar const SINGLE_QUOTES_TAG = '\'';

static int const CLOSED = 0;
static int const OPEN_FOUND = 1;

static unichar const BOLD_TAG[] = {'b'};
static unichar const ITALIC_TAG[] = {'i'};
static unichar const UNDERLINE_TAG[] = {'u'};
static unichar const BREAK_TAG[] = {'b', 'r'};
static unichar const TINY_TAG[] = {'t', 'i', 'n', 'y'};
static unichar const SMALL_TAG[] = {'s', 'm', 'a', 'l', 'l'};
static unichar const LARGE_TAG[] = {'l', 'a', 'r', 'g', 'e'};
static unichar const HUGE_TAG[] = {'h', 'u', 'g', 'e'};
static unichar const LINK_START_TAG[] = {'a', ' ', 'h', 'r', 'e','f'};
static unichar const LINK_END_TAG[] = {'a'};
static unichar const LEFT_TAG[] = {'l', 'e', 'f', 't'};
static unichar const CENTER_TAG[] = {'c', 'e', 'n', 't', 'e','r'};
static unichar const RIGHT_TAG[] = {'r', 'i', 'g', 'h', 't'};
static unichar const FONT_START_TAG[] = {'f', 'o', 'n', 't', ' ', 'c', 'o', 'l', 'o', 'r'};
static unichar const FONT_END_TAG[] = {'f', 'o', 'n', 't'};

static int const BOLD_INDEX = 0;
static int const ITALIC_INDEX = 1;
static int const UNDERLINE_INDEX = 2;
static int const BREAK_INDEX __unused = 3;
static int const TINY_INDEX = 4;
static int const SMALL_INDEX = 5;
static int const LARGE_INDEX = 6;
static int const HUGE_INDEX = 7;
static int const LINK_INDEX = 8;
static int const LEFT_INDEX = 9;
static int const CENTER_INDEX = 10;
static int const RIGHT_INDEX = 11;
static int const FONT_INDEX = 12;

static int const TAG_COUNT = 13;

+ (void) correctTagArray :(int)index :(NSMutableArray *)opens :(NSMutableArray *)closes {
    int openCount = (int)[opens[index] count];
    int closeCount = (int)[closes[index] count];
    if (openCount > 0 && closeCount > 0) {
        if (opens[index][openCount - 1] == closes[index][closeCount - 1]) {
            [opens[index] removeLastObject];
            [closes[index] removeLastObject];
        }
    }
}
+ (BOOL) checkForTag :(unichar*)raw :(const unichar*)tag :(int)offset :(int)length :(NSUInteger)maxLength {
    if (maxLength < offset + length) { return NO; }
    
    for (int i = 0; i < length; i++) {
        if (raw[offset + i] != tag[i]) {
            return NO;
        }
    }
    return YES;
}
+ (int) checkTags :(unichar*)newStr :(unichar*)raw :(int)offset :(int)length :(NSUInteger)maxLength :(NSMutableArray *)opens :(NSMutableArray *)closes :(BOOL) openTag :(int)tagLocation :(NSMutableArray *)colors :(NSMutableArray *)links{
    switch (length) {
        case 1:
            if ([AttributeStringCreator checkForTag:raw:BOLD_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[BOLD_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [AttributeStringCreator correctTagArray: BOLD_INDEX :opens :closes];
                } else {
                    [closes[BOLD_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributeStringCreator checkForTag:raw:ITALIC_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[ITALIC_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [AttributeStringCreator correctTagArray: ITALIC_INDEX :opens :closes];
                } else {
                    [closes[ITALIC_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributeStringCreator checkForTag:raw:UNDERLINE_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[UNDERLINE_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                } else {
                    [closes[UNDERLINE_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributeStringCreator checkForTag:raw:LINK_END_TAG:offset:length:maxLength]) {
                if (openTag == NO) {
                    [closes[LINK_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            break;
        case 2:
            if ([AttributeStringCreator checkForTag:raw:BREAK_TAG:offset:length:maxLength]) {
                newStr[tagLocation] = '\n';
                if ([opens[CENTER_INDEX] count] != [closes[CENTER_INDEX] count]) {
                    [closes[CENTER_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [opens[CENTER_INDEX] addObject:[NSNumber numberWithInt:tagLocation + 1]];
                }
                return 1;
            }
        case 4:
            if ([AttributeStringCreator checkForTag:raw:HUGE_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[HUGE_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [AttributeStringCreator correctTagArray: HUGE_INDEX :opens :closes];
                } else {
                    [closes[HUGE_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributeStringCreator checkForTag:raw:TINY_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[TINY_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [AttributeStringCreator correctTagArray: TINY_INDEX :opens :closes];
                } else {
                    [closes[TINY_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributeStringCreator checkForTag:raw:LEFT_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[LEFT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                } else {
                    [closes[LEFT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributeStringCreator checkForTag:raw:FONT_END_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[FONT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                } else {
                    [closes[FONT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            break;
        case 5:
            if ([AttributeStringCreator checkForTag:raw:SMALL_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[SMALL_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [AttributeStringCreator correctTagArray: SMALL_INDEX :opens :closes];
                } else {
                    [closes[SMALL_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributeStringCreator checkForTag:raw:LARGE_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[LARGE_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                    [AttributeStringCreator correctTagArray: LARGE_INDEX :opens :closes];
                } else {
                    [closes[LARGE_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            if ([AttributeStringCreator checkForTag:raw:RIGHT_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[RIGHT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                } else {
                    [closes[RIGHT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            break;
        case 6:
            if ([AttributeStringCreator checkForTag:raw:CENTER_TAG:offset:length:maxLength]) {
                if (openTag == YES) {
                    [opens[CENTER_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                } else {
                    [closes[CENTER_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
                }
                return 0;
            }
            break;
    }
    if (length >= 5) {
        if ([AttributeStringCreator checkForTag:raw:LINK_START_TAG:offset:6:maxLength]) {
            if (openTag == YES) {
                BOOL startFound = NO;
                unichar buffer[length];
                int index = 0;
                
                for (int i = 0; i <length; i++) {
                    if (raw[offset + i] == DOUBLE_QUOTES_TAG || raw[offset + i] == SINGLE_QUOTES_TAG) {
                        startFound = !startFound;
                        if (!startFound) { break; }
                    } else if (startFound) {
                        buffer[index++] = raw[offset + i];
                    }
                }
                
                if (index > 0) {
                    [links addObject:[NSString stringWithCharacters:buffer length:index]];
                }
                
                [opens[LINK_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
            }
            return 0;
        }
        if ([AttributeStringCreator checkForTag:raw:FONT_START_TAG:offset:4:maxLength]) {
            if (openTag == YES) {
                BOOL startFound = NO;
                unichar buffer[length];
                int index = 0;
                
                for (int i = 0; i <length; i++) {
                    if (raw[offset + i] == DOUBLE_QUOTES_TAG || raw[offset + i] == SINGLE_QUOTES_TAG) {
                        startFound = !startFound;
                        if (!startFound) { break; }
                    } else if (startFound) {
                        buffer[index++] = raw[offset + i];
                    }
                }
                
                if (index > 0) {
                    [colors addObject:[NSString stringWithCharacters:buffer length:index]];
                }
                
                [opens[FONT_INDEX] addObject:[NSNumber numberWithInt:tagLocation]];
            }
            return 0;
        }
    }
    return -1;
}
+ (void) examineTag :(NSMutableArray *)tags :(int *) currTagIndex :(int *) currValue :(int) tagIndex :(int) tagArrayIndex :(int) tagArrayCount {
    if (tagArrayIndex < tagArrayCount) {
        int value = ((NSNumber *)tags[tagIndex][tagArrayIndex]).intValue;
        *currValue = MIN(*currValue, value);
        if (*currValue == value) {
            *currTagIndex = tagIndex;
        }
    }
}
+ (UIColor *) createColor :(NSString *) color {
    if (color == nil) { return [UIColor blackColor]; }
    
    NSString* upperCase = [[color stringByReplacingOccurrencesOfString :@"#" withString: @""] stringByReplacingOccurrencesOfString :@"0x" withString: @""].uppercaseString;
    CGFloat a, r, g, b;
    
    switch (upperCase.length) {
        case 3: // #RGB
            a = 1.0f;
            r = [AttributeStringCreator getColorComponent: upperCase :0 :1];
            g = [AttributeStringCreator getColorComponent: upperCase :1 :1];
            b = [AttributeStringCreator getColorComponent: upperCase :2 :1];
            break;
        case 4: // #ARGB
            a = [AttributeStringCreator getColorComponent: upperCase :0 :1];
            r = [AttributeStringCreator getColorComponent: upperCase :1 :1];
            g = [AttributeStringCreator getColorComponent: upperCase :2 :1];
            b = [AttributeStringCreator getColorComponent: upperCase :3 :1];
            break;
        case 6: // #RRGGBB
            a = 1.0f;
            r = [AttributeStringCreator getColorComponent: upperCase :0 :2];
            g = [AttributeStringCreator getColorComponent: upperCase :2 :2];
            b = [AttributeStringCreator getColorComponent: upperCase :4 :2];
            break;
        case 8: // #AARRGGBB
            a = [AttributeStringCreator getColorComponent: upperCase :0 :2];
            r = [AttributeStringCreator getColorComponent: upperCase :2 :2];
            g = [AttributeStringCreator getColorComponent: upperCase :4 :2];
            b = [AttributeStringCreator getColorComponent: upperCase :6 :2];
            break;
        default:
            return [UIColor blackColor];
            
    }
    
    return [UIColor colorWithRed: r green: g blue: b alpha: a];
}
+ (float) getColorComponent :(NSString *)str :(int) start :(int) length {
    NSString* substring = [str substringWithRange: NSMakeRange(start, length)];
    NSString* fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}
+ (void) findNextCombinedTag :(NSMutableArray *)opens :(NSMutableArray *)closes
                             :(int *) index :(int *) location :(BOOL *) isOpen
                             :(int) boldOpenIndex :(int) boldCloseIndex :(int) boldCount
                             :(int) italicsOpenIndex :(int) italicsCloseIndex :(int) italicsCount
                             :(int) tinyOpenIndex :(int) tinyCloseIndex :(int) tinyCount
                             :(int) smallOpenIndex :(int) smallCloseIndex :(int) smallCount
                             :(int) largeOpenIndex :(int) largeCloseIndex :(int) largeCount
                             :(int) hugeOpenIndex :(int) hugeCloseIndex :(int) hugeCount {
    
    *location = INT32_MAX;
    [AttributeStringCreator examineTag:opens :index :location :BOLD_INDEX :boldOpenIndex :boldCount];
    [AttributeStringCreator examineTag:opens :index :location :ITALIC_INDEX :italicsOpenIndex :italicsCount];
    [AttributeStringCreator examineTag:opens :index :location :TINY_INDEX :tinyOpenIndex :tinyCount];
    [AttributeStringCreator examineTag:opens :index :location :SMALL_INDEX :smallOpenIndex :smallCount];
    [AttributeStringCreator examineTag:opens :index :location :LARGE_INDEX :largeOpenIndex :largeCount];
    [AttributeStringCreator examineTag:opens :index :location :HUGE_INDEX :hugeOpenIndex :hugeCount];
    
    int openValue = *location;
    [AttributeStringCreator examineTag:closes :index :location :BOLD_INDEX :boldCloseIndex :boldCount];
    [AttributeStringCreator examineTag:closes :index :location :ITALIC_INDEX :italicsCloseIndex :italicsCount];
    [AttributeStringCreator examineTag:closes :index :location :TINY_INDEX :tinyCloseIndex :tinyCount];
    [AttributeStringCreator examineTag:closes :index :location :SMALL_INDEX :smallCloseIndex :smallCount];
    [AttributeStringCreator examineTag:closes :index :location :LARGE_INDEX :largeCloseIndex :largeCount];
    [AttributeStringCreator examineTag:closes :index :location :HUGE_INDEX :hugeCloseIndex :hugeCount];
    
    *isOpen = (openValue <= *location);
    
}
+ (NSMutableAttributedString *) create :(unichar*)newStr :(int)newStrLength :(NSMutableArray *)opens :(NSMutableArray *)closes :(int)textSize :(NSMutableArray *)colors :(NSString*)baseColor{
    
    UIFont *font = [UIFont systemFontOfSize:textSize];
    
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineHeightMultiple = 1.0;
    paragraph.minimumLineHeight = font.lineHeight;
    paragraph.maximumLineHeight = font.lineHeight;
    
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc]
                                      initWithString:[NSString stringWithCharacters:newStr length:newStrLength]
                                      attributes:@{
                                                   NSFontAttributeName: font,
                                                   NSParagraphStyleAttributeName: paragraph}];
    
    int boldIndex = 0;
    int italicsIndex = 0;
    int tinyIndex = 0;
    int smallIndex = 0;
    int largeIndex = 0;
    int hugeIndex = 0;
    
    int boldCount = (int) MIN([opens[BOLD_INDEX] count], [closes[BOLD_INDEX] count]);
    int italicsCount = (int) MIN([opens[ITALIC_INDEX] count], [closes[ITALIC_INDEX] count]);
    int tinyCount = (int) MIN([opens[TINY_INDEX] count], [closes[TINY_INDEX] count]);
    int smallCount = (int) MIN([opens[SMALL_INDEX] count], [closes[SMALL_INDEX] count]);
    int largeCount = (int) MIN([opens[LARGE_INDEX] count], [closes[LARGE_INDEX] count]);
    int hugeCount = (int) MIN([opens[HUGE_INDEX] count], [closes[HUGE_INDEX] count]);
    
    int boldOpen = 0;
    int italicsOpen = 0;
    int tinyOpen = 0;
    int smallOpen = 0;
    int largeOpen = 0;
    int hugeOpen = 0;
    
    int previousTagLocation = 0;
    
    int tagIndex = -1;
    int tagLocation = -1;
    BOOL isOpen = NO;
    
    
    
    
    // Iterate through BOLD, ITALICS and the size Tags
    while (boldIndex < boldCount || italicsIndex < italicsCount || tinyIndex < tinyCount || smallIndex < smallCount || largeIndex < largeCount || hugeIndex < hugeCount) {
        [AttributeStringCreator findNextCombinedTag:opens :closes :&tagIndex :&tagLocation :&isOpen
                                                   :(boldIndex + boldOpen) :boldIndex :boldCount
                                                   :(italicsIndex + italicsOpen) :italicsIndex :italicsCount
                                                   :(tinyIndex + tinyOpen) :tinyIndex :tinyCount
                                                   :(smallIndex + smallOpen) :smallIndex :smallCount
                                                   :(largeIndex + largeOpen) :largeIndex :largeCount
                                                   :(hugeIndex + hugeOpen) :hugeIndex :hugeCount];
        
        if (tagLocation > previousTagLocation) {
            //NSString *fontName;
            int fontSize = textSize;
            
            if (tinyOpen > 0) {
                fontSize -= 4;
            } else if (smallOpen > 0) {
                fontSize -= 2;
            } else if (largeOpen > 0) {
                fontSize += 2;
            } else if (hugeOpen > 0) {
                fontSize += 4;
            }
            
            if (boldOpen > 0 && italicsOpen > 0) {
                font = [UIFont italicSystemFontOfSize:fontSize];
            } else if (boldOpen > 0) {
                font = [UIFont boldSystemFontOfSize:fontSize];
            } else if (italicsOpen > 0) {
                font = [UIFont italicSystemFontOfSize:fontSize];
            } else {
                font = [UIFont systemFontOfSize:fontSize];
            }
            
            
            paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.lineHeightMultiple = 1.0;
            paragraph.minimumLineHeight = font.lineHeight;
            paragraph.maximumLineHeight = font.lineHeight;
            
            [ret setAttributes:
             @{
               NSFontAttributeName: font,
               NSParagraphStyleAttributeName: paragraph}
                         range:NSMakeRange(previousTagLocation, tagLocation - previousTagLocation)];
        }
        previousTagLocation = tagLocation;
        
        
        if (isOpen) {
            switch (tagIndex) {
                case BOLD_INDEX:
                    boldOpen++;
                    break;
                case ITALIC_INDEX:
                    italicsOpen++;
                    break;
                case TINY_INDEX:
                    tinyOpen++;
                    break;
                case SMALL_INDEX:
                    smallOpen++;
                    break;
                case LARGE_INDEX:
                    largeOpen++;
                    break;
                case HUGE_INDEX:
                    hugeOpen++;
                    break;
            }
        } else {
            switch (tagIndex) {
                case BOLD_INDEX:
                    boldOpen--;
                    boldIndex++;
                    break;
                case ITALIC_INDEX:
                    italicsOpen--;
                    italicsIndex++;
                    break;
                case TINY_INDEX:
                    tinyOpen--;
                    tinyIndex++;
                    break;
                case SMALL_INDEX:
                    smallOpen--;
                    smallIndex++;
                    break;
                case LARGE_INDEX:
                    largeOpen--;
                    largeIndex++;
                    break;
                case HUGE_INDEX:
                    hugeOpen--;
                    hugeIndex++;
                    break;
            }
        }
        
        
        
    }
    
    
    int count = (int) MIN([opens[UNDERLINE_INDEX] count], [closes[UNDERLINE_INDEX] count]);
    for (int i = 0; i < count; i++) {
        [ret addAttributes:
         @{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) }
                     range:NSMakeRange(
                                       ((NSNumber *)opens[UNDERLINE_INDEX][i]).intValue,
                                       ((NSNumber *)closes[UNDERLINE_INDEX][i]).intValue - ((NSNumber *)opens[UNDERLINE_INDEX][i]).intValue)];
    }
    
    count = (int) MIN([opens[LINK_INDEX] count], [closes[LINK_INDEX] count]);
    for (int i = 0; i < count; i++) {
        [ret addAttributes:
         @{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
            NSForegroundColorAttributeName: [UIColor blueColor]}
                     range:NSMakeRange(
                                       ((NSNumber *)opens[LINK_INDEX][i]).intValue,
                                       ((NSNumber *)closes[LINK_INDEX][i]).intValue - ((NSNumber *)opens[LINK_INDEX][i]).intValue)];
        
        
    }
    
    count = (int) MIN([opens[LEFT_INDEX] count], [closes[LEFT_INDEX] count]);
    paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentLeft;
    
    for (int i = 0; i < count; i++) {
        [ret addAttributes:
         @{ NSParagraphStyleAttributeName: paragraph }
                     range:NSMakeRange(
                                       ((NSNumber *)opens[LEFT_INDEX][i]).intValue,
                                       ((NSNumber *)closes[LEFT_INDEX][i]).intValue - ((NSNumber *)opens[LEFT_INDEX][i]).intValue)];
    }
    
    count = (int) MIN([opens[CENTER_INDEX] count], [closes[CENTER_INDEX] count]);
    paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    
    for (int i = 0; i < count; i++) {
        [ret addAttributes:
         @{ NSParagraphStyleAttributeName: paragraph }
                     range:NSMakeRange(
                                       ((NSNumber *)opens[CENTER_INDEX][i]).intValue,
                                       ((NSNumber *)closes[CENTER_INDEX][i]).intValue - ((NSNumber *)opens[CENTER_INDEX][i]).intValue)];
    }
    
    count = (int) MIN([opens[RIGHT_INDEX] count], [closes[RIGHT_INDEX] count]);
    paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentRight;
    
    for (int i = 0; i < count; i++) {
        [ret addAttributes:
         @{ NSParagraphStyleAttributeName: paragraph }
                     range:NSMakeRange(
                                       ((NSNumber *)opens[RIGHT_INDEX][i]).intValue,
                                       ((NSNumber *)closes[RIGHT_INDEX][i]).intValue - ((NSNumber *)opens[RIGHT_INDEX][i]).intValue)];
    }
    
    
    if (baseColor != nil) {
        [ret addAttributes:
         @{ NSForegroundColorAttributeName: [AttributeStringCreator createColor: baseColor] }
                     range:NSMakeRange(0, ret.length)];
    }
    
    count = (int) MIN([opens[FONT_INDEX] count], [closes[FONT_INDEX] count]);
    paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentRight;
    
    for (int i = 0; i < count; i++) {
        [ret addAttributes:
         @{ NSForegroundColorAttributeName: [AttributeStringCreator createColor: colors[i]] }
                     range:NSMakeRange(
                                       ((NSNumber *)opens[FONT_INDEX][i]).intValue,
                                       ((NSNumber *)closes[FONT_INDEX][i]).intValue - ((NSNumber *)opens[FONT_INDEX][i]).intValue)];
    }
    
    return ret;
}

+ (NSMutableAttributedString *) build:(NSString*)raw :(int)textSize :(NSMutableArray*) links :(NSMutableArray*) linkLocations :(NSString*)baseColor {
    NSUInteger length = raw.length;
    unichar buffer[length+1];
    unichar newStringBuffer[length+1];
    [raw getCharacters:buffer range:NSMakeRange(0, length)];
    
    unichar currChar;
    
    int state = CLOSED;
    BOOL openTag = YES;
    
    int tagLocation = 0;
    int tagStart = 0;
    int currentSize = 0;
    
    NSMutableArray *tagOpens = [NSMutableArray array];
    for (int i = 0; i < TAG_COUNT; i++) {
        [tagOpens addObject:[NSMutableArray array]];
    }
    NSMutableArray *tagCloses = [NSMutableArray array];
    for (int i = 0; i < TAG_COUNT; i++) {
        [tagCloses addObject:[NSMutableArray array]];
    }
    NSMutableArray *colors = [NSMutableArray array];
    
    for(int i = 0; i < length; i++) {
        currChar = buffer[i];
        newStringBuffer[currentSize++] = currChar;
        
        switch (state) {
            case CLOSED:
                if (currChar == OPEN_TAG) {
                    openTag = YES;
                    state = OPEN_FOUND;
                    tagLocation = currentSize - 1;
                    tagStart = i + 1;
                }
                break;
            case OPEN_FOUND:
                if (currChar == SLASH_TAG) {
                    if (openTag == YES && tagStart == i) {
                        tagStart = i + 1;
                        openTag = NO;
                    }
                } else if (currChar == CLOSE_TAG) {
                    int proc = [AttributeStringCreator checkTags:newStringBuffer :buffer :tagStart:(i - tagStart):length :tagOpens :tagCloses :openTag :tagLocation :colors :links];
                    if (proc >= 0) {
                        currentSize = tagLocation + proc;
                    }
                    state = CLOSED;
                }
                break;
        }
    }
    
    int count = (int) MIN([tagOpens[LINK_INDEX] count], [tagCloses[LINK_INDEX] count]);
    for (int i = 0; i < count; i++) {
        [linkLocations addObject: [NSValue valueWithRange:NSMakeRange(((NSNumber *)tagOpens[LINK_INDEX][i]).intValue, (((NSNumber *)tagCloses[LINK_INDEX][i]).intValue - ((NSNumber *)tagOpens[LINK_INDEX][i]).intValue))]];
    }
    
    return [AttributeStringCreator create:newStringBuffer :currentSize :tagOpens :tagCloses :textSize :colors :baseColor];
}

@end

