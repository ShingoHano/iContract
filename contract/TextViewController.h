//
//  TextViewController.h
//  contract
//
//  Created by 羽野 真悟 on 13/07/07.
//  Copyright (c) 2013年 羽野 真悟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewController : UIViewController
{
    NSInteger masterSection;
    UITextView *textView;
    NSMutableArray *textArray;
}

@property(nonatomic,strong) IBOutlet UITextView *textView;

- (void)setSection:(int)index;

@end
