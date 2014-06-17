//
//  InputViewController.h
//  contract
//
//  Created by 羽野 真悟 on 13/05/07.
//  Copyright (c) 2013年 羽野 真悟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDSocialLoginDialog.h"
#import "OKPopoverCalendar.h"
#import "EGORefreshTableHeaderView.h"
#import "BButton.h"
#import "TextViewController.h"

@interface InputViewController : UITableViewController <DDSocialDialogDelegate,UITextFieldDelegate,OKPopoverCalendarControllerDelegate,EGORefreshTableHeaderDelegate>
{
    UITextField *moneyField;    
    NSInteger masterSection;
    NSInteger alertFlag;
    NSInteger alertSection;
    NSInteger alertIndex;
    NSMutableArray *contractArray;
    
    //DDSocialLoginDialog
    DDSocialDialog *blankDialog;

    //OKPopOverCalender
    OKPopoverCalendarController *popController;
    NSDate *_date;
    
    //EGORefreshTableHeaderView
    EGORefreshTableHeaderView *_refreshHeaderView;	
	BOOL _reloading;
}

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
- (void)setSection:(int)index;

@end
