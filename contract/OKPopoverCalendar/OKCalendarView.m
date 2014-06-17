//
//  OKCalendarView.m
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import "OKCalendarView.h"
#import "OKDaysView.h"
#import "OKSelectionView.h"
#import "OKPeriod.h"
#import "OKTheme.h"
#import "OKThemeEngine.h"
#import "OKCalendarConstants.h"

@interface OKCalendarView ()
{
	UIFont *_font;
	UITapGestureRecognizer *_tapGestureRecognizer;
	UILongPressGestureRecognizer *_longPressGestureRecognizer;
	UIPanGestureRecognizer *_panGestureRecognizer;
	NSTimer *_longPressTimer;
	NSTimer *_panTimer;
	CGPoint _panPoint;
	OKDaysView *_daysView;
	OKSelectionView *_selectionView;
	CGRect _initialFrame;
	NSInteger _currentMonth;
    NSInteger _currentYear;
    CGRect _leftArrowRect;
    CGRect _rightArrowRect;
    NSInteger _fontSize;
}

@end

@implementation OKCalendarView


- (id)initWithFrame:(CGRect)frame
{
   
	self = [super initWithFrame:frame];
	if (self) {
		_initialFrame = frame;
		self.backgroundColor = [UIColor clearColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.mondayFirstDayOfWeek = NO;
    
		_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandling:)];
		_tapGestureRecognizer.numberOfTapsRequired = 1;
		_tapGestureRecognizer.numberOfTouchesRequired = 1;
		_tapGestureRecognizer.delegate = self;
		[self addGestureRecognizer:_tapGestureRecognizer];
	
		_panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandling:)];
		_panGestureRecognizer.delegate = self;
		[self addGestureRecognizer:_panGestureRecognizer];
    
		self.allowsLongPressMonthChange = NO;
	
	
		_selectionView = [[OKSelectionView alloc] initWithFrame:CGRectInset(self.bounds, -kOKThemeInnerPadding.width, -kOKThemeInnerPadding.height)];
		 [self addSubview:_selectionView];
		
		_daysView = [[OKDaysView alloc] initWithFrame:self.bounds];
		_daysView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_daysView];
    
		[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redrawComponent)
                                                 name:kOKCalendarRedrawNotification
												   object:nil];
    }
	return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)redrawComponent
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:NSLocalizedString(@"ja",nil)];
	[dateFormatter setLocale:locale];
    NSArray *dayTitles = [dateFormatter shortStandaloneWeekdaySymbols];
    NSArray *monthTitles = [dateFormatter standaloneMonthSymbols];
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat headerHeight = kOKThemeHeaderHeight;
    UIEdgeInsets shadowPadding = kOKThemeShadowPadding;
	
    CGFloat width = _initialFrame.size.width;
    CGFloat height = _initialFrame.size.height;
    CGFloat hDiff  = width / 7;
    CGFloat vDiff  = (height - headerHeight) / (kOKThemeDayTitlesInHeaderIntOffset + 5);
    
    UIFont *dayFont = [[[OKThemeEngine sharedInstance] elementOfGenericType:OKThemeFontGenericType
																	subtype:OKThemeMainSubtype
																	   type:OKThemeDayTitlesElementType] okThemeGenerateFont];
    UIFont *monthFont = [[[OKThemeEngine sharedInstance] elementOfGenericType:OKThemeFontGenericType
                                                                      subtype:OKThemeMainSubtype
                                                                         type:OKThemeMonthTitleElementType] okThemeGenerateFont];
	
    for (int i = 0; i < dayTitles.count; i++)
    {
        NSInteger index = i + (_mondayFirstDayOfWeek?1:0);
        index = index % 7;
        NSString *dayTitle = [dayTitles objectAtIndex:index];
        //// dayHeader Drawing
        CGSize sz = [dayTitle sizeWithFont:dayFont];
        CGRect dayHeaderFrame = CGRectMake(floor(i * hDiff) - 1
                                           , headerHeight + (kOKThemeDayTitlesInHeaderIntOffset * vDiff - sz.height) / 2
                                           , hDiff
                                           , sz.height);
		
        [[OKThemeEngine sharedInstance] drawString:dayTitle
                                          withFont:dayFont
                                            inRect:dayHeaderFrame
                                    forElementType:OKThemeDayTitlesElementType
                                           subType:OKThemeMainSubtype
                                         inContext:context];
    }
    
    int month = _currentMonth;
    int year = _currentYear;
    
    NSString *temp=NSLocalizedString(@"年",nil);
	NSString *monthTitle = [NSString stringWithFormat:@"%d%@%@", year,temp,[monthTitles objectAtIndex:(month - 1)]];
    //// Month Header Drawing
    CGRect textFrame = CGRectMake(0
                                  , (headerHeight - [monthTitle sizeWithFont:monthFont].height) / 2
                                  , width
                                  , monthFont.pointSize);
    
    [[OKThemeEngine sharedInstance] drawString:monthTitle
                                      withFont:monthFont
                                        inRect:textFrame
                                forElementType:OKThemeMonthTitleElementType
                                       subType:OKThemeMainSubtype
                                     inContext:context];
    
    
    NSDictionary *arrowSizeDict = [[OKThemeEngine sharedInstance] elementOfGenericType:OKThemeSizeGenericType
                                                                               subtype:OKThemeMainSubtype
                                                                                  type:OKThemeMonthArrowsElementType];
	
    NSDictionary *arrowOffsetDict = [[OKThemeEngine sharedInstance] elementOfGenericType:OKThemeOffsetGenericType
                                                                                 subtype:OKThemeMainSubtype
                                                                                    type:OKThemeMonthArrowsElementType];
	
    CGSize arrowSize = [arrowSizeDict okThemeGenerateSize];
    CGSize arrowOffset = [arrowOffsetDict okThemeGenerateSize];
    BOOL showsLeftArrow = YES;
    BOOL showsRightArrow = YES;
    
    if (self.allowedPeriod)
    {
        if ([[_currentDate dateByAddingMonths:-1] isBefore:[self.allowedPeriod.startDate monthStartDate]])
        {
            showsLeftArrow = NO;
        }
        else if ([[_currentDate dateByAddingMonths:1] isAfter:self.allowedPeriod.endDate])
        {
            showsRightArrow = NO;
        }
    }
	
    if (showsLeftArrow)
    {
        //// backArrow Drawing
        UIBezierPath* backArrowPath = [UIBezierPath bezierPath];
        [backArrowPath moveToPoint: CGPointMake(hDiff / 2
                                                , headerHeight / 2)]; // left-center corner
        [backArrowPath addLineToPoint: CGPointMake(arrowSize.width + hDiff / 2
                                                   , headerHeight / 2 + arrowSize.height / 2)]; // right-bottom corner
        [backArrowPath addLineToPoint: CGPointMake( arrowSize.width + hDiff / 2
                                                   ,  headerHeight / 2 - arrowSize.height / 2)]; // right-top corner
        [backArrowPath addLineToPoint: CGPointMake( hDiff / 2
                                                   ,  headerHeight / 2)];  // back to left-center corner
        [backArrowPath closePath];
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(arrowOffset.width - shadowPadding.left
                                                                       , arrowOffset.height);
        [backArrowPath applyTransform:transform];
		
        [[OKThemeEngine sharedInstance] drawPath:backArrowPath
                                  forElementType:OKThemeMonthArrowsElementType
                                         subType:OKThemeMainSubtype
                                       inContext:context];
        _leftArrowRect = CGRectInset(backArrowPath.bounds, -20, -20);
    }
	
    if (showsRightArrow)
    {
        //// forwardArrow Drawing
        UIBezierPath* forwardArrowPath = [UIBezierPath bezierPath];
        [forwardArrowPath moveToPoint: CGPointMake( width - hDiff / 2
                                                   ,  headerHeight / 2)]; // right-center corner
        [forwardArrowPath addLineToPoint: CGPointMake( -arrowSize.width + width - hDiff / 2
                                                      , headerHeight / 2 + arrowSize.height / 2)];  // left-bottom corner
        [forwardArrowPath addLineToPoint: CGPointMake(-arrowSize.width + width - hDiff / 2
													  , headerHeight / 2 - arrowSize.height / 2)]; // left-top corner
        [forwardArrowPath addLineToPoint: CGPointMake( width - hDiff / 2
                                                      , headerHeight / 2)]; // back to right-center corner
        [forwardArrowPath closePath];
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-arrowOffset.width - shadowPadding.left, arrowOffset.height);
        [forwardArrowPath applyTransform:transform];
		
        [[OKThemeEngine sharedInstance] drawPath:forwardArrowPath
                                  forElementType:OKThemeMonthArrowsElementType
                                         subType:OKThemeMainSubtype
                                       inContext:context];
        _rightArrowRect = CGRectInset(forwardArrowPath.bounds, -20, -20);
    }
}

- (void) setCurrentDate:(NSDate *)currentDate
{
    if (self.allowedPeriod)
    {
        if (([currentDate isBefore:[self.allowedPeriod.startDate monthStartDate]])
            || ([currentDate isAfter:self.allowedPeriod.endDate]))
        {
            return;
        }
    }
    
    _currentDate = [currentDate monthStartDate];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *eComponents = [gregorian components:NSDayCalendarUnit
									 | NSMonthCalendarUnit
									 | NSYearCalendarUnit
                                                 fromDate:_currentDate];
    
    BOOL needsRedraw = NO;
    
    if([eComponents month] != _currentMonth)
    {
        _currentMonth = [eComponents month];
        needsRedraw = YES;
    }
    if([eComponents year] != _currentYear)
    {
        _currentYear = [eComponents year];
        needsRedraw = YES;
    }
    
    if (needsRedraw)
    {
        _daysView.currentDate = currentDate;
        [self setNeedsDisplay];
        [self periodUpdated];
        if ([_delegate respondsToSelector:@selector(currentDateChanged:)])
        {
            [_delegate currentDateChanged:currentDate];
        }
    }
}

- (void)setMondayFirstDayOfWeek:(BOOL)mondayFirstDayOfWeek
{
    if (_mondayFirstDayOfWeek != mondayFirstDayOfWeek)
    {
        _mondayFirstDayOfWeek = mondayFirstDayOfWeek;
        _daysView.mondayFirstDayOfWeek = mondayFirstDayOfWeek;
        [self setNeedsDisplay];
        [self periodUpdated];
        
        // Ugh... TODO: make other components redraw in more acceptable way
        if ([_delegate respondsToSelector:@selector(currentDateChanged:)])
        {
            [_delegate currentDateChanged:_currentDate];
        }
    }
}

- (UIFont *) font
{
    NSInteger newFontSize = _initialFrame.size.width / 20;
    if (!_font || _fontSize == 0 || _fontSize != newFontSize)
    {
        _font = [UIFont fontWithName: @"Helvetica" size: newFontSize];
        _daysView.font = _font;
        _fontSize = newFontSize;
    }
    return _font;
}

- (void) periodUpdated
{
    NSInteger index = [self indexForDate:_period.startDate];
    NSInteger length = [_period lengthInDays];
    
    int numDaysInMonth      = [_currentDate numberOfDaysInMonth];
    NSDate *monthStartDate  = [_currentDate monthStartDate];
    NSInteger monthStartDay = [monthStartDate weekday];
    monthStartDay           = (monthStartDay + (self.mondayFirstDayOfWeek?5:6)) % 7;
    numDaysInMonth         += monthStartDay;
    int maxNumberOfCells    = ceil((CGFloat)numDaysInMonth / 7) * 7 - 1;
	
    NSInteger endIndex = -1;
    NSInteger startIndex = -1;
    if (index <= maxNumberOfCells || index + length <= maxNumberOfCells)
    {
        endIndex = MIN( maxNumberOfCells, index + length );
        startIndex = MIN( maxNumberOfCells, index );
    }
	
    [_selectionView setStartIndex:startIndex];
    [_selectionView setEndIndex:endIndex];
    _daysView.selectedPeriod = _period;
    [_daysView redrawComponent];
}

- (void)setAllowedPeriod:(OKPeriod *)allowedPeriod
{
    if (allowedPeriod != _allowedPeriod)
    {
        _allowedPeriod = allowedPeriod;
        _allowedPeriod.startDate = [_allowedPeriod.startDate midnightDate];
        _allowedPeriod.endDate = [_allowedPeriod.endDate midnightDate];
    }
}

- (void)setPeriod:(OKPeriod *)period
{
    OKPeriod *localPeriod = [period copy];
    if (self.allowedPeriod)
    {
        if ([localPeriod.startDate isBefore:self.allowedPeriod.startDate])
        {
            localPeriod.startDate = self.allowedPeriod.startDate;
        }
        else if ([localPeriod.startDate isAfter:self.allowedPeriod.endDate])
        {
            localPeriod.startDate = self.allowedPeriod.endDate;
        }
		
        if ([localPeriod.endDate isBefore:self.allowedPeriod.startDate])
        {
            localPeriod.endDate = self.allowedPeriod.startDate;
        }
        else if ([localPeriod.endDate isAfter:self.allowedPeriod.endDate])
        {
            localPeriod.endDate = self.allowedPeriod.endDate;
        }
    }
	
    if (![_period isEqual:localPeriod])
    {
        _period = localPeriod;
        
        if (!_currentDate)
        {
            self.currentDate = period.startDate;
        }
        
        if ([self.delegate respondsToSelector:@selector(periodChanged:)])
        {
            [self.delegate periodChanged:_period];
        }
		
        [self periodUpdated];
    }
}

#pragma mark - Touches handling -

- (NSInteger) indexForDate: (NSDate *)date
{
    NSDate *monthStartDate  = [_currentDate monthStartDate];
    NSInteger monthStartDay = [monthStartDate weekday];
    monthStartDay           = (monthStartDay + (self.mondayFirstDayOfWeek?5:6)) % 7;
	
    NSInteger daysSinceMonthStart = [date daysSinceDate:monthStartDate];
    return daysSinceMonthStart + monthStartDay;
}

- (NSDate *) dateForPoint: (CGPoint)point
{
    CGFloat width  = _initialFrame.size.width;
    CGFloat height = _initialFrame.size.height;
    CGFloat hDiff  = width / 7;
    CGFloat vDiff  = (height - kOKThemeHeaderHeight) / ((kOKThemeDayTitlesInHeader)?6:7);
    
    CGFloat yInCalendar = point.y - (kOKThemeHeaderHeight + ((kOKThemeDayTitlesInHeader)?0:vDiff));
    NSInteger row = yInCalendar / vDiff;
    
    int numDaysInMonth      = [_currentDate numberOfDaysInMonth];
    NSDate *monthStartDate  = [_currentDate monthStartDate];
    NSInteger monthStartDay = [monthStartDate weekday];
    monthStartDay           = (monthStartDay + (self.mondayFirstDayOfWeek?5:6)) % 7;
    numDaysInMonth         += monthStartDay;
    int maxNumberOfRows     = ceil((CGFloat)numDaysInMonth / 7) - 1;
    
    row = MAX(0, MIN(row, maxNumberOfRows));
    
    CGFloat xInCalendar = point.x - 2;
    NSInteger col       = xInCalendar / hDiff;
    
    col = MAX(0, MIN(col, 6));
    
    NSInteger days = row * 7 + col - monthStartDay;
    NSDate *selectedDate = [monthStartDate dateByAddingDays:days];
	
    return selectedDate;
}

- (void) periodSelectionStarted: (CGPoint) point
{
    self.period = [OKPeriod oneDayPeriodWithDate:[self dateForPoint:point]];
}

- (void) periodSelectionChanged: (CGPoint) point
{
    NSDate *newDate = [self dateForPoint:point];
    
    if (_allowsPeriodSelection)
    {
        self.period = [OKPeriod periodWithStartDate:self.period.startDate
                                            endDate:newDate];
    }
    else
    {
        self.period = [OKPeriod oneDayPeriodWithDate:newDate];
    }
}

- (void) panTimerCallback: (NSTimer *)timer
{
    NSNumber *increment = timer.userInfo;
    
    [self setCurrentDate:[self.currentDate dateByAddingMonths:[increment intValue]]];
    [self periodSelectionChanged:_panPoint];
}

- (void) panHandling: (UIGestureRecognizer *)recognizer
{
    /*CGPoint point  = [recognizer locationInView:self];
	 
	 CGFloat height = _initialFrame.size.height;
	 CGFloat vDiff  = (height - kOKThemeHeaderHeight) / ((kOKThemeDayTitlesInHeader)?6:7);
	 
	 if (point.y > kOKThemeHeaderHeight + ((kOKThemeDayTitlesInHeader)?0:vDiff)) // select date in calendar
	 {
	 if (([recognizer state] == UIGestureRecognizerStateBegan) && (recognizer.numberOfTouches == 1))
	 {
	 [self periodSelectionStarted:point];
	 }
	 else if (([recognizer state] == UIGestureRecognizerStateChanged) && (recognizer.numberOfTouches == 1))
	 {
	 if ((point.x < 20) || (point.x > _initialFrame.size.width - 20))
	 {
	 self.panPoint = point;
	 if (self.panTimer)
	 {
	 return;
	 }
	 
	 NSNumber *increment = [NSNumber numberWithInt:1];
	 if (point.x < 20)
	 {
	 increment = [NSNumber numberWithInt:-1];
	 }
	 
	 self.panTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
	 target:self
	 selector:@selector(panTimerCallback:)
	 userInfo:increment
	 repeats:YES];
	 }
	 else
	 {
	 [self.panTimer invalidate];
	 self.panTimer = nil;
	 }
	 
	 [self periodSelectionChanged:point];
	 }
	 }
	 
	 if (([recognizer state] == UIGestureRecognizerStateEnded)
	 || ([recognizer state] == UIGestureRecognizerStateCancelled)
	 || ([recognizer state] == UIGestureRecognizerStateFailed))
	 {
	 [self.panTimer invalidate];
	 self.panTimer = nil;
	 }*/
}

- (void) tapHandling: (UIGestureRecognizer *)recognizer
{
    CGPoint point  = [recognizer locationInView:self];
    
    CGFloat height = _initialFrame.size.height;
    CGFloat vDiff  = (height - kOKThemeHeaderHeight) / ((kOKThemeDayTitlesInHeader)?6:7);
	
    if (point.y > kOKThemeHeaderHeight + ((kOKThemeDayTitlesInHeader)?0:vDiff)) // select date in calendar
    {
        [self periodSelectionStarted:point];
		//[self.pmCalendar dismissCalendarAnimated:YES];

		return;
    }
    
    if(CGRectContainsPoint(_leftArrowRect, point))
    {
        //User tapped the prevMonth button
        [self setCurrentDate:[self.currentDate dateByAddingMonths:-1]];
    }
    else if(CGRectContainsPoint(_rightArrowRect, point))
    {
        //User tapped the nextMonth button
        [self setCurrentDate:[self.currentDate dateByAddingMonths:1]];
    }
}

- (void) longPressTimerCallback: (NSTimer *)timer
{
    NSNumber *increment = timer.userInfo;
    [self setCurrentDate:[self.currentDate dateByAddingMonths:[increment intValue]]];
}

- (void) longPressHandling: (UIGestureRecognizer *)recognizer
{
    if (([recognizer state] == UIGestureRecognizerStateBegan) && (recognizer.numberOfTouches == 1))
    {
        if (_longPressTimer)
        {
            return;
        }
		
        CGPoint point = [recognizer locationInView:self];
        CGFloat height = _initialFrame.size.height;
        CGFloat vDiff  = (height - kOKThemeHeaderHeight) / ((kOKThemeDayTitlesInHeader)?6:7);
        
        if (point.y > kOKThemeHeaderHeight + ((kOKThemeDayTitlesInHeader)?0:vDiff)) // select date in calendar
        {
            [self periodSelectionChanged:point];
            return;
        }
		
        NSNumber *increment = nil;
        if(CGRectContainsPoint(_leftArrowRect, point))
        {
            //User tapped the prevMonth button
            increment = [NSNumber numberWithInt:-1];
        }
        else if(CGRectContainsPoint(_rightArrowRect, point))
        {
            //User tapped the nextMonth button
            increment = [NSNumber numberWithInt:1];
        }
		
        if (increment)
        {
			_longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.15f
                                                                   target:self
                                                                 selector:@selector(longPressTimerCallback:)
                                                                 userInfo:increment
                                                                  repeats:YES];
        }
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        if (_longPressTimer)
        {
            return;
        }
		
        CGPoint point = [recognizer locationInView:self];
        [self periodSelectionChanged:point];
    }
    else if (([recognizer state] == UIGestureRecognizerStateCancelled)
             || ([recognizer state] == UIGestureRecognizerStateEnded) )
    {
        if (_longPressTimer)
        {
            [_longPressTimer invalidate];
            _longPressTimer = nil;
        }
    }
}

- (void)setAllowsLongPressMonthChange:(BOOL)allowsLongPressMonthChange
{
    if (!allowsLongPressMonthChange)
    {
        if (_longPressGestureRecognizer)
        {
            [self removeGestureRecognizer:_longPressGestureRecognizer];
            _longPressGestureRecognizer = nil;
        }
    }
    else if (!_longPressGestureRecognizer)
    {
		/*  self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
		 action:@selector(longPressHandling:)];
		 self.longPressGestureRecognizer.numberOfTouchesRequired = 1;
		 self.longPressGestureRecognizer.delegate = self;
		 self.longPressGestureRecognizer.minimumPressDuration = 0.5;
		 [self addGestureRecognizer:self.longPressGestureRecognizer];*/
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end