//
//  NotificationsViewController.m
//  JUFL
//
//  Created by Ankur on 13/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "NotificationsViewController.h"
#import "NotificationTableViewCell.h"
#import "FeedModel.h"
#import "SVPullToRefresh.h"
#import "EventDetailViewController.h"
#import "AppDelegate.h"
#import "TabBarViewController.h"
#import "Mixpanel.h"

@interface NotificationsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *notificationTableView;
@property (nonatomic, strong) NSMutableArray *notificationArray;
@property (nonatomic, strong) FeedModel *eventFeed;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;


@end
static NSString *cellIdentifier = @"NotificationTableViewCell";

@implementation NotificationsViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadViewForNewNotifications];
    [[Mixpanel sharedInstance] track:@"NotificationTapped"];
}
#pragma mark - My function
- (void)initializeView {
    self.noDataLabel.hidden = YES;
    AppSharedClass.notificationCount = nil;
    TabBarViewController *tabBarController = (TabBarViewController *)appDelegate.window.rootViewController;
    [[tabBarController.tabBar.items objectAtIndex:4] setBadgeValue:nil];
    
    [self.notificationTableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.notificationTableView.backgroundColor = [UIColor clearColor];
    self.blurView.backgroundColor = [[UIColor clearColor]colorWithAlphaComponent:0.1];
    self.view.backgroundColor = [[UIColor clearColor]colorWithAlphaComponent:0.1];
    
    self.notificationTableView.pullToRefreshView.arrowColor = [UIColor whiteColor];
    self.notificationTableView.pullToRefreshView.textColor = [UIColor whiteColor];
    
    [self.notificationTableView addPullToRefreshWithActionHandler:^{
        [self getNotificationsFromServer:YES];
    }];
    [self.notificationTableView addInfiniteScrollingWithActionHandler:^{
        if ([self.eventFeed.nextPage integerValue] > 0) {
            [self getNotificationsForNextPage];
        }
        else {
            [self.notificationTableView.infiniteScrollingView stopAnimating];
        }
    }];
    
    [self getNotificationsFromServer:NO];
}

- (void)getNotificationsFromServer: (BOOL)isPulled {
    if (self.notificationArray.count==0) {
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
    }
    
    [FeedModel getNotifications:@{kPageNumber : @(1)} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils createMainQueue:^{
            [Utils stopActivityIndicatorInView];
            [self.notificationTableView.pullToRefreshView stopAnimating];
            [self.notificationTableView.infiniteScrollingView stopAnimating];
            if (success) {
                self.eventFeed = [[FeedModel alloc]initWithNotificationData:response];
                self.notificationArray = self.eventFeed.results;
                [self.notificationTableView reloadData];
            }
            if (self.notificationArray.count>0) {
                [self.noDataLabel setHidden:YES];
            }
            else {
                
                [self.noDataLabel setHidden:NO];
            }
        }];
    }];
}

- (void)reloadViewForNewNotifications {
    [self getNotificationsFromServer:YES];
    if (self.notificationArray.count != 0 && [Utils isInternetAvailable]) {
        [self.notificationTableView.pullToRefreshView startAnimating];
    }
}

- (void)getNotificationsForNextPage {
    [FeedModel getNotifications:@{kPageNumber : self.eventFeed.nextPage} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils createMainQueue:^{
            [self.notificationTableView.infiniteScrollingView stopAnimating];
            if (success) {
                self.eventFeed = [[FeedModel alloc]initWithNotificationData:response];
                [self.notificationArray addObjectsFromArray:self.eventFeed.results];
                [self.notificationTableView reloadData];
                
            }
        }];
    }];
}

-(void)showEventDetail:(UIButton *)sender {
    
    EventModel *event = ((NotificationModel *)self.notificationArray[sender.tag]).event;
    EventDetailMode eventMode;
    NSNumber *currentId = numberValue([UserDefaluts objectForKey:kCurrentUserID]);
    
    if ([event.creator.userId isEqualToNumber:currentId]) {
        eventMode = EventDetailModeMyEvent;
    }
    else {
        if (event.eventRespose == EventResponseAccepted) {
            eventMode = EventDetailModeAcceptedEvent;
        }
        else if (event.eventRespose == EventResponseNoResponse) {
            eventMode = EventDetailModeNotAcceptedEvent;
        }
        else {
            eventMode = EventDetailModeRejected;
        }
    }
    
    EventDetailViewController *eventDetailViewController = [[EventDetailViewController alloc]initWithEvent:event andMode:eventMode];
    if ([event.endTime isEarlierThanDate:[NSDate date]]) {
        eventDetailViewController.viewEventMode = CurrentPastFeedTableViewModePast;
    }
    
    eventDetailViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:eventDetailViewController animated:YES];
    //    EventDetailViewController *eventDetailViewController = [[EventDetailViewController alloc]initWithEventId:event.eventId];
    //    [self.navigationController pushViewController:eventDetailViewController animated:YES];
}

#pragma mark - IBAction
- (IBAction)crossClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notificationArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NotificationModel *notification = self.notificationArray[indexPath.row];
    [cell setNotificationData:notification];
    cell.seeMoreButton.tag = indexPath.row;
    [cell.seeMoreButton addTarget:self action:@selector(showEventDetail:) forControlEvents:UIControlEventTouchUpInside];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    RESIGN_KEYBOARD
}

- (UIRectEdge)edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom;
}

@end
