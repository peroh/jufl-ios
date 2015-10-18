//
//  MyProfileViewController.m
//  JUFL
//
//  Created by Ankur on 13/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "MyProfileViewController.h"
#import "FeedTableViewCell.h"
#import "FeedModel.h"
#import "SettingViewController.h"
#import "UserModel.h"
#import "SVPullToRefresh.h"
#import "EventDetailViewController.h"
#import "GoingViewController.h"
#import "Mixpanel.h"

#define kCurrentNoDataLabelText @"You have not created any upcoming activities. Try creating one."
#define kPastNoDataLabelText @"Activities that you have attended in the past will appear here."

@interface MyProfileViewController () <UIActionSheetDelegate>
{
    UserModel *user;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *tableDataArray;
@property (nonatomic, strong) NSMutableArray *pastFeedArray;
@property (nonatomic, strong) NSMutableArray *currentFeedArray;
@property (nonatomic, strong) FeedModel *currentEventFeed;
@property (nonatomic, strong) FeedModel *pastEventFeed;
@property (weak, nonatomic) IBOutlet UILabel *noFeedAvailableLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelXConstraint;
@property (weak, nonatomic) IBOutlet UIButton *currentButton;
@property (weak, nonatomic) IBOutlet UIButton *pastButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (nonatomic, assign) CurrentPastFeedTableViewMode tableViewMode;


- (IBAction)currentFeedButtonClicked:(UIButton *)sender;
- (IBAction)pastFeedButtonClicked:(UIButton *)sender;
- (IBAction)settingButtonClicked:(UIButton *)sender;
@end

static NSString *cellIdentifier = @"FeedTableViewCell";

@implementation MyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableViewMode=CurrentPastFeedTableViewModeCurrent;
    [self initializeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    RESIGN_KEYBOARD
}

- (UIRectEdge)edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[Mixpanel sharedInstance] track:@"MyProfileTapped"];
    [self updateUserInfo];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
#pragma mark - My Function
-(void)updateUserInfo
{
    user=[[UserModel alloc]initWithUserTable:[UserModel currentUser]];
    self.userNameLabel.text=[NSString stringWithFormat:@"%@ %@",user.firstName,user.lastName];
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:user.image] placeholderImage:imgSync completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        if (image) {
            self.profileImageView.image = image;
        }
        else {
            self.profileImageView.image = [UIImage imageNamed:@"profilePlaceholder"];
        }
    } animation:NaveenImageViewOptionsNone];
    [self getCurrentFeedFromServer:YES];
}
- (void)initializeView {
    if (self.tableViewMode == CurrentPastFeedTableViewModeCurrent) {
        [self.currentButton setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
        [self.noFeedAvailableLabel setHidden:YES];
        [self getCurrentFeedFromServer:YES];
    }
    else if (self.tableViewMode == CurrentPastFeedTableViewModePast)
    {
        [self.noFeedAvailableLabel setHidden:YES];
        [self getPastFeedFromServer:YES];
    }
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        if (self.tableViewMode == CurrentPastFeedTableViewModeCurrent) {
            [self.noFeedAvailableLabel setHidden:YES];
            [self getCurrentFeedFromServer:YES];
        }
        else {
            [self.noFeedAvailableLabel setHidden:YES];
            [self getPastFeedFromServer:YES];
        }
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        if (self.tableViewMode == CurrentPastFeedTableViewModeCurrent) {
            if ([self.currentEventFeed.nextPage integerValue] > 0) {
                [self.noFeedAvailableLabel setHidden:YES];
                [self getCurrentFeedForNextPage];
            }
            else {
                [self.noFeedAvailableLabel setHidden:YES];
                [self.tableView.infiniteScrollingView stopAnimating];
            }
            
        }
        else{
            if ([self.pastEventFeed.nextPage integerValue] > 0) {
                [self.noFeedAvailableLabel setHidden:YES];
                [self getPastFeedForNextPage];
            }
            else {
                [self.noFeedAvailableLabel setHidden:YES];
                [self.tableView.infiniteScrollingView stopAnimating];
            }
        }
    }];
    [self.noFeedAvailableLabel setHidden:YES];
    
    user=[[UserModel alloc]initWithUserTable:[UserModel currentUser]];
    self.userNameLabel.text=[NSString stringWithFormat:@"%@ %@",user.firstName,user.lastName];
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:user.image] placeholderImage:imgSync completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        if (image) {
            self.profileImageView.image = image;
        }
        else {
            self.profileImageView.image = [UIImage imageNamed:@"profilePlaceholder"];
        }
    } animation:NaveenImageViewOptionsNone];
    
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.currentFeedArray = [[NSMutableArray alloc]init];
    self.pastFeedArray = [[NSMutableArray alloc]init];
    self.tableDataArray = [[NSArray alloc]init];
    [self getCurrentFeedFromServer:NO];
}

- (void)getCurrentFeedFromServer: (BOOL)isPulled {
    if (self.currentFeedArray.count==0) {
        //[Utils startActivityIndicatorWithMessage:kPleaseWait];
    }
    [FeedModel getCurrentFeed:@{kPageNumber : @(1)} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils createMainQueue:^{
            //[Utils stopActivityIndicatorInView];
            [self.tableView.pullToRefreshView stopAnimating];
            [self.tableView.infiniteScrollingView stopAnimating];
            if (success) {
                self.currentEventFeed = [[FeedModel alloc]initWithDictionary:response];
                self.currentFeedArray = self.currentEventFeed.results;
                if (self.tableViewMode == CurrentPastFeedTableViewModeCurrent) {
                    self.tableDataArray =self.currentFeedArray;
                }
                [self.tableView reloadData];
            }
            if (self.currentFeedArray.count==0) {
                self.noFeedAvailableLabel.text=kCurrentNoDataLabelText;
                [self.noFeedAvailableLabel setHidden:NO];
            }
            else
            {
                [self.noFeedAvailableLabel setHidden:YES];
            }
        }];
        
    }];
}

- (void)getPastFeedFromServer: (BOOL)isPulled {
    if (self.pastFeedArray.count==0) {
        //[Utils startActivityIndicatorWithMessage:kPleaseWait];
    }
    [FeedModel getPastFeed:@{kPageNumber : @(1)} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils createMainQueue:^{
            // [Utils stopActivityIndicatorInView];
            [self.tableView.pullToRefreshView stopAnimating];
            [self.tableView.infiniteScrollingView stopAnimating];
            if (success) {
                self.pastEventFeed = [[FeedModel alloc]initWithDictionary:response];
                self.pastFeedArray = self.pastEventFeed.results;
                if (self.tableViewMode == CurrentPastFeedTableViewModePast) {
                    self.tableDataArray =self.pastFeedArray;
                }
                [self.tableView reloadData];
            }
            if (self.pastFeedArray.count==0) {
                self.noFeedAvailableLabel.text=kPastNoDataLabelText;
                [self.noFeedAvailableLabel setHidden:NO];
            }
            else
            {
                [self.noFeedAvailableLabel setHidden:YES];
            }
        }];
    }];
}

- (void)getCurrentFeedForNextPage {
    
    [FeedModel getCurrentFeed:@{kPageNumber : self.currentEventFeed.nextPage} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils createMainQueue:^{
            [self.tableView.infiniteScrollingView stopAnimating];
            if (success) {
                self.currentEventFeed = [[FeedModel alloc]initWithDictionary:response];
                [self.currentFeedArray addObjectsFromArray:self.currentEventFeed.results];
                if (self.tableViewMode ==CurrentPastFeedTableViewModeCurrent) {
                    self.tableDataArray =self.currentFeedArray;
                }
                [self.tableView reloadData];
            }
        }];
    }];
}

- (void)getPastFeedForNextPage {
    
    [FeedModel getPastFeed:@{kPageNumber : self.pastEventFeed.nextPage} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils createMainQueue:^{
            [self.tableView.infiniteScrollingView stopAnimating];
            if (success) {
                self.pastEventFeed = [[FeedModel alloc]initWithDictionary:response];
                [self.pastFeedArray addObjectsFromArray:self.pastEventFeed.results];
                if (self.tableViewMode ==CurrentPastFeedTableViewModePast) {
                    self.tableDataArray =self.pastFeedArray;
                }
                [self.tableView reloadData];
            }
        }];
    }];
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
    GoingViewController *goingViewController = [[GoingViewController alloc]initWithEventMode:event withMode:goingViewMode withPastCurrentMode:self.tableViewMode];
    goingViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:goingViewController animated:YES];
}


#pragma mark - table view Data Source & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    
    
    EventDetailViewController *eventDetailViewController = [[EventDetailViewController alloc]initWithEvent:event andMode:eventMode];
    eventDetailViewController.hidesBottomBarWhenPushed = YES;
    eventDetailViewController.viewEventMode = self.tableViewMode;
    [[SharedClass getAppNavigationController]pushViewController:eventDetailViewController animated:YES];
//    [self.navigationController pushViewController:eventDetailViewController animated:YES];
}

#pragma mark-Action
- (IBAction)currentFeedButtonClicked:(UIButton *)sender {
    [self.currentButton setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
    [self.pastButton setTitleColor:Rgb2UIColor(170, 170, 170) forState:UIControlStateNormal];
    [UIView animateWithDuration:0.3 animations:^{
        self.labelXConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
    self.tableViewMode=CurrentPastFeedTableViewModeCurrent;
    if (self.currentFeedArray.count>0) {
        self.tableDataArray =self.currentFeedArray;
        [self.tableView reloadData];
    }
    else
    {
        self.tableDataArray = nil;
        [self.tableView reloadData];
        [self getCurrentFeedFromServer:YES];
    }
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (IBAction)pastFeedButtonClicked:(UIButton *)sender {
    [self.pastButton setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
    [self.currentButton setTitleColor:Rgb2UIColor(170, 170, 170) forState:UIControlStateNormal];
    [UIView animateWithDuration:0.3 animations:^{
        self.labelXConstraint.constant = (self.currentButton.size.width + 10);;
        [self.view layoutIfNeeded];
    }];
    
    self.tableViewMode=CurrentPastFeedTableViewModePast;
    if (self.pastFeedArray.count>0) {
        self.tableDataArray =self.pastFeedArray;
        [self.tableView reloadData];
    }
    else
    {
        self.tableDataArray = nil;
        [self.tableView reloadData];
        [self getPastFeedFromServer:YES];
    }
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (IBAction)settingButtonClicked:(UIButton *)sender {
    SettingViewController *settingViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    settingViewController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:settingViewController animated:YES];
}
@end
