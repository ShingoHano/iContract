//
//  NotiView.h
//  NotiPad
//
//  Created by Mathieu Bolard on 24/07/12.
//  Copyright (c) 2012 Mathieu Bolard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotiView : UIView {
    UIImageView *_iconView;
    UILabel *_titleLabel;
    UILabel *_detailLabel;
    
    UIColor *_color;
    
    CGGradientRef _gradient;
}

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign) CGFloat width;

- (id)initWithWidth:(CGFloat)width;
- (id)initWithTitle:(NSString *)title detail:(NSString *)detail icon:(UIImage *)icon;
- (UIColor *)lightenColor:(UIColor *)oldColor value:(float)value;
- (void) updateHeight;

@end
