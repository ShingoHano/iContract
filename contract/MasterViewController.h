//
//  MasterViewController.h
//  contract
//
//  Created by 羽野 真悟 on 13/05/07.
//  Copyright (c) 2013年 羽野 真悟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputViewController.h"
#import "ODRefreshControl.h"
#import "BButton.h"
#import "TSMessage.h"

@interface MasterViewController : UITableViewController
{
    NSMutableArray *contractArray;
    NSMutableArray *textArray;
    BButton *bbutton;
}

@end
