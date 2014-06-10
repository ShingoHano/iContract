//
//  NSDate+CalendarHelper.h
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CalendarHelper)

- (NSDate *) dateWithoutTime;
- (NSDate *) dateByAddingDays:(NSInteger) days;
- (NSDate *) dateByAddingMonths:(NSInteger) months;
- (NSDate *) dateByAddingYears:(NSInteger) years;
- (NSDate *) dateByAddingDays:(NSInteger) days months:(NSInteger) months years:(NSInteger) years;
- (NSDate *) monthStartDate;
- (NSDate *) midnightDate;
- (NSUInteger) numberOfDaysInMonth;
- (NSUInteger) weekday;
- (NSInteger) daysSinceDate:(NSDate *) date;
- (NSString *) dateStringWithFormat:(NSString *) format;
- (BOOL) isBefore:(NSDate *) date;
- (BOOL) isAfter:(NSDate *) date;

@end
