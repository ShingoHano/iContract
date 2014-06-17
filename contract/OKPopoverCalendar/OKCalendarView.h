//
//  OKCalendarView.h
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OKPeriod;

@protocol OKCalendarViewDelegate <NSObject>

- (void) currentDateChanged:(NSDate *)currentDate;
- (void) periodChanged:(OKPeriod *)newPeriod;

@end

@interface OKCalendarView : UIView <UIGestureRecognizerDelegate>

@property (strong, nonatomic) OKPeriod *period;
@property (strong, nonatomic) OKPeriod *allowedPeriod;
@property (assign, nonatomic) BOOL mondayFirstDayOfWeek;
@property (assign, nonatomic) BOOL allowsPeriodSelection;

@property (nonatomic, assign) BOOL allowsLongPressMonthChange;
@property (nonatomic, assign) id<OKCalendarViewDelegate> delegate;

@property (nonatomic, strong) NSDate *currentDate;

@end


