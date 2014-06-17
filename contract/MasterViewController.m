//
//  MasterViewController.m
//  contract
//
//  Created by 羽野 真悟 on 13/05/07.
//  Copyright (c) 2013年 羽野 真悟. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"iContract", @"Master");
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //ODRefreshControl
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];

    //NavigationController
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
    
    //TableView
    self.tableView.rowHeight=54;
    self.tableView.sectionHeaderHeight = 8;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back.png"]];
    self.tableView.backgroundView=imageView;

    if(!contractArray)
    {
        contractArray=[[NSMutableArray alloc]initWithObjects:nil];
    }
    
    if(!textArray)
    {
        textArray=[[NSMutableArray alloc]initWithObjects:nil];
    }
    
    [self loadData];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
        [self loadData];
        [TSMessage showNotificationInViewController:self withTitle:NSLocalizedString(@"更新完了",nil) withMessage:NSLocalizedString(@"タイトルの更新を行いました",nil) withType:TSMessageNotificationTypeSuccess];
    });
}

- (void)saveData
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    [defaults setObject:contractArray forKey:@"CONTRACT_ARRAY"];
    [defaults setObject:textArray forKey:@"TEXT_ARRAY"];
    
    [defaults synchronize];
}

- (void)loadData
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];

    contractArray=[[defaults objectForKey:@"CONTRACT_ARRAY"]mutableCopy];;
    textArray=[[defaults objectForKey:@"TEXT_ARRAY"]mutableCopy];;
    
    if(contractArray==nil)
    {
        contractArray=[[NSMutableArray alloc]initWithObjects:nil];
    }
    if(!textArray)
    {
        textArray=[[NSMutableArray alloc]initWithObjects:nil];
    }
    
    int section=contractArray.count/5;
    
    if(section>textArray.count)
    {
        for(int i=textArray.count;i<section;i++)
        {
            [textArray addObject:@""];
        }
        [self saveData];
    }
    else if(section<textArray.count)
    {
        for(int i=textArray.count;i>section;i--)
        {
            [textArray removeObjectAtIndex:i-1];
        }
        [self saveData];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    [self loadData];
    
    [contractArray addObject:NSLocalizedString(@"タイトル",nil)];
    [contractArray addObject:NSLocalizedString(@"2013/01/01",nil)];
    [contractArray addObject:NSLocalizedString(@"2013/12/31",nil)];
    [contractArray addObject:@"0"];
    [contractArray addObject:@"30"];
    [textArray addObject:@""];
    
    [self.tableView reloadData];
    [self saveData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return contractArray.count/5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    BButtonType type=0;

    switch (indexPath.section%6) {
        case 0:
            type=8;
            break;
        case 1:
            type=1;
            break;
        case 2:
            type=7;
            break;
        case 3:
            type=3;
            break;
        case 4:
            type=4;
            break;
        case 5:
            type=5;
            break;
        default:
            type=0;
            break;
    }
    
    NSString *cellString=[[NSString alloc]init];
    cellString=[contractArray objectAtIndex:indexPath.section*5+0];
    bbutton = [[BButton alloc] initWithFrame:CGRectMake(10,0, 300, 56) type:type];
    [bbutton setTitle:cellString forState:UIControlStateNormal];
    [bbutton addTarget:self action:@selector(moveInput:) forControlEvents:UIControlEventTouchUpInside];
    bbutton.tag=indexPath.section;
    
    //iPadの場合
    int screenW = [[UIScreen mainScreen] applicationFrame].size.width;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        bbutton.frame=CGRectMake(10, 0,screenW-20, 56);
    }

    [cell addSubview:bbutton];

    return cell;
}

- (void)moveInput:(id)sender
{
    if(!self.tableView.editing)
    {
       InputViewController *input=[[InputViewController alloc]initWithNibName:@"InputViewController" bundle:nil];
        BButton *button = (BButton *)sender;
        [input setSection:button.tag];
        [self.navigationController pushViewController:input animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self loadData];
        
        for(int i=0;i<5;i++)
        {
            [contractArray removeObjectAtIndex:indexPath.section*5];
        }
        [textArray removeObjectAtIndex:indexPath.section];
        
        [self saveData];
        [self.tableView reloadData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
    }
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:
(NSIndexPath *)fromIndexPath toIndexPath:
(NSIndexPath *)toIndexPath
{
    [self loadData];

    if(fromIndexPath.section>toIndexPath.section)
    {
        for(int i=0;i<5;i++)
        {
            id item=[contractArray objectAtIndex:fromIndexPath.section*5+i];        
            [contractArray removeObjectAtIndex:fromIndexPath.section*5+i];
            [contractArray insertObject:item atIndex:toIndexPath.section*5+i];
        }
        id item2=[textArray objectAtIndex:fromIndexPath.section];
        [textArray removeObjectAtIndex:fromIndexPath.section];
        [textArray insertObject:item2 atIndex:toIndexPath.section];
    }
    else
    {
        for(int i=0;i<5;i++)
        {
            id item=[contractArray objectAtIndex:fromIndexPath.section*5];
            [contractArray removeObjectAtIndex:fromIndexPath.section*5];
            [contractArray insertObject:item atIndex:toIndexPath.section*5+4];
        }
        id item2=[textArray objectAtIndex:fromIndexPath.section];
        [textArray removeObjectAtIndex:fromIndexPath.section];
        [textArray insertObject:item2 atIndex:toIndexPath.section];
    }
    
    [self.tableView reloadData];
    [self saveData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InputViewController *input=[[InputViewController alloc]initWithNibName:@"InputViewController" bundle:nil];
    [input setSection:indexPath.section];
    [self.navigationController pushViewController:input animated:YES];
}

@end
