//
//  OKCalendarBacgroundView.m
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import "OKCalendarBackgroundView.h"
#import "OKCalendarConstants.h"
#import "OKCalendarHelper.h"
#import "OKThemeShadow.h"
#import "OKTheme.h"
#import "OKCalendarConstants.h"

@interface OKCalendarBackgroundView ()
{
	CGRect _initialFrame;
}

@end

@implementation OKCalendarBackgroundView


#pragma mark - UIView overridden methods -


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

#pragma mark - component drawing management -

- (void)redrawComponent
{
    [self setNeedsDisplay];
}

// Returns background bezier path with arrow pointing to a given 
// arrowDirection and arrowPosition (top corner of a triangle).
+ (UIBezierPath*) createBezierPathForSize:(CGSize) size
                           arrowDirection:(OKCalendarArrowDirection)direction
                            arrowPosition:(CGPoint)arrowPosition
{
    CGSize arrowSize = kOKThemeArrowSize;
    UIBezierPath* result = nil;
    CGFloat width = size.width;
    CGFloat height = size.height;
    UIEdgeInsets shadowPadding = kOKThemeShadowPadding;
    CGFloat cornerRadius = kOKThemeCornerRadius;
    width -= shadowPadding.left + shadowPadding.right;
    height -= shadowPadding.top + shadowPadding.bottom;

    if (arrowSize.height == 0)
    {
        CGRect pathRect = CGRectMake(shadowPadding.top
                                     , shadowPadding.left
                                     , width
                                     , height);
        
        if (cornerRadius > 0)
        {
            result = [UIBezierPath bezierPathWithRoundedRect:pathRect
                                                cornerRadius:cornerRadius];
        }
        else
        {
            result = [UIBezierPath bezierPathWithRect:pathRect];
        }
        
        return result;
    }
    
    result = [UIBezierPath bezierPath];
    CGPoint startArrowPoint = CGPointZero;
    CGPoint endArrowPoint = CGPointZero;
    CGPoint topArrowPoint = CGPointZero;
    CGPoint offset = CGPointMake(shadowPadding.top, shadowPadding.left);
    CGPoint tl = CGPointZero;

    switch (direction) 
    {
        case OKCalendarArrowDirectionUp: // going from right side to the left
                                         // so start point is a bottom RIGHT point of a triangle ^. this one :)
            startArrowPoint = CGPointMake(arrowSize.width / 2, arrowSize.height);
            endArrowPoint = CGPointMake(-arrowSize.width / 2, arrowSize.height);
            offset = CGPointOffset(offset, arrowPosition.x, 0);
            tl.y = arrowSize.height;
            break;
        case OKCalendarArrowDirectionDown: // going from left to right
                                           // so start point is a top LEFT point of a triangle - 'V
            startArrowPoint = CGPointMake(-arrowSize.width / 2, -arrowSize.height);
            endArrowPoint = CGPointMake(arrowSize.width / 2, -arrowSize.height);
            offset = CGPointOffset(offset, arrowPosition.x, height + arrowSize.height);
            break;
        case OKCalendarArrowDirectionLeft: // going from top to bottom
                                            // so start point is a top RIGHT point of a triangle - <'
            startArrowPoint = CGPointMake(arrowSize.height, -arrowSize.width / 2);
            endArrowPoint = CGPointMake(arrowSize.height, arrowSize.width / 2);
            offset = CGPointOffset(offset, 0, arrowPosition.y);
            tl.x = arrowSize.height;
            break;
        case OKCalendarArrowDirectionRight: // going from bottom to top
                                            // so start point is a bottom RIGHT point of a triangle - .>
            startArrowPoint = CGPointMake(-arrowSize.height, arrowSize.width / 2);
            endArrowPoint = CGPointMake(-arrowSize.height, -arrowSize.width / 2);
            offset = CGPointOffset(offset, width + arrowSize.height, arrowPosition.y);
            break;
            
        default:
            break;
    }
    
    startArrowPoint = CGPointOffsetByPoint(startArrowPoint, offset);
    endArrowPoint = CGPointOffsetByPoint(endArrowPoint, offset);
    topArrowPoint = CGPointOffsetByPoint(topArrowPoint, offset);
        
    void (^createBezierArrow)(void) = ^{
        [result addLineToPoint: startArrowPoint];
        [result addLineToPoint: topArrowPoint];
        [result addLineToPoint: endArrowPoint];
    };
    
    // starting from bottom-left corner
    [result moveToPoint: CGPointMake(tl.x + shadowPadding.left
                                     , tl.y + shadowPadding.top + height - cornerRadius)];
    // creating arc to a bottom line
    [result addArcWithCenter:CGPointMake(tl.x + shadowPadding.left + cornerRadius
                                         , tl.y + shadowPadding.top + height - cornerRadius) 
                      radius:cornerRadius 
                  startAngle:radians(180) 
                    endAngle:radians(90)
                   clockwise:NO];
    // checking if we have an arrow on a bottom of the background
    if (direction == OKCalendarArrowDirectionDown)
    {
        // draw it if yes
        createBezierArrow();
    }
    // same steps for bottom-right corner
    [result addLineToPoint: CGPointMake(tl.x + shadowPadding.left + width - cornerRadius
                                        , tl.y + shadowPadding.top + height)];
    [result addArcWithCenter:CGPointMake(tl.x + shadowPadding.left + width - cornerRadius
                                         , tl.y + shadowPadding.top + height - cornerRadius) 
                      radius:cornerRadius 
                  startAngle:radians(90) 
                    endAngle:radians(0)
                   clockwise:NO];
    if (direction == OKCalendarArrowDirectionRight)
    {
        createBezierArrow();
    }
    // same steps for top-right corner
    [result addLineToPoint: CGPointMake(tl.x + shadowPadding.left + width
                                        , tl.y + shadowPadding.top + cornerRadius)];
    [result addArcWithCenter:CGPointMake(tl.x + shadowPadding.left + width - cornerRadius
                                         , tl.y + shadowPadding.top + cornerRadius) 
                      radius:cornerRadius 
                  startAngle:radians(0) 
                    endAngle:radians(-90)
                   clockwise:NO];
    if (direction == OKCalendarArrowDirectionUp)
    {
        createBezierArrow();
    }
    // same steps for top-left corner
    [result addLineToPoint: CGPointMake(tl.x + shadowPadding.left + cornerRadius
                                        , tl.y + shadowPadding.top)];
    [result addArcWithCenter:CGPointMake(tl.x + shadowPadding.left + cornerRadius
                                         , tl.y + shadowPadding.top + cornerRadius) 
                      radius:cornerRadius 
                  startAngle:radians(-90) 
                    endAngle:radians(-180)
                   clockwise:NO];
    if (direction == OKCalendarArrowDirectionLeft)
    {
        createBezierArrow();
    }    
    // return back to the starting point
    [result addLineToPoint: CGPointMake(tl.x + shadowPadding.left
                                        , tl.y + shadowPadding.top + height - cornerRadius)];

    [result closePath];
    
    return result;
};

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGSize arrowSize           = kOKThemeArrowSize;
    UIEdgeInsets shadowPadding = kOKThemeShadowPadding;
    CGSize innerPadding        = kOKThemeInnerPadding;
    CGFloat headerHeight       = kOKThemeHeaderHeight;
    
    // backgound box. doesn't include arrow:
    CGRect boxBounds = CGRectMake(0, 0
                                  , self.frame.size.width - arrowSize.height
                                  , self.frame.size.height - arrowSize.height);

    CGFloat width = boxBounds.size.width - (shadowPadding.left + shadowPadding.right);
    CGFloat height = boxBounds.size.height - (shadowPadding.top + shadowPadding.bottom);
 
    NSDictionary *shadowDict = [[OKThemeEngine sharedInstance] elementOfGenericType:OKThemeShadowGenericType
                                                                            subtype:OKThemeMainSubtype
                                                                               type:OKThemeBackgroundElementType];
    OKThemeShadow *innerShadow = [[OKThemeShadow alloc] initWithShadowDict:shadowDict];

    CGPoint tl = CGPointZero;

    switch (self.arrowDirection) 
    {
        case OKCalendarArrowDirectionUp:
            tl.y = arrowSize.height;
            boxBounds.origin.y = arrowSize.height;
            break;
        case OKCalendarArrowDirectionLeft:
            tl.x = arrowSize.height;
            boxBounds.origin.x = arrowSize.height;
            break;
        default:
            break;
    }

    // draws background of popover
    UIBezierPath *roundedRectanglePath = [OKCalendarBackgroundView createBezierPathForSize:boxBounds.size
                                                                            arrowDirection:self.arrowDirection
                                                                             arrowPosition:self.arrowPosition];

    [[OKThemeEngine sharedInstance] drawPath:roundedRectanglePath
                              forElementType:OKThemeBackgroundElementType
                                     subType:OKThemeBackgroundSubtype
                                   inContext:context];

    // background inner shadow
    CGRect roundedRectangleBorderRect = CGRectInset([roundedRectanglePath bounds]
                                                    , -innerShadow.blurRadius
                                                    , -innerShadow.blurRadius);
    roundedRectangleBorderRect = CGRectOffset(roundedRectangleBorderRect
                                              , -innerShadow.offset.width
                                              , -innerShadow.offset.height);
    roundedRectangleBorderRect = CGRectInset(CGRectUnion(roundedRectangleBorderRect
                                                         , [roundedRectanglePath bounds]), -1, -1);
    
    UIBezierPath* roundedRectangleNegativePath = [UIBezierPath bezierPathWithRect: roundedRectangleBorderRect];
    [roundedRectangleNegativePath appendPath: roundedRectanglePath];
    roundedRectangleNegativePath.usesEvenOddFillRule = YES;

    CGContextSaveGState(context);
    {
        CGFloat xOffset = innerShadow.offset.width + round(roundedRectangleBorderRect.size.width);
        CGFloat yOffset = innerShadow.offset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset)
                                               , yOffset + copysign(0.1, yOffset)),
                                    innerShadow.blurRadius,
                                    innerShadow.color.CGColor);
        
        [roundedRectanglePath addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(roundedRectangleBorderRect.size.width)
                                                                       , 0);
        [roundedRectangleNegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [roundedRectangleNegativePath fill];
    }
    CGContextRestoreGState(context);

    NSNumber *separatorWidthNumber = [[OKThemeEngine sharedInstance] elementOfGenericType:OKThemeSizeWidthGenericType
																				  subtype:OKThemeMainSubtype
                                                                                     type:OKThemeSeparatorsElementType];

    if (separatorWidthNumber)
    {
        // dividers        
        CGFloat hDiff = (width + shadowPadding.left + shadowPadding.right - innerPadding.width * 2) / 7;
        CGFloat separatorWidth = [separatorWidthNumber floatValue];
        
        for (int i = 0; i < 6; i++) 
        {
            CGRect dividerRect = CGRectMake(tl.x + innerPadding.width + floor((i + 1) * hDiff) - 1 + shadowPadding.left
                                            , tl.y + innerPadding.height + headerHeight + shadowPadding.top
                                            , separatorWidth
                                            , height - innerPadding.height * 2 - headerHeight);
            UIBezierPath* dividerPath = [UIBezierPath bezierPathWithRect:dividerRect];

            [[OKThemeEngine sharedInstance] drawPath:dividerPath
                                      forElementType:OKThemeSeparatorsElementType
                                             subType:OKThemeMainSubtype
                                           inContext:context];
        }
    }

    [[OKThemeEngine sharedInstance] drawPath:roundedRectanglePath
                              forElementType:OKThemeBackgroundElementType
                                     subType:OKThemeOverlaySubtype
                                   inContext:context];
}

- (void)setFrame:(CGRect)frame
{
    BOOL needsRedraw = NO;
    
    if (!CGSizeEqualToSize(self.frame.size, frame.size))
    {
        needsRedraw = YES;
    }
    
    [super setFrame:frame];
    
    if (needsRedraw)
    {
        [self redrawComponent];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

