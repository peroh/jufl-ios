//
//  GoingViewController.m
//  JUFL
//
//  Created by Ankur on 26/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "GoingViewController.h"
#import "ContactsTableViewCell.h"
#import "FriendsViewController.h"
#import "Mixpanel.h"

@interface GoingViewController ()<UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate>
@property (nonatomic, strong) EventModel *event;
@property (nonatomic, strong) NSMutableArray *allInvitedArray;
@property (nonatomic, strong) NSMutableArray *tableDataArray;
@property (weak, nonatomic) IBOutlet UITableView *goingTableView;
@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIButton *goingButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonLabelXConstraint;
@property (nonatomic, assign) GoingViewMode viewMode;
@property (nonatomic, assign) GoingTableViewMode tableViewMode;
@property (nonatomic, assign) CurrentPastFeedTableViewMode feedViewMode;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *showToMoreButton;
@property (weak, nonatomic) IBOutlet UIButton *hideButton;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;

- (IBAction)hideButtonClicked:(UIButton *)sender;
- (IBAction)hideViewNoButtonClicked:(UIButton *)sender;
- (IBAction)hideViewYesButtonClicked:(UIButton *)sender;

@end
static NSString *cellIdentifier = @"ContactsTableViewCell";
@implementation GoingViewController

#pragma mark - View Lifecycle
- (instancetype)initWithEvent:(EventModel *)event withMode:(GoingViewMode)mode {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.event = event;
        self.viewMode = mode;
    }
    return self;
}
- (instancetype)initWithEventMode:(EventModel *)event withMode:(GoingViewMode)mode withPastCurrentMode:(CurrentPastFeedTableViewMode)pastCurrentMode {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.event = event;
        self.viewMode = mode;
        self.feedViewMode=pastCurrentMode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializeView];
    [self changeViewLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self changeViewLayout];
}
#pragma mark - My Function

- (void)changeViewLayout {
    if (self.viewMode == GoingViewModeInvitee) {
        self.segmentViewHeightConstraint.constant = 0;
        self.segmentView.hidden = YES;
        self.showToMoreButton.hidden = YES;
    }
    else {
        self.tableViewBottomConstraint.constant = 76;
        self.showToMoreButton.hidden = NO;
    }
    self.showToMoreButton.enabled = !self.event.isDeleted;
    if (self.feedViewMode==CurrentPastFeedTableViewModePast) {
        self.showToMoreButton.enabled=NO;
        
    }
    if (!self.showToMoreButton.isEnabled) {
        self.showToMoreButton.backgroundColor = Rgb2UIColorWithAlpha(97, 97, 97, 0.4);
    }
    else {
        self.showToMoreButton.backgroundColor = Rgb2UIColor(33, 205, 182);
    }
    
    [self.view layoutIfNeeded];
}

- (void)initializeView {
    self.noDataLabel.text=@"All people are going.";
    [self.noDataLabel setHidden:YES];
    if (self.feedViewMode==CurrentPastFeedTableViewModePast) {
        self.showToMoreButton.enabled = NO;
    }
    if (self.viewMode==GoingViewModeCreator) {
        [self.hideButton setHidden:NO];
        [self.inviteButton setTitle:@"Showing to" forState:UIControlStateNormal];
    }else
    {
        if (self.tableViewMode == GoingTableViewModeGoing) {
            [self.hideButton setHidden:YES];
        }
        else
            [self.hideButton setHidden:NO];
    }
    
    self.hideButton.userInteractionEnabled=NO;
    self.allInvitedArray = [[NSMutableArray alloc]init];
    [self.goingTableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.goingTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self fetchParticipantList];
}

- (void)fetchParticipantList {
    [Utils startActivityIndicatorWithMessage:@"Getting Participants"];
    [UserModel getParticipantListWithParameters:@{kEventId:self.event.eventId} completion:^(BOOL success, NSArray *users, NSError *error) {
        [Utils createMainQueue:^{
            
            if (success) {
                 //DLog(@"PUser = %@",users);
                self.allInvitedArray = [users mutableCopy];
                
                self.tableViewMode = GoingTableViewModeGoing;
                self.tableDataArray = [[self filterGoingUsers:YES]mutableCopy];
                
                if (self.viewMode==GoingViewModeCreator) {
                   DLog(@"self.openTabStr = %@",self.openTabStr);
                    if ([self.openTabStr isEqualToString:kTabGoing]) {
                        [self goingClicked:nil];
                    }
                    else{
                        [self invitedClicked:nil];
                    }
                
                }
                else{
                 [self goingClicked:nil];
                }
                
                [Utils stopActivityIndicatorInView];
                
                //DLog(@"self.table invited arary = %@",self.allInvitedArray);
                 //DLog(@"self.table DataArray = %@",self.tableDataArray);
                if (self.tableDataArray.count>0) {
                    [self.goingTableView reloadData];
                    [self.noDataLabel setHidden:YES];
                }else
                {
                    [self.goingTableView reloadData];
                    [self.noDataLabel setHidden:NO];
                }
            }
            else {
                [Utils stopActivityIndicatorInView];
            }
            
        }];
    }];
}

- (NSArray *)filterGoingUsers:(BOOL)isGoing {
    
    NSArray *filterArray = [[NSArray alloc]init];
    NSPredicate *predicate = nil;
    if (isGoing) {
        predicate = [NSPredicate predicateWithFormat:@"userResponse == %@", [NSNumber numberWithInteger:EventResponseAccepted]];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"userResponse != %@", [NSNumber numberWithInteger:EventResponseAccepted]];
    }
    filterArray = [self.allInvitedArray filteredArrayUsingPredicate:predicate];
    return filterArray;
}

- (void)callUserAtIndexPath:(NSIndexPath *)indexPath {
    UserModel *user = self.tableDataArray[indexPath.row];
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:[NSString stringWithFormat:@"%@%@",user.countryCode,user.mobileNo]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void)messageUserAtIndexPath:(NSIndexPath *)indexPath {
    UserModel *user = self.tableDataArray[indexPath.row];
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
        [messageComposer setRecipients:@[user.mobileNo]];
        messageComposer.messageComposeDelegate = self;
        [self presentViewController:messageComposer animated:YES completion:^{
        }];
    }
}

- (void)addUserToContacts :(NSIndexPath *)indexPath {
    UserModel *user = self.tableDataArray[indexPath.row];
    [[KTSContactsManager sharedManager]addContactName:user.firstName lastName:user.lastName
                                               phones:@[@{@"value":[NSString stringWithFormat:@"%@%@",user.countryCode,user.mobileNo]}] emails:nil birthday:nil image:nil completion:^(BOOL wasAdded) {
                                                   if (wasAdded) {
                                                       [[Contacts sharedInstance].friendsArray addObject:user];
                                                       [TSMessage showNotificationInViewController:self title:@"Contact added" subtitle:[NSString stringWithFormat:@"You've added %@ to your contacts",user.firstName] type:TSMessageNotificationTypeMessage];
                                                   }
                                                   else {
                                                       [TSMessage showNotificationInViewController:self title:@"Contact not added" subtitle:[NSString stringWithFormat:@"Please check contacts permission in phone settings."] type:TSMessageNotificationTypeMessage];
                                                   }
                                                   
                                                   user.userExistInContacts = wasAdded;
                                                   
                                                   [self.goingTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                                   
                                               }];
}

- (void)removeUserFromEventAtIndexPath:(NSIndexPath *)indexPath {
    UserModel *user = self.tableDataArray[indexPath.row];
    [EventModel removeUserFromEventWithParameters:@{kEventId: self.event.eventId, kFriendId : user.userId} completion:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            [self.allInvitedArray removeObject:user];
            [self.tableDataArray removeObject:user];
            [self.goingTableView reloadData];
        }
    }];
}

-(void)updateOnServer
{
    NSDictionary *params = @{kEventId:self.event.eventId};
    if (self.viewMode==GoingViewModeCreator) {
        [EventModel hideEventWithParameters:params completion:^(BOOL success, NSError *error) {
            if(success)
            {
                [self fetchParticipantList];
            }
        }];
    }
}

- (void)blockUser:(NSIndexPath *)index {
    UserModel *user = self.tableDataArray[index.row];
    NSString *type = @"block";
    BOOL isblock=user.isBlocked;
    if (user.isBlocked) {
        type = @"unblock";
    }
    [UserModel blockUserWithParameters:@{kFriendId :user.userId, kType:type} completion:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            for (UserModel *isBlockedUser in [Contacts sharedInstance].friendsArray) {
                if ([user.userId isEqualToNumber:isBlockedUser.userId]) {
                    isBlockedUser.isBlocked=!isBlockedUser.isBlocked;
                }
            }
            user.isBlocked = !isblock;
            [self.goingTableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}


-(void)hideView
{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.blurView.alpha=0.0f;
        self.blurView.hidden=YES;
    } completion:^(BOOL finished)
     {
         
     }];
}


#pragma mark - IBAction
- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)invitedClicked:(id)sender {
    if (self.tableDataArray.count>0) {
        self.hideButton.userInteractionEnabled=YES;
    }else{
        self.hideButton.userInteractionEnabled=NO;
    }
    [self.hideButton setHidden:NO];
    self.inviteButton.selected = YES;
    self.goingButton.selected = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.buttonLabelXConstraint.constant = (self.inviteButton.size.width + 10);
        [self.view layoutIfNeeded];
    }];
    [self.inviteButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
    [self.goingButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
    self.tableViewMode = GoingTableViewModeInvited;
    self.tableDataArray = [[self filterGoingUsers:NO]mutableCopy];
    if (self.tableDataArray.count>0) {
        [self.noDataLabel setHidden:YES];
    }
    else
    {
        self.noDataLabel.text=@"All people are going.";
        [self.noDataLabel setHidden:NO];
    }
    [[Mixpanel sharedInstance] track:@"Users" properties:@{@"EventID":self.event.eventId,@"InvitedUser":[NSNumber numberWithUnsignedLong:self.tableDataArray.count]}];
    [self.goingTableView reloadData];
}
- (IBAction)goingClicked:(id)sender {
    self.hideButton.userInteractionEnabled=NO;
    [self.hideButton setHidden:YES];
    self.inviteButton.selected = NO;
    self.goingButton.selected = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.buttonLabelXConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
    
    [self.inviteButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
    [self.goingButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
    self.tableViewMode = GoingTableViewModeGoing;
    self.tableDataArray = [[self filterGoingUsers:YES]mutableCopy];
    if (self.tableDataArray.count>0) {
        [self.noDataLabel setHidden:YES];
    }else
    {
        [self.noDataLabel setHidden:NO];
    }
    [[Mixpanel sharedInstance] track:@"Users" properties:@{@"EventID":self.event.eventId,@"GoingUser":[NSNumber numberWithUnsignedLong:[self.event.goingCount integerValue]]}];
    [self.goingTableView reloadData];
}
- (IBAction)showToMoreClicked:(id)sender {
    FriendsViewController *friendsViewController = [[FriendsViewController alloc]initWithViewMode:FriendViewModeInviteMore eventModel:self.event invitedUsers:self.allInvitedArray];
    [self.navigationController pushViewController:friendsViewController animated:YES];
}

#pragma mark - Table data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)
indexPath {
    
    ContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UserModel *user = self.tableDataArray[indexPath.row];
    [cell setAppUserData:user];
    if (user.userExistInContacts) {
        
        cell.backgroundColor = [UIColor whiteColor];
    }
    else {
        cell.backgroundColor = Rgb2UIColorWithAlpha(97, 97, 97, .3);
    }
    
    if (user.userResponse == EventResponseRejected) {
        cell.declinedLabel.hidden = NO;
    }
    else {
        cell.declinedLabel.hidden = YES;
    }
    cell.selectionButton.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *optionArray = nil;
    UserModel *user = self.tableDataArray[indexPath.row];
    NSNumber *currentUid = numberValue([UserDefaluts objectForKey:kCurrentUserID]);
    if ([user.userId isEqualToNumber:currentUid]) {
        return;
    }
    
    
    if (self.tableViewMode == GoingTableViewModeGoing) {
        if (user.userExistInContacts && user.isBlocked) {
            optionArray = @[@"Call", @"Message", @"Unblock"];
        }
        else if (user.userExistInContacts && !user.isBlocked)
        {
            optionArray = @[@"Call", @"Message", @"Block"];
        }else if (!user.userExistInContacts && !user.isBlocked)
        {
            optionArray = @[@"Call", @"Message", @"Block", @"Add to contacts"];
        }else if (!user.userExistInContacts && user.isBlocked)
        {
            optionArray = @[@"Call", @"Message", @"Unblock", @"Add to contacts"];
        }
        [[Utils sharedInstance]openActionSheetWithTitle:user.firstName buttons:optionArray completion:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self callUserAtIndexPath:indexPath];
            }
            else if (buttonIndex == 1) {
                [self messageUserAtIndexPath:indexPath];
            } else if (buttonIndex == 2) {
                [self blockUser:indexPath];
            }
            else if (buttonIndex == 3 && optionArray.count == 4){
                [self addUserToContacts:indexPath];
            }
        }];
    }
    else {
        if (!user.userExistInContacts) {
            optionArray = @[@"Call", @"Message", @"Remove from event", @"Add to contacts"];
        }
        else {
            optionArray = @[@"Call", @"Message", @"Remove from event"];
        }
        
        [[Utils sharedInstance]openActionSheetWithTitle:@"Choose" buttons:optionArray completion:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self callUserAtIndexPath:indexPath];
            }
            else if (buttonIndex == 1) {
                [self messageUserAtIndexPath:indexPath];
            }
            else if (buttonIndex == 2) {
                [self removeUserFromEventAtIndexPath:indexPath];
            }
            else if (buttonIndex == 3 && optionArray.count == 4){
                [self addUserToContacts:indexPath];
            }
        }];
    }
}

#pragma mark - MFMessageCompose delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:^{
        if (result == MessageComposeResultSent) {
        }
        else {
            
        }
    }];
}
- (IBAction)hideButtonClicked:(UIButton *)sender {
    if (self.tableDataArray.count>0) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.blurView.alpha=1.0f;
            self.blurView.hidden=NO;
        } completion:^(BOOL finished)
         {
             
         }];
    }else
    {
        self.hideButton.userInteractionEnabled=NO;
    }
}

- (IBAction)hideViewNoButtonClicked:(UIButton *)sender {
    [self hideView];
}

- (IBAction)hideViewYesButtonClicked:(UIButton *)sender {
    [self hideView];
    [self updateOnServer];
}
@end
