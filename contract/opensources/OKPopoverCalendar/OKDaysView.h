//
//  OKDaysView.h
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OKPeriod;

@interface OKDaysView : UIView

@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) NSDate *currentDate; // month to show
@property (strong, nonatomic) OKPeriod *selectedPeriod;
@property (strong, nonatomic) NSArray *rects;
@property (assign, nonatomic) BOOL mondayFirstDayOfWeek;
@property (assign, nonatomic) CGRect initialFrame;

- (void)redrawComponent;

@end
