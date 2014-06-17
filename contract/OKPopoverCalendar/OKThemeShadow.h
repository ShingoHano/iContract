//
//  OKThemeShadow.h
//  OKPopoverCalendar
//
//  Created by okenProg on 13/04/07.
//  Copyright (c) 2013年 okenProg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKThemeShadow : NSObject

@property (strong, nonatomic) UIColor *color;
@property (assign, nonatomic) CGSize offset;
@property (assign, nonatomic) CGFloat blurRadius;

- (id) initWithShadowDict:(NSDictionary *) shadowDict;

@end
