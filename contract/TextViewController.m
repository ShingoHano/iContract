//
//  TextViewController.m
//  contract
//
//  Created by 羽野 真悟 on 13/07/07.
//  Copyright (c) 2013年 羽野 真悟. All rights reserved.
//

#import "TextViewController.h"
#import "TSMessage.h"

@interface TextViewController ()

@end

@implementation TextViewController

@synthesize textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setSection:(int)index
{
    masterSection=index;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"back.png"]];

    UIColor *color = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem =
    [self barButtonItemWithTint:color
                          title:@"Save"
                         target:self
                       selector:@selector(saveData)];
    
    if(!textArray)
    {
        textArray=[[NSMutableArray alloc]initWithObjects:nil];
    }
    
    [self loadData];
    
    textView.text=[textArray objectAtIndex:masterSection];
    textView.keyboardType=UIKeyboardTypeDefault;
    [textView becomeFirstResponder];
}

-(UIBarButtonItem *)barButtonItemWithTint:(UIColor *)color title:(NSString *)title target:(id)target selector:(SEL)selector
{
	UISegmentedControl *btn = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:title, nil]];
	btn.momentary = YES;
	btn.segmentedControlStyle = UISegmentedControlStyleBar;
	btn.tintColor = color;
	[btn addTarget:target action:selector forControlEvents:UIControlEventValueChanged];
    
	UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
	return barBtn;
}

- (void)saveData
{
    id item=textView.text;
    NSLog(@"%@",item);
    [textArray removeObjectAtIndex:masterSection];
    [textArray insertObject:item atIndex:masterSection];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    [defaults setObject:textArray forKey:@"TEXT_ARRAY"];
    
    [defaults synchronize];
    
    [TSMessage showNotificationInViewController:self withTitle:NSLocalizedString(@"保存完了",nil) withMessage:NSLocalizedString(@"メモの内容を保存しました。",nil) withType:TSMessageNotificationTypeSuccess];
    [self loadData];
}

- (void)loadData
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    textArray=[[defaults objectForKey:@"TEXT_ARRAY"]mutableCopy];
    
    if(textArray==nil)
    {
        textArray=[[NSMutableArray alloc]initWithObjects:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
