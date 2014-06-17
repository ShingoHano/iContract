//
//  OKDaysView.m
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import "OKDaysView.h"
#import "NSDate+CalendarHelper.h"
#import "OKTheme.h"
#import "OKPeriod.h"
#import "OKCalendarConstants.h"

@implementation OKDaysView


- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
    
	if (self) {
		self.initialFrame = frame;
	
		self.backgroundColor = [UIColor clearColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(redrawComponent)
													 name:kOKCalendarRedrawNotification
												   object:nil];
		
		NSMutableArray *tmpRects   = [NSMutableArray arrayWithCapacity:42];
		CGFloat headerHeight       = kOKThemeHeaderHeight;
		UIFont *calendarFont       = kOKThemeDefaultFont;
		
		CGFloat width  = _initialFrame.size.width;
		CGFloat hDiff  = width / 7;
		CGFloat height = _initialFrame.size.height;
		CGFloat vDiff  = (height - headerHeight) / (kOKThemeDayTitlesInHeaderIntOffset + 6);
		CGSize shadow2Offset = CGSizeMake(1, 1); // TODO: remove!
		
		for (NSInteger i = 0; i < 42; i++)
		{
			CGRect rect = CGRectMake(ceil((i % 7) * hDiff)
									 , headerHeight + ((int)(i / 7) + kOKThemeDayTitlesInHeaderIntOffset) * vDiff
									 + (vDiff - calendarFont.pointSize) / 2 - shadow2Offset.height
									 , hDiff
									 , calendarFont.pointSize);
			[tmpRects addObject:NSStringFromCGRect(rect)];
		}
		
		self.rects = [NSArray arrayWithArray:tmpRects];
	}
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context       = UIGraphicsGetCurrentContext();
    UIFont *calendarFont       = [UIFont boldSystemFontOfSize:24.0f];
    UIEdgeInsets shadowPadding = UIEdgeInsetsMake(0.0f, 0.0f, 10.0f, 0.0f);
	CGFloat headerHeight       = 45.0f;
    // digits drawing
	NSDate *dateOnFirst = [_currentDate monthStartDate];
	int weekdayOfFirst = ([dateOnFirst weekday] + (_mondayFirstDayOfWeek?5:6)) % 7 + 1;
	int numDaysInMonth = [dateOnFirst numberOfDaysInMonth];
    NSDate *monthStartDate = [_currentDate monthStartDate];
    int todayIndex = [[[NSDate date] dateWithoutTime] daysSinceDate:monthStartDate] + weekdayOfFirst - 1;
	
    NSDate *prevDateOnFirst = [[_currentDate dateByAddingMonths:-1] monthStartDate];
    int numDaysInPrevMonth = [prevDateOnFirst numberOfDaysInMonth];
    NSDate *firstDateInCal = [monthStartDate dateByAddingDays:(-weekdayOfFirst + 1)];
    
	int selectionStartIndex = [[_selectedPeriod normalizedPeriod].startDate daysSinceDate:firstDateInCal];
    int selectionEndIndex = [[_selectedPeriod normalizedPeriod].endDate daysSinceDate:firstDateInCal];
    NSDictionary *todayBGDict = [[OKThemeEngine sharedInstance] themeDictForType:OKThemeCalendarDigitsTodayElementType
                                                                         subtype:OKThemeBackgroundSubtype];
    NSDictionary *todaySelectedBGDict = [[OKThemeEngine sharedInstance] themeDictForType:OKThemeCalendarDigitsTodaySelectedElementType
                                                                                 subtype:OKThemeBackgroundSubtype];
    NSDictionary *inactiveSelectedDict = [[OKThemeEngine sharedInstance] themeDictForType:OKThemeCalendarDigitsInactiveSelectedElementType
                                                                                  subtype:OKThemeMainSubtype];
    NSDictionary *todaySelectedDict = [[OKThemeEngine sharedInstance] themeDictForType:OKThemeCalendarDigitsTodaySelectedElementType
                                                                               subtype:OKThemeMainSubtype];
    NSDictionary *activeSelectedDict = [[OKThemeEngine sharedInstance] themeDictForType:OKThemeCalendarDigitsActiveSelectedElementType
                                                                                subtype:OKThemeMainSubtype];
	
    //Draw the text for each of those days.
    for(int i = 0; i <= weekdayOfFirst-2; i++)
    {
        int day = numDaysInPrevMonth - weekdayOfFirst + 2 + i;
        BOOL selected = (i >= selectionStartIndex) && (i <= selectionEndIndex);
        BOOL isToday = (i == todayIndex);
		
        NSString *string = [NSString stringWithFormat:@"%d", day];
        CGRect dayHeader2Frame = CGRectFromString([self.rects objectAtIndex:i]);
        
        OKThemeElementType type = OKThemeCalendarDigitsInactiveElementType;
        
        if (isToday)
        {
            type = OKThemeCalendarDigitsTodayElementType;
            if (selected && todaySelectedDict)
            {
                type = OKThemeCalendarDigitsTodaySelectedElementType;
            }
        }
        else if (selected && inactiveSelectedDict)
        {
            type = OKThemeCalendarDigitsInactiveSelectedElementType;
        }
		
        [[OKThemeEngine sharedInstance] drawString:string
                                          withFont:calendarFont
                                            inRect:dayHeader2Frame
                                    forElementType:type
                                           subType:OKThemeMainSubtype
                                         inContext:context];
    }
	
	int day         = 1;
	
	for (int i = 0; i < 6; i++)
    {
		for(int j = 0; j < 7; j++)
        {
			int dayNumber = i * 7 + j;
			
			if (dayNumber >= (weekdayOfFirst-1) && day <= numDaysInMonth)
            {
                NSString *string = [NSString stringWithFormat:@"%d", day];
                CGRect dayHeader2Frame = CGRectFromString([self.rects objectAtIndex:dayNumber]);
                BOOL selected = (dayNumber >= selectionStartIndex) && (dayNumber <= selectionEndIndex);
                BOOL isToday = (dayNumber == todayIndex);
				
                if(isToday)
                {
                    
                    if (todayBGDict)
                    {
						
                        CGFloat width  = _initialFrame.size.width + shadowPadding.left + shadowPadding.right;
                        CGFloat height = _initialFrame.size.height;
                        CGFloat hDiff = (width + shadowPadding.left + shadowPadding.right - kOKThemeInnerPadding.width * 2) / 7;
                        CGFloat vDiff = (height - kOKThemeHeaderHeight - kOKThemeInnerPadding.height * 2) / ((kOKThemeDayTitlesInHeader)?6:7);
                        CGSize bgOffset = [[todayBGDict elementInThemeDictOfGenericType:OKThemeOffsetGenericType] okThemeGenerateSize];
                        
                        NSString *coordinatesRound = [todayBGDict elementInThemeDictOfGenericType:OKThemeCoordinatesRoundGenericType];
                        
                        if (coordinatesRound)
                        {
                            if ([coordinatesRound isEqualToString:@"ceil"])
                            {
                                hDiff = ceil(hDiff);
                                vDiff = ceil(vDiff);
                            }
                            else if ([coordinatesRound isEqualToString:@"floor"])
                            {
                                hDiff = floor(hDiff);
                                vDiff = floor(vDiff);
                            }
                        }
						
                        CGRect rect = CGRectMake(floor(j * hDiff) + bgOffset.width
                                                 , headerHeight + (i + kOKThemeDayTitlesInHeaderIntOffset) * vDiff + bgOffset.height
                                                 , floor(hDiff)
                                                 , vDiff);
                        OKThemeElementType type = OKThemeCalendarDigitsTodayElementType;
                        
                        if (selected && todaySelectedBGDict)
                        {
                            type = OKThemeCalendarDigitsTodaySelectedElementType;
                        }
						
                        UIEdgeInsets rectInset = [[[OKThemeEngine sharedInstance] elementOfGenericType:OKThemeEdgeInsetsGenericType
                                                                                               subtype:OKThemeBackgroundSubtype
                                                                                                  type:type] okThemeGenerateEdgeInsets];
						
                        UIBezierPath* selectedRectPath = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(rect, rectInset)
                                                                                    cornerRadius:0];
                        
						
                        [[OKThemeEngine sharedInstance] drawPath:selectedRectPath
                                                  forElementType:type
                                                         subType:OKThemeBackgroundSubtype
                                                       inContext:context];
                    }
                }
                
                OKThemeElementType type = OKThemeCalendarDigitsActiveElementType;
                
                if (isToday)
                {
                    type = OKThemeCalendarDigitsTodayElementType;
                    if (selected && todaySelectedDict)
                    {
                        type = OKThemeCalendarDigitsTodaySelectedElementType;
                    }
                }
                else if (selected && activeSelectedDict)
                {
                    type = OKThemeCalendarDigitsActiveSelectedElementType;
                }
				
                [[OKThemeEngine sharedInstance] drawString:string
                                                  withFont:calendarFont
                                                    inRect:dayHeader2Frame
                                            forElementType:type
                                                   subType:OKThemeMainSubtype
                                                 inContext:context];
                
				++day;
			}
		}
	}
	
    int weekdayOfNextFirst = (weekdayOfFirst - 1 + numDaysInMonth) % 7;
    
    if( weekdayOfNextFirst > 0 )
    {
        //Draw the text for each of those days.
        for ( int i = weekdayOfNextFirst; i < 7; i++ )
        {
            int index = numDaysInMonth + weekdayOfFirst + i - weekdayOfNextFirst - 1;
            int day = i - weekdayOfNextFirst + 1;
            BOOL isToday = (numDaysInMonth + day - 1 == todayIndex);
            BOOL selected = (index >= selectionStartIndex) && (index <= selectionEndIndex);
            NSString *string = [NSString stringWithFormat:@"%d", day];
            CGRect dayHeader2Frame = CGRectFromString([self.rects objectAtIndex:index]);
            
            OKThemeElementType type = OKThemeCalendarDigitsInactiveElementType;
            
            if (isToday)
            {
                type = OKThemeCalendarDigitsTodayElementType;
                if (selected && todaySelectedDict)
                {
                    type = OKThemeCalendarDigitsTodaySelectedElementType;
                }
            }
            else if (selected && inactiveSelectedDict)
            {
                type = OKThemeCalendarDigitsInactiveSelectedElementType;
            }
            
            [[OKThemeEngine sharedInstance] drawString:string
                                              withFont:calendarFont
                                                inRect:dayHeader2Frame
                                        forElementType:type
                                               subType:OKThemeMainSubtype
                                             inContext:context];
        }
    }
}

- (void) setCurrentDate:(NSDate *)currentDate
{
    if (![_currentDate isEqualToDate:currentDate])
    {
        _currentDate = currentDate;
        [self setNeedsDisplay];
	}
}

- (void)setMondayFirstDayOfWeek:(BOOL)mondayFirstDayOfWeek
{
    if (_mondayFirstDayOfWeek != mondayFirstDayOfWeek)
    {
        _mondayFirstDayOfWeek = mondayFirstDayOfWeek;
        [self setNeedsDisplay];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)redrawComponent
{
    [self setNeedsDisplay];
}

@end
