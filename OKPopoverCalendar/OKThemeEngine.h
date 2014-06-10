//
//  OKThemeEngine.h
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum OKThemeElementType {
    OKThemeGeneralElementType = 0,
    OKThemeBackgroundElementType,
    OKThemeSeparatorsElementType,
    OKThemeMonthArrowsElementType,
    OKThemeMonthTitleElementType,
    OKThemeDayTitlesElementType,
    OKThemeCalendarDigitsActiveElementType,
    OKThemeCalendarDigitsActiveSelectedElementType,
    OKThemeCalendarDigitsInactiveElementType,
    OKThemeCalendarDigitsInactiveSelectedElementType,
    OKThemeCalendarDigitsTodayElementType,
    OKThemeCalendarDigitsTodaySelectedElementType,
    OKThemeSelectionElementType,
} OKThemeElementType;

typedef enum OKThemeElementSubtype {
    OKThemeNoSubtype = -1,
    OKThemeBackgroundSubtype,
    OKThemeMainSubtype,
    OKThemeOverlaySubtype,
} OKThemeElementSubtype;

typedef enum OKThemeGenericType {
    OKThemeColorGenericType,
    OKThemeFontGenericType,
    OKThemeFontNameGenericType,
    OKThemeFontSizeGenericType,
    OKThemeFontTypeGenericType,
    OKThemePositionGenericType,
    OKThemeShadowGenericType,
    OKThemeShadowBlurRadiusType,
    OKThemeOffsetGenericType,
    OKThemeOffsetHorizontalGenericType,
    OKThemeOffsetVerticalGenericType,
    OKThemeSizeInsetGenericType,
    OKThemeSizeGenericType,
    OKThemeSizeWidthGenericType,
    OKThemeSizeHeightGenericType,
    OKThemeStrokeGenericType,
    OKThemeEdgeInsetsGenericType,
    OKThemeEdgeInsetsTopGenericType,
    OKThemeEdgeInsetsLeftGenericType,
    OKThemeEdgeInsetsBottomGenericType,
    OKThemeEdgeInsetsRightGenericType,
    OKThemeCornerRadiusGenericType,
    OKThemeCoordinatesRoundGenericType,
} OKThemeGenericType;

@interface OKThemeEngine : NSObject

@property (nonatomic, strong) NSString *themeName;

/** defaults **/
@property (nonatomic, strong) UIFont *defaultFont;
@property (nonatomic, assign) BOOL dayTitlesInHeader;
@property (nonatomic, assign) UIEdgeInsets shadowInsets;
@property (nonatomic, assign) CGSize innerPadding;
@property (nonatomic, assign) CGSize outerPadding;
@property (nonatomic, assign) CGSize arrowSize;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGSize defaultSize;
@property (nonatomic, assign) CGFloat shadowBlurRadius;

+ (OKThemeEngine *) sharedInstance;
+ (UIColor *) colorFromString:(NSString *)colorString;

- (void) drawString:(NSString *) string
           withFont:(UIFont *) font
             inRect:(CGRect) rect
     forElementType:(OKThemeElementType) themeElementType
            subType:(OKThemeElementSubtype) themeElementSubtype
          inContext:(CGContextRef) context;

- (void) drawPath:(UIBezierPath *) path 
   forElementType:(OKThemeElementType) themeElementType
          subType:(OKThemeElementSubtype) themeElementSubtype
        inContext:(CGContextRef) context;

- (id) elementOfGenericType:(OKThemeGenericType) genericType
                    subtype:(OKThemeElementSubtype) subtype
                       type:(OKThemeElementType) type;

- (NSDictionary *) themeDictForType:(OKThemeElementType) type
                            subtype:(OKThemeElementSubtype) subtype;

@end

@interface NSDictionary (OKThemeAddons)

- (id) elementInThemeDictOfGenericType:(OKThemeGenericType) type;
- (CGSize) okThemeGenerateSize;
// UIOffset is available from iOS 5.0 :(. Using CGSize instead.
//- (UIOffset) okThemeGenerateOffset;
- (UIEdgeInsets) okThemeGenerateEdgeInsets;
- (UIFont *) okThemeGenerateFont;

@end
