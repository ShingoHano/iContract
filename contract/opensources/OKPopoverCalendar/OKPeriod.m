//
//  OKPeriod.h
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import "OKPeriod.h"
#import "NSDate+CalendarHelper.h"

@implementation OKPeriod

+ (id) periodWithStartDate:(NSDate *) startDate endDate:(NSDate *) endDate
{
    OKPeriod *result = [[OKPeriod alloc] init];
    
    result.startDate = startDate;
    result.endDate = endDate;
    
    return result;
}

+ (id) oneDayPeriodWithDate:(NSDate *) date
{
    OKPeriod *result = [[OKPeriod alloc] init];
    
    result.startDate = [date dateWithoutTime];
    result.endDate = result.startDate;

    return result;
}

- (BOOL) isEqual:(id) object
{
    if (![object isKindOfClass:[OKPeriod class]])
    {
        return NO;
    }
    
    OKPeriod *period = object;
    return [self.startDate isEqualToDate:period.startDate] 
            && [self.endDate isEqualToDate:period.endDate];
}

- (NSInteger) lengthInDays
{
    return [self.endDate daysSinceDate:self.startDate];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"startDate = %@; endDate = %@", _startDate, _endDate];
}

- (OKPeriod *) normalizedPeriod
{
    OKPeriod *result = [[OKPeriod alloc] init];
    
    if ([_startDate compare:_endDate] == NSOrderedAscending)
    {
        result.startDate = _startDate;
        result.endDate = _endDate;
    }
    else
    {
        result.startDate = _endDate;
        result.endDate = _startDate;
    }
    
    return result;
}

- (BOOL) containsDate:(NSDate *) date
{
    OKPeriod *normalizedPeriod = [self normalizedPeriod];
    
    if (([normalizedPeriod.startDate compare:date] != NSOrderedDescending)
        && ([normalizedPeriod.endDate compare:date] != NSOrderedAscending))
    {
        return YES;
    }
    
    return NO;
}

- (id) copyWithZone:(NSZone *) zone
{
    OKPeriod *copiedPeriod = [[OKPeriod alloc] init];
    copiedPeriod.startDate = [_startDate copyWithZone: zone];
    copiedPeriod.endDate = [_endDate copyWithZone: zone];
    
    return copiedPeriod;
}

@end
