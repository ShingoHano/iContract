//
//  OKPopoverCalendarController.m
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import "OKPopoverCalendarController.h"
#import "OKCalendarBackgroundView.h"
#import "OKCalendarView.h"
#import "OKPeriod.h"
#import "NSDate+CalendarHelper.h"
#import "OKCalendarConstants.h"
#import "OKCalendarHelper.h"
#import "OKDimmingView.h"
#import "OKTheme.h"
#import "OKCalendarConstants.h"

@interface OKPopoverCalendarController ()
{
	UIView *_mainView;
	UIView *_anchorView;
	OKCalendarArrowDirection _savedPermittedArrowDirections;
	UIView *_calendarView;
	OKCalendarBackgroundView *_backgroundView;
	OKCalendarView *_digitsView;
	CGPoint _position;
	OKCalendarArrowDirection _calendarArrowDirection;
	CGPoint _savedArrowPosition;
	UIDeviceOrientation _currentOrientation;
	CGRect _initialFrame;
	CGSize _initialSize;
}
@end

@implementation OKPopoverCalendarController


#pragma mark - object initializers -

- (id) init
{
    return [self initWithSize: [OKThemeEngine sharedInstance].defaultSize];
}

- (id) initWithSize:(CGSize) size
{
	self = [super init];
    if (self) {
		[self initializeWithSize: size];
    }
    
    return self;
}


- (void) initializeWithSize:(CGSize) size
{
    _initialSize = size;
    CGSize arrowSize = kOKThemeArrowSize;
    CGSize outerPadding = kOKThemeOuterPadding;
    _calendarArrowDirection = OKCalendarArrowDirectionUnknown;
    
    _initialFrame = CGRectMake(0
                                 , 0
                                 , size.width + kOKThemeShadowPadding.left + kOKThemeShadowPadding.right
                                 , size.height + kOKThemeShadowPadding.top + kOKThemeShadowPadding.bottom);
    _calendarView = [[UIView alloc] initWithFrame:_initialFrame];
    _calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    //Make insets from two sides of a calendar to have place for arrow
    CGRect calendarRectWithArrowInsets = CGRectMake(0, 0
                                                    , _initialFrame.size.width + arrowSize.height
                                                    , _initialFrame.size.height + arrowSize.height);
    _mainView = [[UIView alloc] initWithFrame:calendarRectWithArrowInsets];

	_backgroundView = [[OKCalendarBackgroundView alloc] initWithFrame:CGRectInset(calendarRectWithArrowInsets
                                                                                      , outerPadding.width
                                                                                      , outerPadding.height)];
    _backgroundView.clipsToBounds = NO;
    [_mainView addSubview:_backgroundView];
    
    _digitsView = [[OKCalendarView alloc] initWithFrame:UIEdgeInsetsInsetRect(CGRectInset(_initialFrame
                                                                                              , kOKThemeInnerPadding.width
                                                                                              , kOKThemeInnerPadding.height)
                                                                                  , kOKThemeShadowPadding)];
    _digitsView.delegate = self;
	
    [_calendarView addSubview:_digitsView];
    [_mainView addSubview:_calendarView];
    
    self.allowsPeriodSelection = YES;
    self.allowsLongPressMonthChange = YES;
}

#pragma mark - rotation handling -

- (void)didRotate:(NSNotification *) notice
{
    if (_anchorView)
    {
        CGRect rectInAppWindow = [self.view convertRect:_anchorView.frame
                                               fromView:_anchorView.superview];

        [UIView animateWithDuration:0.3
                         animations:^{
                             [self adjustCalendarPositionForPermittedArrowDirections:_savedPermittedArrowDirections
                                                                   arrowPointsToRect:rectInAppWindow];
                         }];
    }
}

#pragma mark - controller presenting methods -

- (void) adjustCalendarPositionForPermittedArrowDirections:(OKCalendarArrowDirection)arrowDirections
                                         arrowPointsToRect:(CGRect)rect
{
    CGSize arrowSize = kOKThemeArrowSize;

    if (arrowDirections & OKCalendarArrowDirectionUp)
    {
        if ((CGRectGetMaxY(rect) + self.size.height + arrowSize.height <= self.view.bounds.size.height)
            && (CGRectGetMidX(rect) >= (arrowSize.width / 2 +  kOKThemeCornerRadius + kOKThemeShadowPadding.left))
            && (CGRectGetMidX(rect) <= (self.view.bounds.size.width - arrowSize.width / 2 -  kOKThemeCornerRadius - kOKThemeShadowPadding.right)))
        {
            _calendarArrowDirection = OKCalendarArrowDirectionUp;
        }
    }
    
    if ((_calendarArrowDirection == OKCalendarArrowDirectionUnknown)
        && (arrowDirections & OKCalendarArrowDirectionLeft))
    {
        if ((CGRectGetMidX(rect) + self.size.width + arrowSize.height <= self.view.bounds.size.width)
            && (CGRectGetMidY(rect) >= (arrowSize.width / 2 +  kOKThemeCornerRadius + kOKThemeShadowPadding.top))
            && (CGRectGetMidY(rect) <= (self.view.bounds.size.height - arrowSize.width / 2 -  kOKThemeCornerRadius - kOKThemeShadowPadding.bottom)))
            
        {
            _calendarArrowDirection = OKCalendarArrowDirectionLeft;
        }
    }
    
    if ((_calendarArrowDirection == OKCalendarArrowDirectionUnknown)
        && (arrowDirections & OKCalendarArrowDirectionDown))
    {
        if ((CGRectGetMidY(rect) - self.size.height - arrowSize.height >= 0)
            && (CGRectGetMidX(rect) >= (arrowSize.width / 2 +  kOKThemeCornerRadius + kOKThemeShadowPadding.left))
            && (CGRectGetMidX(rect) <= (self.view.bounds.size.width - arrowSize.width / 2 -  kOKThemeCornerRadius - kOKThemeShadowPadding.right)))
        {
            _calendarArrowDirection = OKCalendarArrowDirectionDown;
        }
    }
    
    if ((_calendarArrowDirection == OKCalendarArrowDirectionUnknown)
        && (arrowDirections & OKCalendarArrowDirectionRight))
    {
        if ((CGRectGetMidX(rect) - self.size.width - arrowSize.height >= 0)
            && (CGRectGetMidY(rect) >= (arrowSize.width / 2 +  kOKThemeCornerRadius + kOKThemeShadowPadding.top))
            && (CGRectGetMidY(rect) <= (self.view.bounds.size.height - arrowSize.width / 2 -  kOKThemeCornerRadius - kOKThemeShadowPadding.bottom)))
        {
            _calendarArrowDirection = OKCalendarArrowDirectionRight;
        }
    }
    
    if (_calendarArrowDirection == OKCalendarArrowDirectionUnknown) // nothing suits
    {
        // TODO: check rect's quad and pick direction automatically
		_calendarArrowDirection = OKCalendarArrowDirectionUp;
    }
    
    CGRect calendarFrame = _mainView.frame;
    CGRect frm = CGRectMake(0
                            , 0
                            , calendarFrame.size.width - arrowSize.height
                            , calendarFrame.size.height - arrowSize.height);
    CGPoint arrowPosition = CGPointZero;
    CGPoint arrowOffset = CGPointZero;
    
    switch (_calendarArrowDirection)
    {
        case OKCalendarArrowDirectionUp:
        case OKCalendarArrowDirectionDown:
            arrowPosition.x = CGRectGetMidX(rect) - kOKThemeShadowPadding.right;
            
            if (arrowPosition.x < frm.size.width / 2)
            {
                calendarFrame.origin.x = 0;
            }
            else if (arrowPosition.x > self.view.bounds.size.width - frm.size.width / 2)
            {
                calendarFrame.origin.x = self.view.bounds.size.width - frm.size.width - kOKThemeShadowPadding.right;
            }
            else
            {
                calendarFrame.origin.x = arrowPosition.x - frm.size.width / 2 + kOKThemeShadowPadding.left;
            }
            
            if (_calendarArrowDirection == OKCalendarArrowDirectionUp)
            {
                arrowOffset.y = arrowSize.height;
                calendarFrame.origin.y = CGRectGetMaxY(rect) - kOKThemeShadowPadding.top;
            }
            else 
            {
                calendarFrame.origin.y = CGRectGetMinY(rect) - _backgroundView.frame.size.height + kOKThemeShadowPadding.bottom;
            }
            
            break;
        case OKCalendarArrowDirectionLeft:
        case OKCalendarArrowDirectionRight:
            arrowPosition.y = CGRectGetMidY(rect) - kOKThemeShadowPadding.top;
            
            if (arrowPosition.y < frm.size.height / 2)
            {
                calendarFrame.origin.y = 0;
            }
            else if (arrowPosition.y > self.view.bounds.size.height - frm.size.height / 2)
            {
                calendarFrame.origin.y = self.view.bounds.size.height - frm.size.height;
            }
            else
            {
                calendarFrame.origin.y = arrowPosition.y - calendarFrame.size.height / 2 + arrowSize.height;
            }
            
            if (_calendarArrowDirection == OKCalendarArrowDirectionLeft)
            {
                arrowOffset.x = arrowSize.height;
                calendarFrame.origin.x = CGRectGetMaxX(rect) - kOKThemeShadowPadding.left;
            }
            else 
            {
                calendarFrame.origin.x = CGRectGetMinX(rect) - calendarFrame.size.width + kOKThemeShadowPadding.right;
            }
            break;
        default:
            NSAssert(NO, @"arrow direction is not set! JACKPOT!! :)");
            break;
    }
    _mainView.frame = calendarFrame;
    frm.origin = CGPointOffsetByPoint(frm.origin, arrowOffset);
    _calendarView.frame = frm;
    
    arrowPosition = [self.view convertPoint:arrowPosition toView:_mainView];
    
    if ((_calendarArrowDirection == OKCalendarArrowDirectionUp)
        || (_calendarArrowDirection == OKCalendarArrowDirectionDown))
    {
        arrowPosition.x = MIN(arrowPosition.x, frm.size.width - arrowSize.width / 2 -  kOKThemeCornerRadius);
        arrowPosition.x = MAX(arrowPosition.x, arrowSize.width / 2 +  kOKThemeCornerRadius);
    }
    else if ((_calendarArrowDirection == OKCalendarArrowDirectionRight)
             || (_calendarArrowDirection == OKCalendarArrowDirectionLeft))
    {
        arrowPosition.y = MIN(arrowPosition.y, frm.size.height - arrowSize.width / 2 -  kOKThemeCornerRadius);
        arrowPosition.y = MAX(arrowPosition.y, arrowSize.width / 2 +  kOKThemeCornerRadius);
    }
    
    _backgroundView.arrowPosition = arrowPosition;
    _savedArrowPosition = arrowPosition;
}


- (void)presentCalendarFromRect:(CGRect) rect
                         inView:(UIView *) view
       permittedArrowDirections:(OKCalendarArrowDirection) arrowDirections
                      isPopover:(BOOL) isPopover
                       animated:(BOOL) animated
{
    if (!isPopover)
    {
        self.view = _mainView;
    }
    else
    {
        self.view = [[OKDimmingView alloc] initWithFrame:view.bounds
                                              controller:self];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_mainView];
    }

    [view addSubview:self.view];

    CGRect rectInAppWindow = [self.view convertRect:rect fromView:view];
    [self adjustCalendarPositionForPermittedArrowDirections:arrowDirections
                                          arrowPointsToRect:rectInAppWindow];
    _initialFrame = CGRectMake(_mainView.frame.origin.x, _mainView.frame.origin.y, _initialSize.width + kOKThemeShadowPadding.left + kOKThemeShadowPadding.right, _initialSize.height+ kOKThemeShadowPadding.top + kOKThemeShadowPadding.bottom);
    [self fullRedraw];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    if (animated)
    {
        _mainView.alpha = 0;
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             _mainView.alpha = 1;
                         }];
    }

    if (!_digitsView.period)
    {
        self.period = [OKPeriod oneDayPeriodWithDate:[NSDate date]];
    }
    
    _calendarVisible = YES;
}

- (void)presentCalendarFromView:(UIView *) anchorView
       permittedArrowDirections:(OKCalendarArrowDirection) arrowDirections
                      isPopover:(BOOL) isPopover
                       animated:(BOOL) animated
{
    _anchorView = anchorView;
    _savedPermittedArrowDirections = arrowDirections;
    
    [self presentCalendarFromRect:anchorView.frame
                           inView:_anchorView.superview
         permittedArrowDirections:arrowDirections
                        isPopover:isPopover
                         animated:animated];
}

- (void) dismissCalendarAnimated:(BOOL) animated
{
    self.view.alpha = 1;
    void (^completionBlock)(BOOL) = ^(BOOL finished){
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.view removeFromSuperview];
        _calendarVisible = NO;
        if ([self.delegate respondsToSelector:@selector(calendarControllerDidDismissCalendar:)])
        {
            [self.delegate calendarControllerDidDismissCalendar:self];
        }
    };
    
    
    if (animated)
    {
        [UIView animateWithDuration:0.2 
                         animations:^{
                             self.view.alpha = 0;
                             _mainView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                         }
                         completion:completionBlock];
    }
    else
    {
        completionBlock(YES);
    }
}

- (void) fullRedraw
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOKCalendarRedrawNotification
                                                        object:nil];
}

- (void)setCalendarArrowDirection:(OKCalendarArrowDirection)calendarArrowDirection
{
    _backgroundView.arrowDirection = calendarArrowDirection;
    _calendarArrowDirection = calendarArrowDirection;
}

#pragma mark - date/period management -

- (BOOL)mondayFirstDayOfWeek
{
    return _digitsView.mondayFirstDayOfWeek;
}

- (void)setMondayFirstDayOfWeek:(BOOL)mondayFirstDayOfWeek
{
    _digitsView.mondayFirstDayOfWeek = mondayFirstDayOfWeek;
}

- (BOOL)allowsPeriodSelection
{
    return _digitsView.allowsPeriodSelection;
}

- (void)setAllowsPeriodSelection:(BOOL)allowsPeriodSelection
{
    _digitsView.allowsPeriodSelection = allowsPeriodSelection;
}

- (BOOL)allowsLongPressMonthChange
{
    return _digitsView.allowsLongPressMonthChange;
}

- (void)setAllowsLongPressMonthChange:(BOOL)allowsLongPressMonthChange
{
    _digitsView.allowsLongPressMonthChange = allowsLongPressMonthChange;
}

- (OKPeriod *) period
{
    return _digitsView.period;
}

- (void) setPeriod:(OKPeriod *) period
{
    _digitsView.period = period;
    _digitsView.currentDate = period.startDate;
}

- (OKPeriod *) allowedPeriod
{
    return _digitsView.allowedPeriod;
}

- (void) setAllowedPeriod:(OKPeriod *) allowedPeriod
{
    _digitsView.allowedPeriod = allowedPeriod;
}

#pragma mark - OKdigitsViewDelegate methods -

- (void) periodChanged:(OKPeriod *) newPeriod
{
    if ([self.delegate respondsToSelector:@selector(calendarController:didChangePeriod:)])
    {
        [self.delegate calendarController:self didChangePeriod:[newPeriod normalizedPeriod]];
    }
}

- (void) currentDateChanged:(NSDate *) currentDate
{
    CGSize arrowSize = kOKThemeArrowSize;
    CGSize outerPadding = kOKThemeOuterPadding;
    
	int numDaysInMonth      = [currentDate numberOfDaysInMonth];
    NSInteger monthStartDay = [[currentDate monthStartDate] weekday];
    numDaysInMonth         += (monthStartDay + (_digitsView.mondayFirstDayOfWeek?5:6)) % 7;
    CGFloat height          = _initialFrame.size.height - outerPadding.height * 2 - arrowSize.height;
    CGFloat vDiff           = (height - kOKThemeHeaderHeight - kOKThemeInnerPadding.height * 2 - kOKThemeShadowPadding.bottom - kOKThemeShadowPadding.top) / ((kOKThemeDayTitlesInHeader)?6:7);
    CGRect frm              = CGRectInset(_initialFrame, outerPadding.width, outerPadding.height);
    int numberOfRows        = ceil((CGFloat)numDaysInMonth / 7);
    frm.size.height         = ceil(((numberOfRows + ((kOKThemeDayTitlesInHeader)?0:1)) * vDiff) + kOKThemeHeaderHeight + kOKThemeInnerPadding.height * 2 + arrowSize.height) + kOKThemeShadowPadding.bottom + kOKThemeShadowPadding.top;
    
    
    if (self.calendarArrowDirection == OKCalendarArrowDirectionDown)
    {
        frm.origin.y += _initialFrame.size.height - frm.size.height;
    }
    
    _mainView.frame = frm;
    [self fullRedraw];
}

- (void)setSize:(CGSize)size
{
    CGRect frm = _mainView.frame;
    frm.size = size;
    _mainView.frame = frm;
    [self fullRedraw];
}

- (CGSize)size
{
    return _mainView.frame.size;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



#pragma mark - Dealloc

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
