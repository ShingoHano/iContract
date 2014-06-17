//
//  OKThemeShadow.m
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import "OKThemeShadow.h"
#import "OKThemeEngine.h"
#import "OKTheme.h"

@implementation OKThemeShadow

- (id) initWithShadowDict:(NSDictionary *) shadowDict
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    self.color = [OKThemeEngine colorFromString:[shadowDict elementInThemeDictOfGenericType:OKThemeColorGenericType]];
    self.offset = [[shadowDict elementInThemeDictOfGenericType:OKThemeOffsetGenericType] okThemeGenerateSize];
    NSNumber *blurRadiusNumber = [shadowDict elementInThemeDictOfGenericType:OKThemeShadowBlurRadiusType];
    
    if (!blurRadiusNumber)
    {
        self.blurRadius = kOKThemeShadowBlurRadius;
    }
    else 
    {
        self.blurRadius = [blurRadiusNumber floatValue];
    }
    
    
    return self;
}

@end
