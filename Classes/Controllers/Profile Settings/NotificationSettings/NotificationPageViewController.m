//
//  NotificationPageViewController.m
//  JUFL
//
//  Created by Rakesh Lohan on 10/08/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "NotificationPageViewController.h"
#import "NotificationPageTableViewCell.h"

static NSString *cellIdentifier = @"NotificationPageTableViewCell";

@interface NotificationPageViewController ()  <UITableViewDelegate,UITableViewDataSource>
{
    NSArray *cellLabelTextArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)backButtonClicked:(UIButton *)sender;
@end

@implementation NotificationPageViewController
{
    NSDictionary *notificationDic;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super initWithNibName:@"NotificationPageViewController" bundle:nil];
    if(self)
    {
        notificationDic=dic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self initializeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Mark-My functions
-(void)initializeView
{
    cellLabelTextArray=[[NSArray alloc]initWithObjects:@"New activity", @"Details changed", @"Activity cancelled",@"Invitee Notifications", @"Activity reminder", nil];
    [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
}

- (void)toggleClicked:(UISwitch *)sender {
    if(sender.isOn){
        if (sender.tag==0) {
            [Utils createBackGroundQueue:^{
                NSDictionary *params = @{kNotificationInvite:@"1"};
                [EventModel onOffNotification:params completion:^(BOOL success, NSError *error) {
                    if(success)
                    {
                        DLog(@"%i",success);
                    }
                }];
            }];
        }
        else if(sender.tag==1)
        {
            [Utils createBackGroundQueue:^{
                NSDictionary *params = @{kNotificationEdit:@"1"};
                [EventModel onOffNotification:params completion:^(BOOL success, NSError *error) {
                    if(success)
                    {
                        DLog(@"%i",success);
                    }
                }];
            }];
            
        }else if (sender.tag==2)
        {
            [Utils createBackGroundQueue:^{
                NSDictionary *params = @{kNotificationCancel:@"1"};
                [EventModel onOffNotification:params completion:^(BOOL success, NSError *error) {
                    if(success)
                    {
                        DLog(@"%i",success);
                    }
                }];
            }];
            
        }else if (sender.tag==3)
        {
            [Utils createBackGroundQueue:^{
                NSDictionary *params = @{kNotificationInviteeNotiication:@"1"};
                [EventModel onOffNotification:params completion:^(BOOL success, NSError *error) {
                    if(success)
                    {
                        DLog(@"%i",success);
                    }
                }];
            }];
            
        }else if (sender.tag==4)
        {
            [Utils createBackGroundQueue:^{
                NSDictionary *params = @{kNotificationActivityScheduled:@"1"};
                [EventModel onOffNotification:params completion:^(BOOL success, NSError *error) {
                    if(success)
                    {
                        DLog(@"%i",success);
                    }
                }];
            }];
            
        }
        
    }else
    {
        if (sender.tag==0) {
            [Utils createBackGroundQueue:^{
                NSDictionary *params = @{kNotificationInvite:@"0"};
                [EventModel onOffNotification:params completion:^(BOOL success, NSError *error) {
                    if(success)
                    {
                        DLog(@"%i",success);
                    }
                }];
            }];
        }
        else if(sender.tag==1)
        {
            [Utils createBackGroundQueue:^{
                NSDictionary *params = @{kNotificationEdit:@"0"};
                [EventModel onOffNotification:params completion:^(BOOL success, NSError *error) {
                    if(success)
                    {
                        DLog(@"%i",success);
                    }
                }];
            }];
            
        }else if (sender.tag==2)
        {
            [Utils createBackGroundQueue:^{
                NSDictionary *params = @{kNotificationCancel:@"0"};
                [EventModel onOffNotification:params completion:^(BOOL success, NSError *error) {
                    if(success)
                    {
                        DLog(@"%i",success);
                    }
                }];
            }];
        }else if (sender.tag==3)
        {
            [Utils createBackGroundQueue:^{
                NSDictionary *params = @{kNotificationInviteeNotiication:@"0"};
                [EventModel onOffNotification:params completion:^(BOOL success, NSError *error) {
                    if(success)
                    {
                        DLog(@"%i",success);
                    }
                }];
            }];
        }else if (sender.tag==4)
        {
            [Utils createBackGroundQueue:^{
                NSDictionary *params = @{kNotificationActivityScheduled:@"0"};
                [EventModel onOffNotification:params completion:^(BOOL success, NSError *error) {
                    if(success)
                    {
                        DLog(@"%i",success);
                    }
                }];
            }];
        }
    }
}
#pragma Mark-tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return cellLabelTextArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationPageTableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.titleLabel.text=[cellLabelTextArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row==0) {
        if ([[notificationDic valueForKey:kNotificationInvite] isEqual:@"1"]) {
            [cell.toggleSwitch setOn:YES animated:NO];
        }else{
            [cell.toggleSwitch setOn:NO animated:NO];
        }
    }
    if (indexPath.row==1) {
        if ([[notificationDic valueForKey:kNotificationEdit] isEqual:@"1"]) {
            [cell.toggleSwitch setOn:YES animated:NO];
        }else{
            [cell.toggleSwitch setOn:NO animated:NO];
        }
    }
    if (indexPath.row==2) {
        if ([[notificationDic valueForKey:kNotificationCancel] isEqual:@"1"]) {
            [cell.toggleSwitch setOn:YES animated:NO];
        }else{
            [cell.toggleSwitch setOn:NO animated:NO];
        }
    }
    if (indexPath.row==3) {
        if ([[notificationDic valueForKey:kNotificationInviteeNotiication] isEqual:@"1"]) {
            [cell.toggleSwitch setOn:YES animated:NO];
        }else{
            [cell.toggleSwitch setOn:NO animated:NO];
        }
    }
    if (indexPath.row==4) {
        if ([[notificationDic valueForKey:kNotificationActivityScheduled] isEqual:@"1"]) {
            [cell.toggleSwitch setOn:YES animated:NO];
        }else{
            [cell.toggleSwitch setOn:NO animated:NO];
        }
    }
    
    cell.toggleSwitch.tag=indexPath.row;
    [cell.toggleSwitch addTarget:self action:@selector(toggleClicked:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (IBAction)backButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
