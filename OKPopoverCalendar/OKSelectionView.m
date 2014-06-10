//
//  OKSelectionView.m
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import "OKSelectionView.h"
#import "OKCalendarConstants.h"
#import "OKTheme.h"

@interface OKSelectionView ()
{
	CGRect _initialFrame;
}

@end

@implementation OKSelectionView


- (void)redrawComponent
{
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) 
    {
        return nil;
    }    
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redrawComponent)
                                                 name:kOKCalendarRedrawNotification
                                               object:nil];
    self.backgroundColor = [UIColor clearColor];
    _initialFrame = frame;
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if((_startIndex >= 0) || (_endIndex >= 0)) 
    {
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGFloat cornerRadius = [[[OKThemeEngine sharedInstance] elementOfGenericType:OKThemeCornerRadiusGenericType
                                                                             subtype:OKThemeBackgroundSubtype
                                                                                type:OKThemeSelectionElementType] floatValue];

        CGSize innerPadding        = kOKThemeInnerPadding;
        CGFloat headerHeight       = kOKThemeHeaderHeight;
        
        CGFloat width  = _initialFrame.size.width;
        CGFloat height = _initialFrame.size.height;
        CGFloat hDiff = (width - innerPadding.width * 2) / 7;
        CGFloat vDiff = (height - headerHeight - innerPadding.height * 2) / (kOKThemeDayTitlesInHeaderIntOffset + 6);


        NSString *coordinatesRound = [[OKThemeEngine sharedInstance] elementOfGenericType:OKThemeCoordinatesRoundGenericType
                                                                                  subtype:OKThemeBackgroundSubtype
                                                                                     type:OKThemeSelectionElementType];

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

        int tempStart = MAX(MIN(_startIndex, _endIndex), 0);
        int tempEnd = MAX(_startIndex, _endIndex);
        
        int rowStart = tempStart / 7;
        int rowEnd = tempEnd / 7;
        int colStart = tempStart % 7;
        int colEnd = tempEnd % 7;
        UIEdgeInsets rectInset = [[[OKThemeEngine sharedInstance] elementOfGenericType:OKThemeEdgeInsetsGenericType
                                                                               subtype:OKThemeBackgroundSubtype
                                                                                  type:OKThemeSelectionElementType] okThemeGenerateEdgeInsets];
        
        for (int i = rowStart; i <= rowEnd; i++)
        {
            //// selectedRect Drawing
            int thisRowStartCell = 0;
            int thisRowEndCell = 6;
            
            if (rowStart == i) 
            {
                thisRowStartCell = colStart;
            }
            
            if (rowEnd == i) 
            {
                thisRowEndCell = colEnd;
            } 

            //// selectedRect Drawing
            CGRect rect = CGRectMake(innerPadding.width + floor(thisRowStartCell * hDiff)
                                     , innerPadding.height + headerHeight
                                            + floor((i + kOKThemeDayTitlesInHeaderIntOffset) * vDiff)
                                     , floor((thisRowEndCell - thisRowStartCell + 1) * hDiff)
                                     , floor(vDiff));
            rect = UIEdgeInsetsInsetRect(rect, rectInset);

            UIBezierPath* selectedRectPath = [UIBezierPath bezierPathWithRoundedRect: rect
                                                                        cornerRadius: cornerRadius];
            [[OKThemeEngine sharedInstance] drawPath: selectedRectPath
                                      forElementType: OKThemeSelectionElementType
                                             subType: OKThemeBackgroundSubtype
                                           inContext: context];
        }
    }
}

- (void)setStartIndex:(NSInteger)startIndex
{
    if (_startIndex != startIndex)
    {
        _startIndex = startIndex;
        [self setNeedsDisplay];
    }
}

- (void)setEndIndex:(NSInteger)endIndex
{
    if (_endIndex != endIndex)
    {
        _endIndex = endIndex;
        [self setNeedsDisplay];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
