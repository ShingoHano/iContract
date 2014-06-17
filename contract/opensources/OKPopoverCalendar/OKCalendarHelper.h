//
//  OKCalendarHelper.h
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import "NSDate+CalendarHelper.h"

static inline float radians(double degrees) 
{ 
    return degrees * M_PI / 180; 
}
static inline CGPoint CGPointOffset(CGPoint originalPoint, CGFloat dx, CGFloat dy) 
{ 
    return CGPointMake(originalPoint.x + dx, originalPoint.y + dy); 
}
static inline CGPoint CGPointOffsetByPoint(CGPoint originalPoint, CGPoint offsetPoint) 
{ 
    return CGPointOffset(originalPoint, offsetPoint.x, offsetPoint.y); 
}

// To be deprecated as UIOffset is iOS 5 only.
static inline CGSize UIOffsetToCGSize(UIOffset offset) 
{ 
    return CGSizeMake(offset.horizontal, offset.vertical); 
}

// UIColor helpers

#define UIColorMakeRGBA(nRed, nGreen, nBlue, nAlpha) [UIColor colorWithRed:(nRed)/255.0f \
                                                                     green:(nGreen)/255.0f \
                                                                      blue:(nBlue)/255.0f \
                                                                     alpha:nAlpha]
#define UIColorMakeRGB(nRed, nGreen, nBlue) UIColorMakeRGBA(nRed, nGreen, nBlue, 1.0f)

// Logging

#define DEBUG_LOGS

#ifdef DEBUG_LOGS
#define OKLog(message, ...) NSLog((@"OKLOG: %s [Line %d] " message), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__)
#else
#define OKLog(message, ...)
#endif
