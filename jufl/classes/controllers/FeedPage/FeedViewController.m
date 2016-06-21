//
//  FeedViewController.m
//  JUFL
//
//  Created by Ankur on 13/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedTableViewCell.h"
#import "FeedModel.h"
#import "SVPullToRefresh.h"
#import "GoingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "EventDetailViewController.h"
#import "Mixpanel.h"

#define kFeedNoDataLabelText @"There is currently nothing in your feed. Try creating your own activity by pressing the “+” below."

//"@"There is currently nothing in your feed. Try creating your own activity."

#define kGoingNoDataLabelText @"You are not going to anything. Try joining an activity."

@interface FeedViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonLabelXConstraint;
@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIButton *feedButton;
@property (weak, nonatomic) IBOutlet UIButton *goingButton;
@property (weak, nonatomic) IBOutlet UITableView *feedTable;
@property (nonatomic, strong) NSMutableArray *feedArray;
@property (nonatomic, strong) NSArray *tableDataArray;
@property (nonatomic, strong) FeedModel *eventFeed;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
@property (nonatomic, assign) FeedTableViewMode tableViewMode;

@end
static NSString *cellIdentifier = @"FeedTableViewCell";
@implementation FeedViewController

#pragma mark - View LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[Mixpanel sharedInstance] track:@"FeedTapped"];
    if (AppSharedClass.lastSelectedIndex == 2) {
        [self goingClicked:nil];
    }
    [self reloadViewForNewFeeds];
}
#pragma mark - My Function

- (void)initializeView {
    [self.noDataLabel setHidden:YES];
     self.noDataLabel.text=kFeedNoDataLabelText;
    self.feedArray = [[NSMutableArray alloc]init];
    self.tableDataArray = [[NSArray alloc]init];
    [self.feedTable addPullToRefreshWithActionHandler:^{
        [self.noDataLabel setHidden:YES];
        [self getFeedFromServer:YES];
    }];
    [self.feedTable addInfiniteScrollingWithActionHandler:^{
        if ([self.eventFeed.nextPage integerValue] > 0) {
            [self.noDataLabel setHidden:YES];
            [self getFeedForNextPage];
        }
        else {
            [self.feedTable.infiniteScrollingView stopAnimating];
        }
    }];
    [self.feedButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
    [self.goingButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
    self.feedButton.selected = YES;
    self.goingButton.selected = NO;
    self.feedTable.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.feedTable registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
}

- (void)reloadViewForNewFeeds {
    [self getFeedFromServer:YES];
    if (self.feedArray.count != 0 && [Utils isInternetAvailable]) {
        [self.feedTable.pullToRefreshView startAnimating];
    }
}

- (void)getFeedFromServer: (BOOL)isPulled {
    if (self.feedArray.count==0) {
        // [Utils startActivityIndicatorWithMessage:kPleaseWait];
    }
    [FeedModel getUserFeed:@{kPageNumber : @(1)} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        //[Utils stopActivityIndicatorInView];
        [Utils createMainQueue:^{
            [self.feedTable.pullToRefreshView stopAnimating];
            [self.feedTable.infiniteScrollingView stopAnimating];
            if (success) {
                self.eventFeed = [[FeedModel alloc]initWithDictionary:response];
                self.feedArray = self.eventFeed.results;
                if (self.tableViewMode == FeedTableViewModeGoing) {
                    self.tableDataArray = [self getAcceptedEvents:self.feedArray];
                }
                else {
                    self.tableDataArray = self.feedArray;
                }
                [self.feedTable reloadData];
            }
            if (self.tableDataArray.count) {
                [self.noDataLabel setHidden:YES];
            }
            else {
                [self.noDataLabel setHidden:NO];
            }
            
        }];
    }];
}

- (void)getFeedForNextPage {
    [FeedModel getUserFeed:@{kPageNumber : self.eventFeed.nextPage} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [self.feedTable.infiniteScrollingView stopAnimating];
        if (success) {
            [Utils createMainQueue:^{
                self.eventFeed = [[FeedModel alloc]initWithDictionary:response];
                [self.feedArray addObjectsFromArray:self.eventFeed.results];
                if (self.tableViewMode == FeedTableViewModeGoing) {
                    self.tableDataArray = [self getAcceptedEvents:self.feedArray];
                }
                else {
                    self.tableDataArray = self.feedArray;
                }
                [self.feedTable reloadData];
                
            }];
        }
    }];
}

-(NSArray *)getAcceptedEvents:(NSArray *)originalArray {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(eventRespose == %@) AND (isDeleted == %@)", [NSNumber numberWithInteger:EventResponseAccepted],[NSNumber numberWithBool:NO]];
    // NSPredicate *cancelPredicate = [NSPredicate predicateWithFormat:@"isDeleted == %@",[NSNumber numberWithBool:NO]];
    NSArray *acceptedArray = [originalArray filteredArrayUsingPredicate:predicate];
    return acceptedArray;
}

- (void)goToGoingPage:(UIButton *)sender {
    EventModel *event = self.tableDataArray[sender.tag];
    GoingViewMode goingViewMode;
    NSNumber *currentId = numberValue([UserDefaluts objectForKey:kCurrentUserID]);
    if ([event.creator.userId isEqualToNumber:currentId]) {
        goingViewMode = GoingViewModeCreator;
    }
    else {
        goingViewMode = GoingViewModeInvitee;
    }
    
    GoingViewController *goingViewController = [[GoingViewController alloc]initWithEvent:event withMode:goingViewMode];
    
    goingViewController.openTabStr = kTabGoing;
    
    goingViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:goingViewController animated:YES];
}


#pragma mark - IBActions
- (IBAction)feedClicked:(id)sender {
    self.noDataLabel.text=kFeedNoDataLabelText;
    AppSharedClass.lastSelectedIndex = 0;
    self.feedButton.selected = YES;
    self.goingButton.selected = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.buttonLabelXConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
    [self.feedButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
    [self.goingButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
    
    self.tableViewMode = FeedTableViewModeAll;
    self.tableDataArray = self.feedArray;
    
    if (self.tableDataArray.count>0) {
        [self.noDataLabel setHidden:YES];
    }
    else {
        [self.noDataLabel setHidden:NO];
    }
    
    [self.feedTable reloadData];
    if (self.tableDataArray.count>0) {
        [self.noDataLabel setHidden:YES];
    }
    else {
        [self.noDataLabel setHidden:NO];
    }
    [self.feedTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}
- (IBAction)goingClicked:(id)sender {
    self.noDataLabel.text=kGoingNoDataLabelText;
    self.feedButton.selected = NO;
    self.goingButton.selected = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.buttonLabelXConstraint.constant = -(self.feedButton.size.width + 10);;
        [self.view layoutIfNeeded];
    }];
    
    [self.feedButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
    [self.goingButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
    
    self.tableViewMode = FeedTableViewModeGoing;
    self.tableDataArray = [self getAcceptedEvents:self.feedArray];
    if (self.tableDataArray.count>0) {
        [self.noDataLabel setHidden:YES];
    }
    else {
        [self.noDataLabel setHidden:NO];
    }
    [self.feedTable reloadData];
    [self.feedTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark - Delegate

#pragma mark - Table Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    EventModel *event = self.tableDataArray[indexPath.row];
    [cell setCellData:event];
    cell.goingButton.tag = indexPath.row;
    [cell.goingButton addTarget:self action:@selector(goToGoingPage:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EventModel *event = self.tableDataArray[indexPath.row];
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
    
   //Remove last chat record
    [UserDefaluts removeObjectForKey:kChatType];
    [UserDefaluts removeObjectForKey:kLastSenderId];
    [UserDefaluts removeObjectForKey:kLastSenderName];
    EventDetailViewController *eventDetailViewController = [[EventDetailViewController alloc]initWithEvent:event andMode:eventMode];
    eventDetailViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:eventDetailViewController animated:YES];
}
#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    RESIGN_KEYBOARD
}

- (UIRectEdge)edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom;
}

#pragma mark -Tab bar delegate
//- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
//    [self.feedTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0
//                                                              inSection:0]
//                          atScrollPosition:UITableViewScrollPositionTop
//                                  animated:YES];
//}
@end
