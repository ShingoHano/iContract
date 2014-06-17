//
//  InputViewController.m
//  contract
//
//  Created by 羽野 真悟 on 13/05/07.
//  Copyright (c) 2013年 羽野 真悟. All rights reserved.
//

#import "InputViewController.h"
#import "MasterViewController.h"
#import "NSTimer+Blocks.h"
#import "NotiView.h"


@interface InputViewController ()

@end

@implementation InputViewController

static CGFloat offset = 20.0;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
	
	[_refreshHeaderView refreshLastUpdatedDate];
    
    self.tableView.rowHeight=40;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back.png"]];
    self.tableView.backgroundView=imageView;
    
    if(!contractArray)
    {
        contractArray=[[NSMutableArray alloc]initWithObjects:nil];
    }

    [self loadData];
}


- (void)setSection:(int)index
{
    masterSection=index;
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	_reloading = YES;	
}

- (void)doneLoadingTableViewData{
	
    //現在の日付と満期日の日付の差分を取得
    NSDate* date_converted;
    NSString* date_source = [contractArray objectAtIndex:masterSection*5+2];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    date_converted = [formatter dateFromString:date_source];
    NSDate *start = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *from;
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&from interval:NULL forDate:start];
    NSDate *to;
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&to interval:NULL forDate:date_converted];
    NSDateComponents *dif = [calendar components:NSDayCalendarUnit fromDate:from toDate:to options:0];
    
    //        [[UIApplication sharedApplication]cancelAllLocalNotifications];
    
    if([dif day]<0)
    {
        [self showAlert];
        _reloading = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        return;
    }
    //        NSLog(@"%d",[dif day]);
    
    NSInteger restDay=[dif day]-[[contractArray objectAtIndex:masterSection*5+4]integerValue];
    
    NSString *temp=nil;
    
    if([dif day]<[[contractArray objectAtIndex:masterSection*5+4]integerValue])
    {
        temp=[NSString stringWithFormat:@"%d",[dif day]];
        temp=[temp stringByAppendingString:NSLocalizedString(@"日です",nil)];
    }
    else
    {
        temp=[contractArray objectAtIndex:masterSection*5+4];
        temp=[temp stringByAppendingString:NSLocalizedString(@"日です",nil)];
    }
    //
    
    
    for (UILocalNotification *notify in [[UIApplication sharedApplication]
                                         scheduledLocalNotifications]) {
        
        NSString *keyId = [notify.userInfo objectForKey:@"key_id"];
        if([keyId isEqualToString:[contractArray objectAtIndex:masterSection*5]]){
            [[UIApplication sharedApplication] cancelLocalNotification:notify];
        }
    }
    
    //差分の指定日前に通知を行う
    UILocalNotification *notification=[[UILocalNotification alloc]init];
    notification.timeZone=[NSTimeZone defaultTimeZone];
    notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:60*60*24*(restDay)];
    notification.alertBody=[[[contractArray objectAtIndex:masterSection*5]stringByAppendingString:NSLocalizedString(@"の満期日まであと",nil)]stringByAppendingString:temp];
    notification.applicationIconBadgeNumber=0;
    notification.soundName=UILocalNotificationDefaultSoundName;
    notification.userInfo=[NSDictionary dictionaryWithObject:[contractArray objectAtIndex:masterSection*5] forKey:@"key_id"];

    [[UIApplication sharedApplication]scheduleLocalNotification:notification];
    
    [self showMessage:[contractArray objectAtIndex:masterSection*5] et:restDay];
    
    _reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:2.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

- (void)saveData
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    [defaults setObject:contractArray forKey:@"CONTRACT_ARRAY"];
    
    [defaults synchronize];

    MasterViewController *master=[[MasterViewController alloc]initWithNibName:@"MasterViewController" bundle:nil];
    [master.tableView reloadData];
}

- (void)loadData
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    contractArray=[[defaults objectForKey:@"CONTRACT_ARRAY"]mutableCopy];
    
    if(contractArray==nil)
    {
        contractArray=[[NSMutableArray alloc]initWithObjects:nil];
    }
}


- (void)showMessage:(NSString*)title et:(NSInteger)days
{
    NSString *temp;
    temp=NSLocalizedString(@"通知センターへの登録が完了しました。",nil);
    temp=[temp stringByAppendingString:title];
    temp=[temp stringByAppendingString:NSLocalizedString(@"の契約満期日が近づいたお知らせは、",nil)];
    if(days>0)
    {
        temp=[temp stringByAppendingString:[NSString stringWithFormat:@"%d",days]];
        temp=[temp stringByAppendingString:NSLocalizedString(@"日後に通知されます。",nil)];
    }

    else
    {
        temp=[temp stringByAppendingString:NSLocalizedString(@"今通知されます。",nil)];
    }
    
    [TSMessage showNotificationInViewController:self withTitle: NSLocalizedString(@"通知センターへの登録",nil) withMessage:temp withType:TSMessageNotificationTypeSuccess withDuration:20];
    
}

- (void)showAlert
{
    [TSMessage showNotificationInViewController:self withTitle: NSLocalizedString(@"通知センターへの登録",nil) withMessage:NSLocalizedString(@"契約満期日が現在よりも過去の日付に設定されているため、通知センターへの登録が完了できませんでした。",nil) withType:TSMessageNotificationTypeError withDuration:20];
}

/*******************************************************************
 関数名　　editAlert
 概要	 項目名と金額の編集用アラート表示
 引数　　　なし
 戻り値   なし
 *******************************************************************/
-(void)editAlert
{
    //アラートの判別用
//    alertFlag=10;
    
    if(alertSection==0)
    {
        
        BButtonType type=0;
        DDSocialDialogTheme dialogTheme = 0;
        
        if(masterSection%5==0)
        {
            type=3;
            dialogTheme = 3;
        }
        else if(masterSection%5==1)
        {
            type=1;
            dialogTheme = 1;
        }
        else if(masterSection%5==2)
        {
            type=4;
            dialogTheme = 4;
        }
        else if(masterSection%5==3)
        {
            type=5;
            dialogTheme = 5;
        }
        else if(masterSection%5==4)
        {
            type=9;
            dialogTheme = 9;
        }
        
        blankDialog = [[DDSocialDialog alloc] initWithFrame:CGRectMake(0., 0., 300., 250.) theme:dialogTheme];
        blankDialog.dialogDelegate = self;        
        blankDialog.titleLabel.text = NSLocalizedString(@"タイトル入力",nil);
        moneyField = [[UITextField alloc] initWithFrame:CGRectMake(85, 130, 165, 25)];
        moneyField.borderStyle = UITextBorderStyleRoundedRect;
        moneyField.font = [UIFont fontWithName:@"Arial-BoldMT" size:18];
        moneyField.textColor = [UIColor grayColor];
        moneyField.text=[contractArray objectAtIndex:masterSection*5];
        moneyField.minimumFontSize = 8;
        moneyField.adjustsFontSizeToFitWidth = YES;
        moneyField.delegate = self;
        moneyField.keyboardType=UIKeyboardTypeDefault;
        
        UILabel *label2=[[UILabel alloc]initWithFrame:CGRectMake(15, 130, 60, 25)];
        label2.text=NSLocalizedString(@"タイトル",nil);
        label2.font=[UIFont fontWithName:@"HiraKakuProN-W6" size:12];
        label2.textColor=[UIColor colorWithRed:0.202 green:0.3 blue:0.202 alpha:0.99];
        label2.textAlignment=NSTextAlignmentCenter;
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(15, 40, 250, 80)];
        label.text=NSLocalizedString(@"設定する項目のタイトルをつけます。全角12文字（半角24文字）以内で入力してください。",nil);
        label.numberOfLines=5;
        label.font=[UIFont fontWithName:@"HiraKakuProN-W6" size:12];
        label.textColor=[UIColor colorWithRed:0.202 green:0.3 blue:0.202 alpha:0.99];
        label.textAlignment=NSTextAlignmentCenter;

        BButton *btn1 = [[BButton alloc] initWithFrame:CGRectMake(40,180, 80, 30) type:type];
        [btn1 setTitle:@"Cancel" forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(cancelDialog) forControlEvents:UIControlEventTouchUpInside];
        [blankDialog addSubview:btn1];
        
        BButton *btn2 = [[BButton alloc] initWithFrame:CGRectMake(160,180, 80, 30) type:type];
        [btn2 setTitle:@"OK" forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(okDialog) forControlEvents:UIControlEventTouchUpInside];
        [blankDialog addSubview:btn2];

        [blankDialog addSubview:moneyField];
        [blankDialog addSubview:label];
        [blankDialog addSubview:label2];        
        [blankDialog show];

        // テキストフィールドをファーストレスポンダに
        [moneyField becomeFirstResponder];
    }
    
    else if(alertSection==1)
    {
        NSString *temp;
        
        if(alertIndex==0)
        {
            temp=[contractArray objectAtIndex:masterSection*5+1];
        }
        
        else if(alertIndex==1)
        {
            temp=[contractArray objectAtIndex:masterSection*5+2];
        }
    
        NSArray *comArray=[temp componentsSeparatedByString:@"/"];
        
        // NSCalendar を取得します。
        NSCalendar* calendar = [NSCalendar currentCalendar];
        
        // NSDateComponents を作成して、そこに作成したい情報をセットします。
        NSDateComponents* components = [[NSDateComponents alloc] init];
        
        components.year = [[comArray objectAtIndex:0]integerValue];
        components.month = [[comArray objectAtIndex:1]integerValue];
        components.day = [[comArray objectAtIndex:2]integerValue];
        
        // NSCalendar を使って、NSDateComponents を NSDate に変換します。
        NSDate* date = [calendar dateFromComponents:components];

        if(!popController)
        {
        popController = [[OKPopoverCalendarController alloc] init];
        }
        popController.period = [OKPeriod oneDayPeriodWithDate:date];
        _date = date;
        popController.delegate = self;
        [popController presentCalendarFromRect:CGRectMake(0, -300, 300, 300) inView:self.view permittedArrowDirections:OKCalendarArrowDirectionUp isPopover:NO animated:NO];
    }
    
    else if(alertSection==2)
    {
        
        BButtonType type=0;
        DDSocialDialogTheme dialogTheme = 0;
        
        if(masterSection%5==0)
        {
            type=4;
            dialogTheme = 4;
        }
        else if(masterSection%5==1)
        {
            type=5;
            dialogTheme = 5;
        }
        else if(masterSection%5==2)
        {
            type=9;
            dialogTheme = 9;
        }
        else if(masterSection%5==3)
        {
            type=3;
            dialogTheme = 3;
        }
        else if(masterSection%5==4)
        {
            type=1;
            dialogTheme = 1;
        }
        
        // We ignored the frame.origin position, the dialog will be placed at the center automatically.
        blankDialog = [[DDSocialDialog alloc] initWithFrame:CGRectMake(0., 0., 300., 250.) theme:dialogTheme];
        blankDialog.dialogDelegate = self;
        blankDialog.titleLabel.text = NSLocalizedString(@"違約金入力",nil);
        
        moneyField = [[UITextField alloc] initWithFrame:CGRectMake(85, 130, 165, 25)];
        moneyField.borderStyle = UITextBorderStyleRoundedRect;
        moneyField.font = [UIFont fontWithName:@"Arial-BoldMT" size:18];
        moneyField.textColor = [UIColor grayColor];
        moneyField.text=[contractArray objectAtIndex:masterSection*5+3];
        moneyField.minimumFontSize = 8;
        moneyField.adjustsFontSizeToFitWidth = YES;
        moneyField.delegate = self;
        moneyField.keyboardType=UIKeyboardTypeNumberPad;
        
        UILabel *label2=[[UILabel alloc]initWithFrame:CGRectMake(15, 130, 60, 25)];
        label2.text=NSLocalizedString(@"金額",nil);
        label2.font=[UIFont fontWithName:@"HiraKakuProN-W6" size:12];
        label2.textColor=[UIColor colorWithRed:0.202 green:0.3 blue:0.202 alpha:0.99];
        label2.textAlignment=NSTextAlignmentCenter;
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(15, 40, 250, 80)];
        label.text=NSLocalizedString(@"中途解約した場合の違約金の設定を行います。金額を半角数字で入力してください。",nil);
        label.numberOfLines=5;
        label.font=[UIFont fontWithName:@"HiraKakuProN-W6" size:12];
        label.textColor=[UIColor colorWithRed:0.202 green:0.3 blue:0.202 alpha:0.99];
        label.textAlignment=NSTextAlignmentCenter;
        
        BButton *btn1 = [[BButton alloc] initWithFrame:CGRectMake(40,180, 80, 30) type:type];
        [btn1 setTitle:@"Cancel" forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(cancelDialog) forControlEvents:UIControlEventTouchUpInside];
        [blankDialog addSubview:btn1];
        
        BButton *btn2 = [[BButton alloc] initWithFrame:CGRectMake(160,180, 80, 30) type:type];
        [btn2 setTitle:@"OK" forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(okDialog) forControlEvents:UIControlEventTouchUpInside];
        [blankDialog addSubview:btn2];
        
        [blankDialog addSubview:moneyField];
        [blankDialog addSubview:label];
        [blankDialog addSubview:label2];
        [blankDialog show];
        
        // テキストフィールドをファーストレスポンダに
        [moneyField becomeFirstResponder];
    }
    
    else if(alertSection==3)
    {
        BButtonType type=0;
        DDSocialDialogTheme dialogTheme = 0;
        
        if(masterSection%5==0)
        {
            type=5;
            dialogTheme = 5;
        }
        else if(masterSection%5==1)
        {
            type=9;
            dialogTheme = 9;
        }
        else if(masterSection%5==2)
        {
            type=3;
            dialogTheme = 3;
        }
        else if(masterSection%5==3)
        {
            type=1;
            dialogTheme = 1;
        }
        else if(masterSection%5==4)
        {
            type=4;
            dialogTheme = 4;
        }
        
        
        // We ignored the frame.origin position, the dialog will be placed at the center automatically.
        blankDialog = [[DDSocialDialog alloc] initWithFrame:CGRectMake(0., 0., 300., 250.) theme:dialogTheme];
        blankDialog.dialogDelegate = self;
        
        blankDialog.titleLabel.text = NSLocalizedString(@"通知設定",nil);
        
        moneyField = [[UITextField alloc] initWithFrame:CGRectMake(85, 130, 165, 25)];
        moneyField.borderStyle = UITextBorderStyleRoundedRect;
        moneyField.font = [UIFont fontWithName:@"Arial-BoldMT" size:18];
        moneyField.textColor = [UIColor grayColor];
        moneyField.text=[contractArray objectAtIndex:masterSection*5+4];
        moneyField.minimumFontSize = 8;
        moneyField.adjustsFontSizeToFitWidth = YES;
        moneyField.delegate = self;
        moneyField.keyboardType=UIKeyboardTypeNumberPad;
        
        UILabel *label2=[[UILabel alloc]initWithFrame:CGRectMake(15, 130, 60, 25)];
        label2.font=[UIFont fontWithName:@"HiraKakuProN-W6" size:12];
        label2.textColor=[UIColor colorWithRed:0.202 green:0.3 blue:0.202 alpha:0.99];
        label2.textColor=[UIColor blackColor];
        label2.textAlignment=NSTextAlignmentCenter;
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(15, 40, 250, 80)];
        label.text=NSLocalizedString(@"満期の何日前に通知するかを1日から365日の間で設定できます。設定する日数を半角数字で入力してください。",nil);
        label.numberOfLines=5;
        label.font=[UIFont fontWithName:@"HiraKakuProN-W6" size:12];
        label.textColor=[UIColor colorWithRed:0.202 green:0.3 blue:0.202 alpha:0.99];
        label.textAlignment=NSTextAlignmentCenter;
        
        BButton *btn1 = [[BButton alloc] initWithFrame:CGRectMake(40,180, 80, 30) type:type];
        [btn1 setTitle:@"Cancel" forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(cancelDialog) forControlEvents:UIControlEventTouchUpInside];
        [blankDialog addSubview:btn1];
        
        BButton *btn2 = [[BButton alloc] initWithFrame:CGRectMake(160,180, 80, 30) type:type];
        [btn2 setTitle:@"OK" forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(okDialog) forControlEvents:UIControlEventTouchUpInside];
        [blankDialog addSubview:btn2];
        
        [blankDialog addSubview:moneyField];
        [blankDialog addSubview:label];
        [blankDialog addSubview:label2];
        [blankDialog show];
        
        // テキストフィールドをファーストレスポンダに
        [moneyField becomeFirstResponder];
    }
}

- (void)calendarController:(OKPopoverCalendarController *)calendarController didChangePeriod:(OKPeriod *)newPeriod
{
	if (![newPeriod containsDate:_date]) {
//		[calendarController dismissCalendarAnimated:YES];
        [popController dismissCalendarAnimated:NO];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat  = @"yyyy/MM/dd";
        
        NSString *nowDateStr = [df stringFromDate:newPeriod.startDate];
        //            NSDate *nowDate = [dateFormatter dateFromString:nowDateStr];
        
        
        //            NSLog(@"%@",nowDateStr);
        
        if(alertIndex==0)
        {
            [contractArray removeObjectAtIndex:masterSection*5+1];
            [contractArray insertObject:nowDateStr atIndex:masterSection*5+1];
        }
        if(alertIndex==1)
        {
            [contractArray removeObjectAtIndex:masterSection*5+2];
            [contractArray insertObject:nowDateStr atIndex:masterSection*5+2];
        }
        [self saveData];
        [self.tableView reloadData];
	}
}


/*******************************************************************
 関数名　　alertView
 概要	 アラートのボタンクリック時の処理
 引数　　　:(UIAlertView *)alertView　アラート
 :(NSInteger)buttonIndex 　　クリックされたボタンインデックス
 戻り値   なし
 *******************************************************************/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //エラーアラートからOKが選択された場合、設定画面からキャンセルが選択された場合
    if (buttonIndex==0) {
    }
}

/*******************************************************************
 関数名　　errorAlertView:
 概要	 入力エラー表示用アラート
 引数　　　:(int)errorNumber  エラー番号
 戻り値   なし
 *******************************************************************/
- (void)errorAlertView:(int)errorNumber
{
    NSString *errorString;      //エラー文字列
    
    if(errorNumber==0)
    {
        errorString=NSLocalizedString(@"タイトルが入力されていません。\n",nil);
//        alertFlag=1;            //アラート再表示用
    }
    else if(errorNumber==3)
    {
        errorString=NSLocalizedString(@"項目名は全角12文字(半角24文字)以内で入力してください。\n",nil);
//        alertFlag=1;            //アラート再表示用
    }
    else if(errorNumber==2)
    {
        errorString=NSLocalizedString(@"金額が入力されていません。\n",nil);
//        alertFlag=1;            //アラート再表示用
    }
    else if(errorNumber==5)
    {
        errorString=NSLocalizedString(@"金額は半角数字で入力してください。\n",nil);
//        alertFlag=1;            //アラート再表示用
    }
    else if(errorNumber==8)
    {
        errorString=NSLocalizedString(@"入力された値が大きすぎます。\n",nil);
//        alertFlag=1;            //アラート再表示用
    }
    else if(errorNumber==1)
    {
        errorString=NSLocalizedString(@"日数が入力されていません\n",nil);
//        alertFlag=1;            //アラート再表示用
    }
    else if(errorNumber==4)
    {
        errorString=NSLocalizedString(@"日数は半角数字で入力してください\n",nil);
//        alertFlag=1;            //アラート再表示用
    }
    else if(errorNumber==7)
    {
        errorString=NSLocalizedString(@"入力された日数は無効です。\n",nil);
//        alertFlag=1;            //アラート再表示用
    }
    
    [TSMessage showNotificationInViewController:self withTitle:NSLocalizedString(@"入力エラー",nil) withMessage:errorString withType:TSMessageNotificationTypeError];

    /*
    // UIAlertViewの生成
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"入力エラー",nil)
                                                        message:errorString
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];*/
    // アラート表示
//    [alertView show];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if(section==0)
    {
        return 1;
    }
    else if(section==1)
    {
        return 2;
    }
    else if(section==2)
    {
        return 1;
    }
    else if(section==3)
    {
        return 1;
    }
    else if(section==4)
    {
        return 1;
    }

    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.textColor=[UIColor colorWithRed:0.202 green:0.3 blue:0.202 alpha:0.99];;
    UIFont *font =[UIFont fontWithName:@"HiraKakuProN-W6" size:14];
    cell.textLabel.font=font;

    
    if (indexPath.section==0)
    {
        cell.accessoryType=UITableViewCellAccessoryNone;
        cell.textLabel.text=[contractArray objectAtIndex:masterSection*5+0];
    }
    
    else if (indexPath.section==1)
    {
        cell.accessoryType=UITableViewCellAccessoryNone;
        if(indexPath.row==0)
        {
            cell.textLabel.text=[[contractArray objectAtIndex:masterSection*5+1]stringByAppendingString:NSLocalizedString(@" から",nil)];
        }
        else
        {
            cell.textLabel.text=[[contractArray objectAtIndex:masterSection*5+2]stringByAppendingString:NSLocalizedString(@" まで",nil)];
        }
    }
    
    else if(indexPath.section==2)
    {
        cell.accessoryType=UITableViewCellAccessoryNone;
        cell.textLabel.text=[[contractArray objectAtIndex:masterSection*5+3] stringByAppendingString:NSLocalizedString(@" 円",nil)];
    }
    
    else if(indexPath.section==3)
    {
        cell.accessoryType=UITableViewCellAccessoryNone;
        cell.textLabel.text=[[contractArray objectAtIndex:masterSection*5+4] stringByAppendingString:NSLocalizedString(@" 日前",nil)];
    }
    
    else if(indexPath.section==4)
    {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;

        cell.textLabel.text=NSLocalizedString(@"メモの編集",nil);
    }
    
    if(masterSection%5==0)
    {
        if(indexPath.section%5==0)
            cell.imageView.image=[UIImage imageNamed:@"image1"];
        else if(indexPath.section%5==1)
                cell.imageView.image=[UIImage imageNamed:@"image4"];
        else if(indexPath.section%5==2)
            cell.imageView.image=[UIImage imageNamed:@"image3"];
        else if(indexPath.section%5==3)
            cell.imageView.image=[UIImage imageNamed:@"image2"];
        else if(indexPath.section%5==4)
            cell.imageView.image=[UIImage imageNamed:@"image5"];
    }
    else if(masterSection%5==1)
    {
        if(indexPath.section%5==0)
            cell.imageView.image=[UIImage imageNamed:@"image4"];
        else if(indexPath.section%5==1)
            cell.imageView.image=[UIImage imageNamed:@"image3"];
        else if(indexPath.section%5==2)
            cell.imageView.image=[UIImage imageNamed:@"image2"];
        else if(indexPath.section%5==3)
            cell.imageView.image=[UIImage imageNamed:@"image5"];
        else if(indexPath.section%5==4)
            cell.imageView.image=[UIImage imageNamed:@"image1"];
    }
    else if(masterSection%5==2)
    {
        if(indexPath.section%5==0)
            cell.imageView.image=[UIImage imageNamed:@"image3"];
        else if(indexPath.section%5==1)
            cell.imageView.image=[UIImage imageNamed:@"image2"];
        else if(indexPath.section%5==2)
            cell.imageView.image=[UIImage imageNamed:@"image5"];
        else if(indexPath.section%5==3)
            cell.imageView.image=[UIImage imageNamed:@"image1"];
        else if(indexPath.section%5==4)
            cell.imageView.image=[UIImage imageNamed:@"image4"];
    }
    else if(masterSection%5==3)
    {
        if(indexPath.section%5==0)
            cell.imageView.image=[UIImage imageNamed:@"image2"];
        else if(indexPath.section%5==1)
            cell.imageView.image=[UIImage imageNamed:@"image5"];
        else if(indexPath.section%5==2)
            cell.imageView.image=[UIImage imageNamed:@"image1"];
        else if(indexPath.section%5==3)
            cell.imageView.image=[UIImage imageNamed:@"image4"];
        else if(indexPath.section%5==4)
            cell.imageView.image=[UIImage imageNamed:@"image3"];

    }
    else
    {
        if(indexPath.section%5==0)
            cell.imageView.image=[UIImage imageNamed:@"image5"];
        else if(indexPath.section%5==1)
            cell.imageView.image=[UIImage imageNamed:@"image1"];
        else if(indexPath.section%5==2)
            cell.imageView.image=[UIImage imageNamed:@"image4"];
        else if(indexPath.section%5==3)
            cell.imageView.image=[UIImage imageNamed:@"image3"];
        else if(indexPath.section%5==4)
            cell.imageView.image=[UIImage imageNamed:@"image2"];
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)
    {
        return NSLocalizedString(@"タイトル",nil);
    }
    else if(section==1)
    {
        return NSLocalizedString(@"契約期間",nil);
    }
    else if(section==2)
    {
        return NSLocalizedString(@"違約金",nil);
    }
    else if(section==3)
    {
        return NSLocalizedString(@"通知設定",nil);
    }
    else if(section==4)
    {
        return NSLocalizedString(@"注記事項",nil);
    }
    else
    {
        return nil;
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==4)
    {
        TextViewController *text=[[TextViewController alloc]initWithNibName:@"TextViewController" bundle:nil];
        [text setSection:masterSection];
        [self.navigationController pushViewController:text animated:YES];
    }
    else
    {
        alertSection=indexPath.section;
        alertIndex=indexPath.row;
        [self editAlert];
    }
}

-(void)cancelDialog
{
    [blankDialog cancel];
}

-(void)okDialog
{
    if(alertSection==0)
    {
        // テキストフィールド未入力の場合
        if ([moneyField.text length]==0)
        {

            [self errorAlertView:0];
        }
        //文字数オーバー
        else if([moneyField.text lengthOfBytesUsingEncoding:NSShiftJISStringEncoding]>24)
        {
            [self errorAlertView:3];
        }
        //正常入力
        else
        {
            [blankDialog cancel];

            [contractArray removeObjectAtIndex:masterSection*5+0];
            [contractArray insertObject:moneyField.text atIndex:masterSection*5+0];
            [self saveData];
            [self loadData];
            [self.tableView reloadData];
            
            NotiView *nv = [[NotiView alloc] initWithWidth:300];
            [nv setTitle:@"iContract"];
            [nv setDetail:NSLocalizedString(@"メニュー画面のタイトルを更新するには、メニュー画面のテーブルをプルダウンしてください。",nil)];
            [nv setIcon:[UIImage imageNamed:@"Icon"]];

            // make sure it's out of the screen
            CGRect f = nv.frame;
            f.origin.x = [self viewWidth] - f.size.width - offset;
            f.origin.y = -f.size.height;
            nv.frame = f;
            [self.view addSubview:nv];
            
            [UIView animateWithDuration:0.4 animations:^{
                nv.frame = CGRectOffset(nv.frame, 0.0, f.size.height+offset);
            } completion:^(BOOL finished) {
                [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer *timer) {
                    [UIView animateWithDuration:0.4 animations:^{
                        nv.frame = CGRectOffset(nv.frame, f.size.width+offset, 0.0);
                    } completion:^(BOOL finished) {
                        [nv removeFromSuperview];
                    }];
                }];
            }];

        }
    }
    else if(alertSection==2)                           //エディットアラート
    {
        if([moneyField.text length]==0)    //金額未入力
        {
            [self errorAlertView:2];
        }
        else
        {
            NSMutableCharacterSet *checkCharSet = [[NSMutableCharacterSet alloc] init];
            [checkCharSet addCharactersInString:@"1234567890"];
            if([[moneyField.text stringByTrimmingCharactersInSet:checkCharSet] length] > 0) //数字以外入力
            {
                [self errorAlertView:5];
            }
            else if(moneyField.text.longLongValue> 2147483647)                               //int上限超過
            {
                [self errorAlertView:8];
            }
            else
            {
                [contractArray removeObjectAtIndex:masterSection*5+3];
                [contractArray insertObject:moneyField.text atIndex:masterSection*5+3];
                
                [blankDialog cancel];

                [self saveData];
                [self loadData];
                [self.tableView reloadData];        //テーブルデータ更新
            }
        }
    }
    
    else if(alertSection==3)                           //エディットアラート
    {
        if([moneyField.text length]==0)    //金額未入力
        {
            [self errorAlertView:1];
        }
        else
        {
            NSMutableCharacterSet *checkCharSet = [[NSMutableCharacterSet alloc] init];
            [checkCharSet addCharactersInString:@"1234567890"];
            if([[moneyField.text stringByTrimmingCharactersInSet:checkCharSet] length] > 0) //数字以外入力
            {
                [self errorAlertView:4];
            }
            else if(moneyField.text.longLongValue< 1 || moneyField.text.longLongValue> 365)
            {
                [self errorAlertView:7];
            }
            else
            {
                [contractArray removeObjectAtIndex:masterSection*5+4];
                [contractArray insertObject:moneyField.text atIndex:masterSection*5+4];
            
                [blankDialog cancel];

                [self saveData];
                [self loadData];
            
                [self.tableView reloadData];        //テーブルデータ更新
                
                NotiView *nv = [[NotiView alloc] initWithWidth:300];
                [nv setTitle:@"iContract"];
                [nv setDetail:NSLocalizedString(@"通知センターへ登録するには、テーブルをプルダウンしてください。",nil)];
                [nv setIcon:[UIImage imageNamed:@"Icon"]];
                CGRect f = nv.frame;
                f.origin.x = [self viewWidth] - f.size.width - offset;
                f.origin.y = -f.size.height;
                nv.frame = f;
                [self.view addSubview:nv];
                
                [UIView animateWithDuration:0.4 animations:^{
                    nv.frame = CGRectOffset(nv.frame, 0.0, f.size.height+offset);
                } completion:^(BOOL finished) {
                    [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer *timer) {
                        [UIView animateWithDuration:0.4 animations:^{
                            nv.frame = CGRectOffset(nv.frame, f.size.width+offset, 0.0);
                        } completion:^(BOOL finished) {
                            [nv removeFromSuperview];
                        }];
                    }];
                }];
            }
        }
    }
}


- (CGFloat) viewWidth {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat width = self.view.frame.size.width;
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        width = self.view.frame.size.height;
    }
    return width;
}


/*
#pragma mark -
#pragma mark DDSocialDialogDelegate (Optional)
- (void)socialDialogDidCancel:(DDSocialDialog *)socialDialog {
}*/

/*
#pragma mark DDSocialLoginDialogDelegate (Required)

- (void)socialDialogDidSucceed:(DDSocialLoginDialog *)socialLoginDialog {
	NSString *username = socialLoginDialog.username;
	NSString *password = socialLoginDialog.password;
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSStringFromClass([socialLoginDialog class]) message:[NSString stringWithFormat:@"Username:%@ and Password:%@", username, password] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
//	[alertView release];
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
