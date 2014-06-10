//
//  OKDimmingView.m
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import "OKDimmingView.h"
#import "OKCalendarConstants.h"
#import "OKPopoverCalendarController.h"
#import "OKCalendarHelper.h"

@implementation OKDimmingView

- (id)initWithFrame:(CGRect)frame controller:(OKPopoverCalendarController*)controller
{
    if (!(self = [super initWithFrame:frame])) 
    {
        return nil;
    }
    
	_controller = controller;
    self.backgroundColor = UIColorMakeRGBA(0, 0, 0, 0.3);
    
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![_controller.delegate respondsToSelector:@selector(calendarControllerShouldDismissCalendar:)]
        || [_controller.delegate calendarControllerShouldDismissCalendar:self.controller])
    {
        [_controller dismissCalendarAnimated:YES];
    }
}

@end
