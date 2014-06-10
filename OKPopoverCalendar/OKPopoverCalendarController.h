//
//  OKPopoverCalendarController.h
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OKCalendarView.h"
#import "OKCalendarConstants.h"

@class OKPeriod,OKPopoverCalendarController;

@protocol OKPopoverCalendarControllerDelegate <NSObject>

@optional

- (BOOL)calendarControllerShouldDismissCalendar:(OKPopoverCalendarController *)calendarController;
- (void)calendarControllerDidDismissCalendar:(OKPopoverCalendarController *)calendarController;
- (void)calendarController:(OKPopoverCalendarController *)calendarController didChangePeriod:(OKPeriod *)newPeriod;

@end

@interface OKPopoverCalendarController : UIViewController <OKCalendarViewDelegate>

@property (assign, nonatomic) id<OKPopoverCalendarControllerDelegate> delegate;
@property (strong, nonatomic) OKPeriod *period;
@property (strong, nonatomic) OKPeriod *allowedPeriod;
@property (assign, nonatomic, getter = isMondayFirstDayOfWeek) BOOL mondayFirstDayOfWeek;
@property (assign, nonatomic) BOOL allowsPeriodSelection;
@property (assign, nonatomic) BOOL allowsLongPressMonthChange;
@property (readonly, nonatomic) OKCalendarArrowDirection calendarArrowDirection;
@property (assign, nonatomic) CGSize size;
@property (readonly, getter = isCalendarVisible) BOOL calendarVisible;

- (id) initWithSize:(CGSize) size;

//- (id) initWithThemeName:(NSString *) themeName;

//- (id) initWithThemeName:(NSString *) themeName andSize:(CGSize) size;

- (void)presentCalendarFromRect:(CGRect) rect
                         inView:(UIView *) view
       permittedArrowDirections:(OKCalendarArrowDirection) arrowDirections
                      isPopover:(BOOL) isPopover
                       animated:(BOOL) animated;

- (void)presentCalendarFromView:(UIView *) anchorView
       permittedArrowDirections:(OKCalendarArrowDirection) arrowDirections
                      isPopover:(BOOL) isPopover
                       animated:(BOOL) animated;

- (void) dismissCalendarAnimated:(BOOL) animated;

@end