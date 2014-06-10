//
//  OKPeriod.h
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OKPeriod : NSObject <NSCopying>

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

+ (id) oneDayPeriodWithDate:(NSDate *) date;

+ (id) periodWithStartDate:(NSDate *) startDate endDate:(NSDate *) endDate;

- (NSInteger) lengthInDays;

- (OKPeriod *) normalizedPeriod;

- (BOOL) containsDate:(NSDate *) date;

@end
