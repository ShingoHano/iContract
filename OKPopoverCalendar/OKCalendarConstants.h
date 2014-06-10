//
//  OKCalendarConstrants.h
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#define kOKCalendarRedrawNotification @"kOKCalendarRedrawNotification"

enum {
//    OKCalendarArrowDirectionNo      = -1, <- TBI
    OKCalendarArrowDirectionUp      = 1UL << 0,
    OKCalendarArrowDirectionDown    = 1UL << 1,
    OKCalendarArrowDirectionLeft    = 1UL << 2,
    OKCalendarArrowDirectionRight   = 1UL << 3,
    OKCalendarArrowDirectionAny     = OKCalendarArrowDirectionUp | OKCalendarArrowDirectionDown | OKCalendarArrowDirectionLeft | OKCalendarArrowDirectionRight,
    OKCalendarArrowDirectionUnknown = NSUIntegerMax
};
typedef NSUInteger OKCalendarArrowDirection;
