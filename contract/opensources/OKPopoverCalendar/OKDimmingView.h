//
//  OKDimmingView.h
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OKPopoverCalendarController;


@interface OKDimmingView : UIView

@property (strong, nonatomic) OKPopoverCalendarController *controller;

- (id)initWithFrame:(CGRect)frame controller:(OKPopoverCalendarController*)controller;

@end
