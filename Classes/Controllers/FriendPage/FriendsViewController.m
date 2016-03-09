//
//  FriendsViewController.m
//  JUFL
//
//  Created by Ankur on 13/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "FriendsViewController.h"
#import "Contacts.h"
#import "ContactsTableViewCell.h"
#import "SelectAllTableViewCell.h"
#import "EventCreatedViewController.h"
#import "SVPullToRefresh.h"
#import "ProfileImageViewController.h"
#import "Mixpanel.h"
#import "AppDelegate.h"

@interface FriendsViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MFMessageComposeViewControllerDelegate>
{
    BOOL isSelectedAll;
}

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (nonatomic, strong) NSMutableArray *contactsArray;
@property (nonatomic, strong) NSMutableArray *friendArray;
@property (nonatomic, strong) NSArray *tableDataArray;
@property (nonatomic, assign) FriendViewMode viewMode;
@property (nonatomic, assign) FriendTableViewMode tableViewMode;
@property (nonatomic, strong) EventModel *currentEvent;
@property (weak, nonatomic) IBOutlet UIButton *showActivityButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomConstraint;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *friendsButton;
@property (weak, nonatomic) IBOutlet UIButton *contactsButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *navTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonLabelXConstraint;
@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (nonatomic, strong) NSString *friendSelected;
@property (nonatomic, strong) NSArray *alreadyInvitedUsers;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
@property (weak, nonatomic) IBOutlet UIView *contactPermissionView;

@end

static NSString *cellIdentifier = @"ContactsTableViewCell";
static NSString *selectCellId = @"SelectAllTableViewCell";

@implementation FriendsViewController

#pragma mark - View life cycle
- (instancetype)initWithViewMode:(FriendViewMode)mode {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.viewMode = mode;
    }
    return self;
}

- (instancetype)initWithViewMode:(FriendViewMode)mode eventModel:(EventModel *)event {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.viewMode = mode;
        self.currentEvent = event;
    }
    return self;
}

- (instancetype)initWithViewMode:(FriendViewMode)mode eventModel:(EventModel *)event invitedUsers:(NSArray *)users {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.viewMode = mode;
        self.currentEvent = event;
        self.alreadyInvitedUsers = users;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self initializeView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(friendsUpdated:)
                                                 name:@"FriendsUpdateNotification"
                                               object:nil];
    
    [self changeViewLayout];
    [self changeShowAllButtonState];
    [self checkContactPermission];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[Mixpanel sharedInstance] track:@"MyFriendsTapped"];
    isSelectedAll = NO;
    [self deselectAllUsers];
    [self changeShowAllButtonState];
    [self changeViewLayout];
    [self.contactsTableView reloadData];
}
#pragma mark - My functions
- (void)checkContactPermission {
    [Contacts askContactPermission:^(BOOL success) {
        [Contacts sharedInstance].isContactsAllowed = success;
        if (success) {
            [self initializeView];
        }
        else {
            [self showContactPermissionView];
        }
    }];
}

- (void)friendsUpdated:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"FriendsUpdateNotification"]) {
        
        [self fillContactsData:[Contacts sharedInstance].friendsArray andNonUser:[Contacts sharedInstance].contactsArray];
    }
        
}

- (void)changeViewLayout {
    if (self.viewMode == FriendViewModeInviteUsers || self.viewMode == FriendViewModeInviteMore) {
        self.segmentHeightConstraint.constant = 0;
        self.tableBottomConstraint.constant = 76;
        self.showActivityButton.hidden = NO;
        self.backButton.hidden = NO;
    }
    [self.view layoutIfNeeded];
}

- (NSArray *)filterBlockedUsers {
    NSArray *filterArray = [[NSArray alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isBlocked == %@", [NSNumber numberWithBool:NO]];
    filterArray = [self.friendArray filteredArrayUsingPredicate:predicate];
    return filterArray;
}


- (NSArray *)filterAlreadyInvitedUser {
    
    NSArray *filterArray = [[NSArray alloc]init];
    filterArray = [self filterBlockedUsers];
    NSMutableArray *tempIDArray = [[NSMutableArray alloc] init];
    
    for (UserModel *user in  self.alreadyInvitedUsers) {
        [tempIDArray addObject:user.userId];
    }
    
    UserModel *currentUser = [[UserModel alloc]initWithUserTable:[UserModel currentUser]];
    [tempIDArray addObject:currentUser.userId];
    //    NOT(%K IN %@)
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT(%K IN %@)",@"userId",tempIDArray];
    NSArray *tempInviteArray = [filterArray filteredArrayUsingPredicate:predicate];
    
    return tempInviteArray;
}

- (void)showContactPermissionView {
    self.contactPermissionView.hidden = NO;
    self.contactsTableView.hidden = YES;
    self.noDataLabel.hidden = YES;
    self.searchBar.hidden = YES;
    self.showActivityButton.hidden = NO;
    self.closeButton.hidden = YES;
    if (self.viewMode == FriendViewModeInviteUsers || self.viewMode == FriendViewModeInviteMore) {
    self.backButton.hidden = NO;
    }
    else {
        self.backButton.hidden = YES;
    }
    self.segmentView.hidden = YES;
    [self.showActivityButton setTitle:@"Settings" forState:UIControlStateNormal];
    [self toggleNextButtonState:YES];
    
}

- (void)initializeView {
    self.contactPermissionView.hidden = YES;
    self.contactsTableView.hidden = NO;
    if (!self.friendArray.count || !self.contactsArray.count) {
        self.noDataLabel.hidden = NO;
    }
    
    self.searchBar.hidden = NO;
    self.contactsArray = [[NSMutableArray alloc]init];
    self.friendArray = [[NSMutableArray alloc]init];
    self.tableDataArray = [[NSArray alloc]init];
    self.tableViewMode = FriendTableViewModeAppUser;
    self.backButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.segmentView.hidden = NO;
    self.navTitleLabel.text = @"MY FRIENDS";
    [self toggleNextButtonState:NO];
    if (self.viewMode == FriendViewModeInviteUsers) {
        self.backButton.hidden = NO;
        self.closeButton.hidden = YES;
        self.navTitleLabel.text = @"WHO";
        self.segmentView.hidden = YES;
        [self toggleNextButtonState:YES];
        self.tableViewMode = FriendTableViewModeAppUser;
    }
    else if (self.viewMode == FriendViewModeInviteMore) {
        self.backButton.hidden = NO;
        self.closeButton.hidden = YES;
        self.navTitleLabel.text = @"SHOW TO";
        self.segmentView.hidden = YES;
        self.tableViewMode = FriendTableViewModeAppUser;
        
    }
    else {
        [self.showActivityButton setTitle:@"Invite friends to Jufl app" forState:UIControlStateNormal];
    }
    [self.contactsTableView addPullToRefreshWithActionHandler:^{
        if ([Utils isInternetAvailable]) {
            [Utils createBackGroundQueue:^{
                [self.noDataLabel setHidden:YES];
                [self fetchContactsFromServer];
            }];
        }
        else {
                [self.contactsTableView.pullToRefreshView stopAnimating];
        }
    }];
    [self.friendsButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
    [self.contactsButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
    self.friendsButton.selected = YES;
    self.contactsButton.selected = NO;
    self.contactsTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.contactsTableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [self.contactsTableView registerNib:[UINib nibWithNibName:selectCellId bundle:nil] forCellReuseIdentifier:selectCellId];
    [self performSelector:@selector(getContacts) withObject:self afterDelay:0.0];
}

- (void)getContacts {
    if ([Contacts sharedInstance].contactsArray.count == 0 && [Contacts sharedInstance].isFetchingContacts == NO) {
        [Utils startActivityIndicatorWithMessage:@"Fetching contacts"];
        [Utils createBackGroundQueue:^{
            [self.noDataLabel setHidden:YES];
            [self fetchContactsFromServer];
        }];
        
    }
    else if ([Contacts sharedInstance].isFetchingContacts){
        if ([Contacts sharedInstance].addressBookArray.count) {
            [Utils startActivityIndicatorWithMessage:@"Fetching contacts"];
        }
//        [[Contacts sharedInstance] fetchContactsFromAddressBookWithHandler:^(BOOL success, NSArray *appUser, NSArray *nonAppUser, NSError *error) {
//            [self fillContactsData:appUser andNonUser:nonAppUser];
//        }];
        
    }
    else {
        
        [self fillContactsData:[Contacts sharedInstance].friendsArray andNonUser:[Contacts sharedInstance].contactsArray];
    }
}

- (void)fillContactsData:(NSArray *)appUser andNonUser:(NSArray *)nonAppUser {
    [Utils createMainQueue:^{
        [self.contactsTableView.pullToRefreshView stopAnimating];
        [Utils stopActivityIndicatorInView];
        self.friendArray = [NSMutableArray arrayWithArray:appUser];
        
        NSNumber *friendUsersCount = [NSNumber numberWithUnsignedLong:self.friendArray.count];
        NSNumber *currentUID = numberValue([UserDefaluts objectForKey:kCurrentUserID]);
        [[Mixpanel sharedInstance] track:@"UserFriendsCount" properties:@{@"UserId" : currentUID,@"FriendsCount" : friendUsersCount}];
        self.contactsArray = [NSMutableArray arrayWithArray:nonAppUser];
        if (self.tableViewMode == FriendTableViewModeAppUser) {
            self.tableDataArray = [NSArray arrayWithArray:self.friendArray];
            if (self.viewMode == FriendViewModeInviteUsers) {
                self.tableDataArray = [self filterBlockedUsers];
            }
            else if (self.viewMode == FriendViewModeInviteMore) {
                self.tableDataArray = [self filterAlreadyInvitedUser];
            }
        }
        else {
            self.tableDataArray = [NSArray arrayWithArray:self.contactsArray];
        }
        [self.contactsTableView reloadData];
        
        if (self.tableDataArray.count > 0) {
            
            [self.noDataLabel setHidden:YES];
        }
        else
        {
            [self.noDataLabel setHidden:NO];
        }
        
    }];
    if (self.tableDataArray.count > 0) {
        
        [self.noDataLabel setHidden:YES];
    }
    else
    {
        [self.noDataLabel setHidden:NO];
    }
}


- (void)fetchContactsFromServer {
    [[Contacts sharedInstance] fetchContactsFromAddressBookWithHandler:^(BOOL success, NSArray *appUser, NSArray *nonAppUser, NSError *error) {
        [self fillContactsData:appUser andNonUser:nonAppUser];
    }];
}
- (void)selectUserAtIndex:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.tableViewMode == FriendTableViewModeNonUser) {
        if ([self getSelectedUserArray].count >= 10 && sender.selected) {
            [TSMessage showNotificationWithTitle:@"You can select maximum of 10 contacts at a time" type:TSMessageNotificationTypeMessage];
            [self.contactsTableView reloadData];
            
            [self changeShowAllButtonState];
        }
        else {
            Contacts *user = self.tableDataArray[sender.tag];
            user.isSelected = sender.selected;
            if ([self getSelectedUserArray].count == self.contactsArray.count) {
                isSelectedAll = YES;
            }
            else {
                isSelectedAll = NO;
            }
            
            [self.contactsTableView reloadData];
            
            [self changeShowAllButtonState];
        }
        
    }
    else {
        if (sender.tag == 0) {
            isSelectedAll = sender.selected;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
            [self.contactsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            if (isSelectedAll) {
                [self selectAllUsers];
            }
            else {
                [self deselectAllUsers];
            }
            [self.contactsTableView reloadData];
            [self changeShowAllButtonState];
            return;
        }
        UserModel *user = self.tableDataArray[sender.tag-1];
        user.isSelected = sender.selected;
        if (self.viewMode == FriendViewModeInviteUsers) {
            if ([self getSelectedUserArray].count == [self filterBlockedUsers].count) {
                isSelectedAll = YES;
            }
            else {
                isSelectedAll = NO;
            }
            
        }
        else if (self.viewMode == FriendViewModeInviteMore) {
            if ([self getSelectedUserArray].count == [self filterAlreadyInvitedUser].count) {
                isSelectedAll = YES;
            }
            else {
                isSelectedAll = NO;
            }
        }
        
        [self.contactsTableView reloadData];
        [self changeShowAllButtonState];
    }
}

- (void)changeShowAllButtonState {
    NSArray *selectedUser = [self getSelectedUserArray];
    NSString *title = nil;
    BOOL nextButtonState = NO;
    if (self.tableViewMode == FriendTableViewModeNonUser) {
        title = @"Invite friends to Jufl app";
        if (selectedUser.count == 1) {
            title = @"Invite 1 friend to Jufl app";
            nextButtonState = YES;
        }
        else if (selectedUser.count > 1){
            
            title =[NSString stringWithFormat:@"Invite %ld friends to Jufl app",selectedUser.count];
            nextButtonState = YES;
        }
    }
    else {
        title = @"Show activity to friends";
        if (selectedUser.count == 1) {
            title = @"Show to 1 friend";
            nextButtonState = YES;
        }
        else if (selectedUser.count > 1){
            
            title =[NSString stringWithFormat:@"Show to %ld friends",selectedUser.count];
            nextButtonState = YES;
        }
        else {
            if (self.viewMode == FriendViewModeInviteMore) {
                nextButtonState = NO;
            }
            else {
                nextButtonState = YES;
            }
            if ([Contacts sharedInstance].isContactsAllowed) {
            title = @"Create activity";
            }
            else {
                title = @"Settings";
            }
        }
    }
    
    
    [self toggleNextButtonState:nextButtonState];
    [self.showActivityButton setTitle:title forState:UIControlStateNormal];
}

- (void)deselectAllUsers {
    if (self.tableViewMode == FriendTableViewModeNonUser) {
        for (Contacts *user in  [self getSelectedUserArray]) {
            user.isSelected = NO;
        }
        [self toggleNextButtonState:NO];
    }
    else {
        for (UserModel *user in  [self getSelectedUserArray]) {
            user.isSelected = NO;
        }
    }
    
    [self.contactsTableView reloadData];
}

- (void)selectAllUsers {
    if (self.tableViewMode == FriendTableViewModeNonUser) {
        for (Contacts *user in  self.tableDataArray) {
            user.isSelected = YES;
        }
        
    }
    else {
        for (UserModel *user in  self.tableDataArray) {
            user.isSelected = YES;
        }
        
    }
    
    [self.contactsTableView reloadData];
}


- (void)toggleNextButtonState:(BOOL)isEnabled {
    self.showActivityButton.enabled = isEnabled;
    self.showActivityButton.backgroundColor = Rgb2UIColorWithAlpha(97, 97, 97, 0.4);
    if (isEnabled) {
        self.showActivityButton.backgroundColor = Rgb2UIColor(33, 205, 182);
    }
    
}

-(NSArray *)getSelectedUserArray {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected == %@", [NSNumber numberWithBool:YES]];
    NSArray *selectedUser = nil;
    if (self.tableViewMode == FriendTableViewModeNonUser)  {
        self.contactsArray = [NSMutableArray arrayWithArray:[Contacts sharedInstance].contactsArray];
        
        selectedUser = [self.contactsArray filteredArrayUsingPredicate:predicate];
    }
    else {
        self.friendArray = [NSMutableArray arrayWithArray:[Contacts sharedInstance].friendsArray];
        
        selectedUser = [self.friendArray filteredArrayUsingPredicate:predicate];
    }
    return selectedUser;
}

-(NSArray *)getSelectedUserIds {
    NSMutableArray *userIds = [[NSMutableArray alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected == %@", [NSNumber numberWithBool:YES]];
    NSArray *selectedUser = [self.friendArray filteredArrayUsingPredicate:predicate];
    for (UserModel *user in  selectedUser) {
        [userIds addObject:[user.userId stringValue]];
    }
    return userIds;
}


-(NSArray *)getSelectedContactNumbers {
    NSMutableArray *contactNumbers = [[NSMutableArray alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected == %@", [NSNumber numberWithBool:YES]];
    NSArray *selectedUser = [self.contactsArray filteredArrayUsingPredicate:predicate];
    for (Contacts *user in  selectedUser) {
        [contactNumbers addObject:user.mobileNo];
    }
    return contactNumbers;
}

- (void)showToast:(BOOL)created {
    
    NSInteger friendCount = [self getSelectedUserIds].count;
    NSString *friendStr = friendCount == 1? @"friend":@"friends";
    
    NSString *messageString = [NSString stringWithFormat:@"You are showing %@ to %li %@",self.currentEvent.name,(long)friendCount,friendStr];
    if (!created) {
        messageString = [NSString stringWithFormat:@"You are now showing %@ to %li %@",self.currentEvent.name,(long)friendCount,friendStr];
    }
     [TSMessage showNotificationInViewController:appDelegate.window.rootViewController title:messageString subtitle:nil type:TSMessageNotificationTypeMessage];
}

- (void)goToNextPage {
    
    [SharedClass sharedInstance].currentEvent = [[EventModel alloc]init];
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:YES];
    if (self.viewMode == FriendViewModeInviteUsers) {
        [self showToast:YES];
    }
    else {
        [self showToast:NO];
    }
    
    /*EventCreatedViewController *eventCreatedViewController = [[EventCreatedViewController alloc]initWithEventModel:self.currentEvent andFriends:[NSString stringWithFormat:@"%ld",[self getSelectedUserIds].count]];
    eventCreatedViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:eventCreatedViewController animated:YES];*/
}

- (void)goToFriendsInvitedPage {
    NSInteger friendCount = [self getSelectedUserIds].count;
    NSString *friendStr = friendCount == 1? @"friend":@"friends";
    
    NSString *messageString = [NSString stringWithFormat:@"You have invited %@ %@ to Jufl",self.friendSelected,friendStr];
    
    [TSMessage showNotificationInViewController:appDelegate.window.rootViewController title:messageString subtitle:nil type:TSMessageNotificationTypeMessage];
}

- (void)openSMSController {
    self.friendSelected = [NSString stringWithFormat:@"%ld",[self getSelectedUserArray].count];
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
        NSString *message = @"I’m catching up with friends on Jufl. Check out the iPhone app if you want to join us!\n https://itunes.apple.com/us/app/jufl/id1040129321?ls=1&mt=8";
        [messageComposer setBody:message];
        [messageComposer setRecipients:[self getSelectedContactNumbers]];
        messageComposer.messageComposeDelegate = self;
        [self presentViewController:messageComposer animated:YES completion:^{
        }];
    }
}

- (void)blockUser:(NSIndexPath *)index {
    UserModel *user = self.tableDataArray[index.row];
    NSString *type = @"block";
    if (user.isBlocked) {
        type = @"unblock";
    }
    [UserModel blockUserWithParameters:@{kFriendId :user.userId, kType:type} completion:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            user.isBlocked = !user.isBlocked;
            [self.contactsTableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

- (void)showUserProfilePhoto :(NSIndexPath *)index {
    UserModel *user = self.tableDataArray[index.row];
    ProfileImageViewController *profileImageViewController = [[ProfileImageViewController alloc]initWithUser:user];
    [self.navigationController presentViewController:profileImageViewController animated:YES completion:^{
        
    }];
}
#pragma mark - IBActions
- (IBAction)showActivityClicked:(id)sender {
    if ([Contacts sharedInstance].isContactsAllowed) {
        if (self.viewMode == FriendViewModeInviteUsers) {
            NSMutableDictionary *dict = [[EventModel getDictionaryFromModel:self.currentEvent addLocation:YES] mutableCopy];
            NSMutableArray *invitedArray = [NSMutableArray arrayWithArray:[self getSelectedUserIds]];
            
            NSNumber *currentUID = numberValue([UserDefaluts objectForKey:kCurrentUserID]);
            
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"HH:mm"];
//            DLog(@"periodDuration: %@",[dateFormatter stringFromDate:[NSDate date]]);
//            NSString *date=[dateFormatter stringFromDate:[NSDate date]];

            [invitedArray addObject:currentUID]; // adding current user id to invited list.
            [dict setObject:invitedArray forKey:kInvitedIds];
            [EventModel createEventWithParams:dict withHandler:^(BOOL success, NSArray *events, NSError *error) {
                if (success) {
                    EventModel *event = [events firstObject];
                    [[Mixpanel sharedInstance] track:@"Time" properties:@{kEventId :event.eventId,@"CreateTime" :[NSDate date] ,@"StartTime" :event.startTime}];
                    
                    NSTimeInterval distanceBetweenDates = [event.startTime timeIntervalSinceDate:[NSDate date]];
                    double secondsInAnHour = 3600;
                    NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
                    if (!hoursBetweenDates>=1) {
                        [[Mixpanel sharedInstance] track:@"Type" properties:@{@"Random" :@"YES",@"Time" : [NSDate date]}];
                    }else
                    {
                        [[Mixpanel sharedInstance] track:@"Type" properties:@{@"Planned" :@"YES",@"Time" : [NSDate date]}];
                    }
                     [[Mixpanel sharedInstance] track:@"CreatedCount" properties:@{@"UserId" : currentUID}];
                    [[Mixpanel sharedInstance] track:@"ActivityName" properties:@{@"name" : event.name}];
                    [self goToNextPage];
                }
            }];
        }
        else if (self.viewMode == FriendViewModeInviteMore) {
            [EventModel addUsersToEventWithParameters:@{kEventId :self.currentEvent.eventId, kInvitedIds: [self getSelectedUserIds],kEventName:self.currentEvent.name} completion:^(BOOL success, NSDictionary *response, NSError *error) {
                if (success) {
                    [self goToNextPage];
                }
            }];
        }
        else {
            [self openSMSController];
        }

    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}
- (IBAction)friendsClicked:(id)sender {
    RESIGN_KEYBOARD
    self.searchBar.text = @"";
    self.searchBar.showsCancelButton = NO;
    self.friendsButton.selected = YES;
    self.contactsButton.selected = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.buttonLabelXConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
    [self.friendsButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
    [self.contactsButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
    self.showActivityButton.hidden = YES;
    self.tableBottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
    self.tableViewMode = FriendTableViewModeAppUser;
    self.tableDataArray = [NSArray arrayWithArray:self.friendArray];
    if (self.tableDataArray.count>0) {
        [self.noDataLabel setHidden:YES];
    }
    else
    {
        [self.noDataLabel setHidden:NO];
    }
    [self.contactsTableView reloadData];
}

- (IBAction)contactsClicked:(id)sender {
    RESIGN_KEYBOARD
    self.searchBar.text = @"";
    self.searchBar.showsCancelButton = NO;
    self.friendsButton.selected = NO;
    self.contactsButton.selected = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.buttonLabelXConstraint.constant = -(self.friendsButton.size.width + 10);
        [self.view layoutIfNeeded];
    }];
    
    [self.friendsButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
    [self.contactsButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
    self.showActivityButton.hidden = NO;
    self.tableBottomConstraint.constant = 76;
    [self.view layoutIfNeeded];
    self.tableViewMode = FriendTableViewModeNonUser;
    [self changeShowAllButtonState];
    self.tableDataArray = [NSArray arrayWithArray:self.contactsArray];
    if (self.tableDataArray.count>0) {
        [self.noDataLabel setHidden:YES];
    }
    else
    {
        [self.noDataLabel setHidden:NO];
    }
    [self.contactsTableView reloadData];
}
- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)closeClicked:(id)sender {
    [[Utils sharedInstance]openAlertViewWithTitle:kTitle message:@"Current event data will be lost. Do you want to continue?" buttons:@[@"Cancel", @"Ok"] completion:^(UIAlertView *alert, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [SharedClass sharedInstance].currentEvent = [[EventModel alloc]init];
            self.currentEvent = [SharedClass sharedInstance].currentEvent;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - Delegates
#pragma mark - Table Data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ((self.viewMode == FriendViewModeInviteUsers || self.viewMode == FriendViewModeInviteMore) && self.tableViewMode == FriendTableViewModeAppUser) {
        if ([Contacts sharedInstance].isContactsAllowed && self.tableDataArray.count > 0) {
            return self.tableDataArray.count+1;
        }
        return 0;
    }
    return self.tableDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    SelectAllTableViewCell *selectCell = [tableView dequeueReusableCellWithIdentifier:selectCellId];
    
    if (self.viewMode == FriendViewModeShowUsers) {
        if(self.tableViewMode == FriendTableViewModeAppUser) {
            UserModel *user = self.tableDataArray[indexPath.row];
            cell.selectionButton.selected = user.isSelected;
            cell.selectionButton.hidden = YES;
            [cell setAppUserData:user];
        }
        else {
            Contacts *contact = self.tableDataArray[indexPath.row];
            cell.selectionButton.selected = contact.isSelected;
            cell.selectionButton.hidden = NO;
            [cell setNonAppUserData:contact];
            //            }
        }
    }
    else {
        if (indexPath.row == 0) {
            selectCell.contactNameLabel.text = @"Show to all friends";
            selectCell.contactImageView.layer.cornerRadius = 0;
            selectCell.selectionButton.selected = isSelectedAll;
            selectCell.selectionButton.tag = indexPath.row;
            [selectCell.selectionButton addTarget:self action:@selector(selectUserAtIndex:) forControlEvents:UIControlEventTouchUpInside];
            selectCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return selectCell;
        }
        else {
            UserModel *user = self.tableDataArray[indexPath.row-1];
            cell.selectionButton.selected = user.isSelected;
            [cell setAppUserData:user];
        }
    }
    cell.selectionButton.tag = indexPath.row;
    [cell.selectionButton addTarget:self action:@selector(selectUserAtIndex:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RESIGN_KEYBOARD
    
    if (self.viewMode == FriendViewModeShowUsers && self.tableViewMode == FriendTableViewModeAppUser) {
        UserModel *user = self.tableDataArray[indexPath.row];
        if (user.isBlocked) {
            [[Utils sharedInstance]openActionSheetWithTitle:@"Choose" buttons:@[@"Unblock user"] completion:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [self blockUser:indexPath];
                }
            }];
        }
        else {
            NSArray *buttonArray;
            if([user.image hasSuffix:@"jpg"])
                buttonArray=[[NSArray alloc]initWithObjects:@"Block user", @"Show photo", nil];
            else
                buttonArray=[[NSArray alloc]initWithObjects:@"Block user", nil];
            
            [[Utils sharedInstance]openActionSheetWithTitle:@"Choose" buttons:buttonArray completion:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0){
                    [[Utils sharedInstance]openAlertViewWithTitle:@"Block User" message:@"Are you sure you want to block this user?" buttons:@[@"Cancel",@"Ok"] completion:^(UIAlertView *alert, NSInteger buttonIndex) {
                        if (buttonIndex == 1)
                        {
                            [self blockUser:indexPath];
                        }
                    }];
                }
                else if (buttonIndex == 1){
                    if (buttonArray.count==2) {
                        [self showUserProfilePhoto:indexPath];
                    }
                    
                }
            }];
        }
    }
    else if (self.viewMode == FriendViewModeInviteUsers || self.viewMode == FriendViewModeInviteMore || self.tableViewMode == FriendTableViewModeNonUser) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = indexPath.row;
        [self selectUserAtIndex:btn];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewMode == FriendViewModeInviteUsers || self.viewMode == FriendViewModeInviteMore) {
        if (indexPath.row == 0) {
            return 45;
        }
        else
            return 70;
    }
    return 70;
}

- (UIRectEdge)edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom;
}

#pragma mark - MFMessageComposeViewControllerDelegate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (result == MessageComposeResultSent) {
            [self goToFriendsInvitedPage];
        }
        else {
            
        }
    }];
}

#pragma mark - Search bar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}// return NO to not become first responder
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}// called when text starts editing
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}// return NO to not resign first responder
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    
}// called when text ends editing
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        if (self.tableViewMode == FriendTableViewModeAppUser) {
            self.tableDataArray = [NSArray arrayWithArray:self.friendArray];
            if (self.viewMode == FriendViewModeInviteUsers) {
                self.tableDataArray = [self filterBlockedUsers];
            }
            else if (self.viewMode == FriendViewModeInviteMore) {
                self.tableDataArray = [self filterAlreadyInvitedUser];
            }
        }
        else {
            self.tableDataArray = [NSArray arrayWithArray:self.contactsArray];
        }

    }
    else {
//    NSPredicate *firstPredicate = [NSPredicate predicateWithFormat:@"SELF.firstName CONTAINS[cd] %@ OR SELF.lastName CONTAINS[cd] %@" , searchText, searchText];
        NSPredicate *firstPredicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS[cd] %@" , searchText];
    self.tableDataArray = [[self.contactsArray filteredArrayUsingPredicate:firstPredicate] mutableCopy];
    if (self.tableViewMode == FriendTableViewModeAppUser) {
        self.tableDataArray = [[self.friendArray filteredArrayUsingPredicate:firstPredicate] mutableCopy];
        if (self.viewMode == FriendViewModeInviteUsers) {
            self.tableDataArray = [[[self filterBlockedUsers] filteredArrayUsingPredicate:firstPredicate] mutableCopy];
        }
        else if (self.viewMode == FriendViewModeInviteMore) {
            self.tableDataArray = [[[self filterAlreadyInvitedUser]filteredArrayUsingPredicate:firstPredicate]mutableCopy];
        }
    }
    }
    [self.contactsTableView reloadData];
    if (self.tableDataArray.count>0) {
        
        [self.noDataLabel setHidden:YES];
    }
    else
    {
        [self.noDataLabel setHidden:NO];
    }

    
    
}// called when text changes (including clear)
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    RESIGN_KEYBOARD
}// called when keyboard search button pressed
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    
}// called when bookmark button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    //    _noContactLabel.text = @"You don't have any Contacts";
    if (self.tableViewMode == FriendTableViewModeAppUser) {
        self.tableDataArray = [NSArray arrayWithArray:self.friendArray];
        if (self.viewMode == FriendViewModeInviteUsers) {
            self.tableDataArray = [self filterBlockedUsers];
        }
        else if (self.viewMode == FriendViewModeInviteMore) {
            self.tableDataArray = [self filterAlreadyInvitedUser];
        }
    }
    else {
        self.tableDataArray = [NSArray arrayWithArray:self.contactsArray];
    }
    
    [self.contactsTableView reloadData];
    if (self.tableDataArray.count>0) {
        [self.noDataLabel setHidden:YES];
    }
    else
    {
        [self.noDataLabel setHidden:NO];
    }
    RESIGN_KEYBOARD
}// called when cancel button pressed

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    RESIGN_KEYBOARD
    self.searchBar.showsCancelButton = NO;
}

@end
