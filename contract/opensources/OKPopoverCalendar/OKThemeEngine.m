//
//  OKThemeEngine.m
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import "OKThemeEngine.h"
#import "OKCalendarHelper.h"
#import <CoreText/CoreText.h>

static OKThemeEngine* sharedInstance;

@interface OKThemeEngine ()

@property (nonatomic, strong) NSDictionary *themeDict;

+ (NSString *) keyNameForElementType:(OKThemeElementType) type;
+ (NSString *) keyNameForElementSubtype:(OKThemeElementSubtype) type;
+ (NSString *) keyNameForGenericType:(OKThemeGenericType) type;

@end

@implementation OKThemeEngine

+ (OKThemeEngine *) sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OKThemeEngine alloc] init];
		[sharedInstance setThemeName:@"apple calendar"];
    });
    
    return sharedInstance;
}

+ (UIColor *) colorFromString:(NSString *)colorString
{
    UIColor *color = nil;
    if ([colorString isKindOfClass:[NSString class]]) // plain color
    {
        if ([colorString hasSuffix:@".png"])
        {
            color = [UIColor colorWithPatternImage:[UIImage imageNamed:colorString]];
        }
        else
        {
            NSArray *elements = [colorString componentsSeparatedByString:@","];
            NSAssert([elements count] >= 3 && [elements count] <= 4, @"Wrong count of color components.");
            
            NSString *r = [elements objectAtIndex:0];
            NSString *g = [elements objectAtIndex:1];
            NSString *b = [elements objectAtIndex:2];
            
            if ([elements count] > 3) // R,G,B,A
            {
                NSString *a = [elements objectAtIndex:3];
                color = UIColorMakeRGBA([r floatValue], [g floatValue], [b floatValue], [a floatValue]);
            }
            else
            {
                color = UIColorMakeRGB([r floatValue], [g floatValue], [b floatValue]);
            }
        }
    }
    return color;
}

// draws vertical gradient
+ (void) drawGradientInContext:(CGContextRef) context
                        inRect:(CGRect) rect
                     fromArray:(NSArray *) gradientArray
{
    NSMutableArray *gradientColorsArray = [NSMutableArray arrayWithCapacity:[gradientArray count]];
    CGFloat gradientLocations[gradientArray.count];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // TODO: ADD CACHING! May be expensive!
    int i = 0;
    for (NSDictionary *colElement in gradientArray) 
    {
        NSString *color = [colElement elementInThemeDictOfGenericType:OKThemeColorGenericType];
        NSNumber *pos = [colElement elementInThemeDictOfGenericType:OKThemePositionGenericType];
        [gradientColorsArray addObject:(id)[OKThemeEngine colorFromString:color].CGColor];
        gradientLocations[i] = 1 - pos.floatValue;
        i++;
    }
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace
                                                        , (__bridge CFArrayRef)gradientColorsArray
                                                        , gradientLocations);
    
    CGContextDrawLinearGradient(context
                                , gradient
                                , CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height)
                                , CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y)
                                , 0);
    CGGradientRelease(gradient);
//    CGColorSpaceRelease(colorSpace);
}

+ (NSString *) keyNameForElementType: (OKThemeElementType) type
{
    NSString *result = nil;
    
    switch (type) {
        case OKThemeGeneralElementType:
            result = @"General";
            break;
        case OKThemeBackgroundElementType:
            result = @"Background";
            break;
        case OKThemeSeparatorsElementType:
            result = @"Separators";
            break;
        case OKThemeMonthTitleElementType:
            result = @"Month title";
            break;
        case OKThemeDayTitlesElementType:
            result = @"Day titles";
            break;
        case OKThemeCalendarDigitsActiveElementType:
            result = @"Calendar digits active";
            break;
        case OKThemeCalendarDigitsActiveSelectedElementType:
            result = @"Calendar digits active selected";
            break;
        case OKThemeCalendarDigitsInactiveElementType:
            result = @"Calendar digits inactive";
            break;
        case OKThemeCalendarDigitsInactiveSelectedElementType:
            result = @"Calendar digits inactive selected";
            break;
        case OKThemeCalendarDigitsTodayElementType:
            result = @"Calendar digits today";
            break;
        case OKThemeCalendarDigitsTodaySelectedElementType:
            result = @"Calendar digits today selected";
            break;
        case OKThemeMonthArrowsElementType:
            result = @"Month arrows";
            break;
        case OKThemeSelectionElementType:
            result = @"Selection";
            break;
        default:
            break;
    }
    
    return result;
}

+ (NSString *) keyNameForElementSubtype: (OKThemeElementSubtype) type
{
    NSString *result = nil;
    
    switch (type) {
        case OKThemeBackgroundSubtype:
            result = @"Background";
            break;
        case OKThemeMainSubtype:
            result = @"Main";
            break;
        case OKThemeOverlaySubtype:
            result = @"Overlay";
            break;
        default:
            break;
    }
    
    return result;
}

+ (NSString *) keyNameForGenericType: (OKThemeGenericType) type
{
    NSString *result = nil;
    
    switch (type) {
        case OKThemeColorGenericType:
            result = @"Color";
            break;
        case OKThemeFontGenericType:
            result = @"Font";
            break;
        case OKThemeFontNameGenericType:
            result = @"Name";
            break;
        case OKThemeFontSizeGenericType:
            result = @"Size";
            break;
        case OKThemeFontTypeGenericType:
            result = @"Type";
            break;
        case OKThemePositionGenericType:
            result = @"Position";
            break;
        case OKThemeOffsetGenericType:
            result = @"Offset";
            break;
        case OKThemeOffsetHorizontalGenericType:
            result = @"Horizontal";
            break;
        case OKThemeOffsetVerticalGenericType:
            result = @"Vertical";
            break;
        case OKThemeShadowGenericType:
            result = @"Shadow";
            break;
        case OKThemeShadowBlurRadiusType:
            result = @"Blur radius";
            break;
        case OKThemeSizeGenericType:
            result = @"Size";
            break;
        case OKThemeSizeWidthGenericType:
            result = @"Width";
            break;
        case OKThemeSizeHeightGenericType:
            result = @"Height";
            break;
        case OKThemeSizeInsetGenericType:
            result = @"Size inset";
            break;
        case OKThemeStrokeGenericType:
            result = @"Stroke";
            break;
        case OKThemeEdgeInsetsGenericType:
            result = @"Insets";
            break;
        case OKThemeEdgeInsetsTopGenericType:
            result = @"Top";
            break;
        case OKThemeEdgeInsetsLeftGenericType:
            result = @"Left";
            break;
        case OKThemeEdgeInsetsBottomGenericType:
            result = @"Bottom";
            break;
        case OKThemeEdgeInsetsRightGenericType:
            result = @"Right";
            break;
        case OKThemeCornerRadiusGenericType:
            result = @"Corner radius";
            break;
        case OKThemeCoordinatesRoundGenericType:
            result = @"Coordinates round";
            break;
        default:
            break;
    }
    
    return result;
}

- (void) setThemeName:(NSString *)themeName
{
    if ([_themeName isEqualToString:themeName])
    {
        return;
    }
    
    _themeName = themeName;
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:themeName ofType:@"plist"];
    self.themeDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    NSAssert(self.themeDict, @"FATAL ERROR: Cannot initialize theme! Please check that you have at least default theme added to your project.");
    
    NSDictionary *generalSettings = [sharedInstance themeDictForType:OKThemeGeneralElementType
                                                             subtype:OKThemeNoSubtype];
    
    self.dayTitlesInHeader = [[generalSettings objectForKey:@"Day titles in header"] boolValue];
    self.defaultFont = [[generalSettings elementInThemeDictOfGenericType:OKThemeFontGenericType] okThemeGenerateFont];
    self.arrowSize = [[generalSettings objectForKey:@"Arrow size"] okThemeGenerateSize];
    self.defaultSize = [[generalSettings objectForKey:@"Default size"] okThemeGenerateSize];
    self.cornerRadius = [[generalSettings objectForKey:@"Corner radius"] floatValue];
    self.headerHeight = [[generalSettings objectForKey:@"Header height"] floatValue];
    self.outerPadding = [[generalSettings objectForKey:@"Outer padding"] okThemeGenerateSize];
    self.innerPadding = [[generalSettings objectForKey:@"Inner padding"] okThemeGenerateSize];
    self.shadowInsets = [[generalSettings objectForKey:@"Shadow insets"] okThemeGenerateEdgeInsets];
    self.shadowBlurRadius = [[generalSettings objectForKey:@"Shadow blur radius"] floatValue];
}

- (void) drawString:(NSString *) string 
           withFont:(UIFont *) font
             inRect:(CGRect) rect 
     forElementType:(OKThemeElementType) themeElementType
            subType:(OKThemeElementSubtype) themeElementSubtype
          inContext:(CGContextRef) context
{
    NSDictionary *themeDictionary = [[OKThemeEngine sharedInstance] themeDictForType:themeElementType
                                                                             subtype:themeElementSubtype];
    id colorObj = [themeDictionary elementInThemeDictOfGenericType:OKThemeColorGenericType];
    NSDictionary *shadowDict = [themeDictionary elementInThemeDictOfGenericType:OKThemeShadowGenericType];
    UIFont *usedFont = font;
    CGSize offset = [[themeDictionary elementInThemeDictOfGenericType:OKThemeOffsetGenericType] okThemeGenerateSize];
    CGRect realRect = CGRectOffset(rect, offset.width, offset.height);

    if (!usedFont)
    {
        usedFont = [[themeDictionary elementInThemeDictOfGenericType:OKThemeFontGenericType] okThemeGenerateFont];
    }

    if (!usedFont)
    {
        usedFont = self.defaultFont;
    }

    NSAssert(usedFont != nil, @"Please provide proper font either in theme file or in a code.");
    
    CGSize sz = [string sizeWithFont:usedFont];
    BOOL isGradient = ![colorObj isKindOfClass:[NSString class]];
    CGSize shadowOffset = CGSizeZero;

    CGContextSaveGState(context);
    {
        if (shadowDict)
        {
            shadowOffset = [[shadowDict elementInThemeDictOfGenericType:OKThemeOffsetGenericType] okThemeGenerateSize];
            UIColor *shadowColor = [OKThemeEngine colorFromString:[shadowDict elementInThemeDictOfGenericType:OKThemeColorGenericType]];
            [shadowColor set];
        }
        
        CGPoint textPoint = CGPointMake((int)(realRect.origin.x + (realRect.size.width - sz.width) / 2)
                                        , (int)(realRect.origin.y + realRect.size.height - 1));

        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)[usedFont fontName]
                                              , usedFont.pointSize
                                              , NULL);
        
        // Create an attributed string
        CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorFromContextAttributeName };
        CFTypeRef values[] = { font, kCFBooleanTrue };
        CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
                                                  sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, (__bridge CFStringRef)string, attr);
        CFRelease(attr);
        
        // Draw the string
        CTLineRef line = CTLineCreateWithAttributedString(attrString);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
        CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0)); //Use this one if the view's coordinates are flipped
        if (!CGSizeEqualToSize(shadowOffset, CGSizeZero))
        {
            CGContextSetTextPosition(context
                                     , textPoint.x + shadowOffset.width
                                     , textPoint.y + shadowOffset.height);
            CGContextSetTextDrawingMode(context, kCGTextFill);
            CTLineDraw(line, context);
        }

        CGContextSetTextPosition(context, textPoint.x, textPoint.y);

        // Clean up
        if (isGradient)
        {
            CGContextSetTextDrawingMode(context, kCGTextClip);
            CTLineDraw(line, context);

            [OKThemeEngine drawGradientInContext: context
                                          inRect: CGRectMake(textPoint.x
                                                             , textPoint.y - usedFont.pointSize + 1
                                                             , sz.width
                                                             , usedFont.pointSize)
                                       fromArray: colorObj];
        }
        else
        {
            CGContextSetTextDrawingMode(context, kCGTextFill);
            [[OKThemeEngine colorFromString:colorObj] setFill];
            
            CTLineDraw(line, context);
        }
        
        CFRelease(line);
        CFRelease(attrString);
        CFRelease(font);
    }
    CGContextRestoreGState(context);
}

- (void) drawPath:(UIBezierPath *) path 
   forElementType:(OKThemeElementType) themeElementType
          subType:(OKThemeElementSubtype) themeElementSubtype
        inContext:(CGContextRef) context
{
    NSDictionary *themeDictionary = [[OKThemeEngine sharedInstance] themeDictForType:themeElementType
                                                                             subtype:themeElementSubtype];
    id colorObj = [themeDictionary elementInThemeDictOfGenericType:OKThemeColorGenericType];

    NSDictionary *shadowDict = [themeDictionary elementInThemeDictOfGenericType:OKThemeShadowGenericType];
    CGContextSaveGState(context);
    {
        if (shadowDict)
        {
            CGSize shadowOffset = [[shadowDict elementInThemeDictOfGenericType:OKThemeOffsetGenericType] okThemeGenerateSize];
            UIColor *shadowColor = [OKThemeEngine colorFromString:[shadowDict elementInThemeDictOfGenericType:OKThemeColorGenericType]];
            NSNumber *blurRadius = [shadowDict elementInThemeDictOfGenericType:OKThemeShadowBlurRadiusType];
            CGContextSetShadowWithColor(context
                                        , shadowOffset
                                        , blurRadius?[blurRadius floatValue]:sharedInstance.shadowBlurRadius
                                        , shadowColor.CGColor);
            if (![shadowDict objectForKey:@"Type"])
            {
                [shadowColor setFill];
                [path fill];
            }
        }
    }
    if (![shadowDict objectForKey:@"Type"])
    {
        CGContextRestoreGState(context);

        CGContextSaveGState(context);
    }
    {
        [path addClip];

        if ([colorObj isKindOfClass:[NSString class]]) // plain color
        {
            [[OKThemeEngine colorFromString:colorObj] setFill];
            
            [path fill];
        }
        else
        {
            [OKThemeEngine drawGradientInContext:context
                                          inRect:path.bounds
                                       fromArray:colorObj];
        }

        NSDictionary *stroke = [themeDictionary elementInThemeDictOfGenericType:OKThemeStrokeGenericType];
        
        if (stroke)
        {
            NSString *strokeColorStr = [stroke elementInThemeDictOfGenericType:OKThemeColorGenericType];
            UIColor *strokeColor = [OKThemeEngine colorFromString:strokeColorStr];
            [strokeColor setStroke];
            path.lineWidth = [[stroke elementInThemeDictOfGenericType:OKThemeSizeWidthGenericType] floatValue]; // TODO: make separate stroke width generic type

            [path stroke];
        }
    }
    CGContextRestoreGState(context);
}

- (id) elementOfGenericType:(OKThemeGenericType) genericType
                    subtype:(OKThemeElementSubtype) subtype
                       type:(OKThemeElementType) type
{
    return [[[OKThemeEngine sharedInstance] themeDictForType:type
                                                     subtype:subtype] elementInThemeDictOfGenericType:genericType];
}

- (NSDictionary *) themeDictForType:(OKThemeElementType) type
                            subtype:(OKThemeElementSubtype) subtype
{
    NSDictionary *result = [sharedInstance.themeDict objectForKey:[OKThemeEngine keyNameForElementType:type]];
    
    if (subtype != OKThemeNoSubtype)
    {
        result = [result objectForKey:[OKThemeEngine keyNameForElementSubtype:subtype]];
    }
    
    return result;
}

- (NSDictionary *) themeDict
{
    if (!_themeDict)
    {
        self.themeName = @"default";
    }
    
    return _themeDict;
}

@end

@implementation NSDictionary (OKThemeAddons)

- (id) elementInThemeDictOfGenericType:(OKThemeGenericType) type
{
    return [self objectForKey:[OKThemeEngine keyNameForGenericType:type]];
}

- (CGSize) okThemeGenerateSize
{
    NSNumber *width = [self elementInThemeDictOfGenericType:OKThemeSizeWidthGenericType];
    NSNumber *height = [self elementInThemeDictOfGenericType:OKThemeSizeHeightGenericType];
    
    if (!width || !height)
    {
        return CGSizeZero;
    }
    
    NSAssert( [width isKindOfClass:[NSNumber class]], @"Expected numeric width value to generate CGSize" );
    NSAssert( [height isKindOfClass:[NSNumber class]], @"Expected numeric height value to generate CGSize" );
    
    return CGSizeMake([width floatValue], [height floatValue]);
}

- (UIFont *) okThemeGenerateFont
{
    NSNumber *size = [self elementInThemeDictOfGenericType:OKThemeFontSizeGenericType];
    NSString *name = [self elementInThemeDictOfGenericType:OKThemeFontNameGenericType];
    
    if (!size)
    {
        return [OKThemeEngine sharedInstance].defaultFont;
    }
    
    NSAssert( [size isKindOfClass:[NSNumber class]], @"Expected numeric font size value to generate UIFont" );

    if (!name)
    {
        NSString *type = [self elementInThemeDictOfGenericType:OKThemeFontTypeGenericType];
        if ([type isEqualToString:@"bold"])
        {
            return [UIFont boldSystemFontOfSize:[size floatValue]];            
        }
        
        return [UIFont systemFontOfSize:[size floatValue]];
    }
    
    return [UIFont fontWithName:name size:[size floatValue]];
}

- (UIEdgeInsets) okThemeGenerateEdgeInsets
{
    NSNumber *top = [self elementInThemeDictOfGenericType:OKThemeEdgeInsetsTopGenericType];
    NSNumber *left = [self elementInThemeDictOfGenericType:OKThemeEdgeInsetsLeftGenericType];
    NSNumber *bottom = [self elementInThemeDictOfGenericType:OKThemeEdgeInsetsBottomGenericType];
    NSNumber *right = [self elementInThemeDictOfGenericType:OKThemeEdgeInsetsRightGenericType];
    
    if (!top || !bottom || !left || !right)
    {
        return UIEdgeInsetsZero;
    }
    
    NSAssert( [top isKindOfClass:[NSNumber class]], @"Expected numeric top value to generate UIEdgeInsets" );
    NSAssert( [left isKindOfClass:[NSNumber class]], @"Expected numeric left value to generate UIEdgeInsets" );
    NSAssert( [bottom isKindOfClass:[NSNumber class]], @"Expected numeric bottom value to generate UIEdgeInsets" );
    NSAssert( [right isKindOfClass:[NSNumber class]], @"Expected numeric right value to generate UIEdgeInsets" );
    
    return UIEdgeInsetsMake([top floatValue], [left floatValue], [bottom floatValue], [right floatValue]);
}

@end

