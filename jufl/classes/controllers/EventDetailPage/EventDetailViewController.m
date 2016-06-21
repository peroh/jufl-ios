//
//  EventDetailViewController.m
//  JUFL
//
//  Created by Ankur on 28/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "EventDetailViewController.h"
#import "CurrentPin.h"
#import "GoingViewController.h"
#import "CreateEventViewController.h"
#import "Mixpanel.h"
#import "TabBarViewController.h"
#import "AppDelegate.h"
#import "NRValidation.h"
#import "ChatViewController.h"
#define MapPinImageName @"annotation"

@interface EventDetailViewController ()<MKMapViewDelegate,UIActionSheetDelegate>
@property (nonatomic, assign)EventDetailMode viewMode;
@property (nonatomic, strong) EventModel *event;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *creatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *creatorName;
@property (weak, nonatomic) IBOutlet UILabel *eventAddressLabel;
@property (weak, nonatomic) IBOutlet MKMapView *eventMapView;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIButton *eventResponseButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *joinLabel;
@property (weak, nonatomic) IBOutlet UILabel *goingLabel;
@property (weak, nonatomic) IBOutlet UITextView *additionalInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *cantGoButton;
@property (nonatomic, assign) BOOL isNewEvent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeButtonTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goingButtonTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tapToGoTopSpace;

@property (weak, nonatomic) IBOutlet UIView *categoryBarView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelXConstraint;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@property (weak, nonatomic) IBOutlet UILabel *badgeCountLbl;
@property (weak, nonatomic) IBOutlet UILabel *unreadChatCountLbl;
- (IBAction)mapFeedButtonClicked:(UIButton *)sender;
- (IBAction)infoFeedButtonClicked:(UIButton *)sender;

@end

@implementation EventDetailViewController

#pragma mark - View life cycle

- (instancetype)initWithEvent :(EventModel *)event andMode:(EventDetailMode)mode {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.viewMode = mode;
        self.event = event;
    }
    return self;
}

- (instancetype)initWithEventId:(NSNumber *)eventId {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.eventId = eventId;
        self.viewMode = EventDetailModeNotAcceptedEvent;
    }
    return self;
}
- (instancetype)initWithEventMode :(EventModel *)event andMode:(CurrentPastFeedTableViewMode)mode {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.viewEventMode = mode;
        self.event = event;
    }
    return self;
}
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
    if ([self.eventId integerValue]>0) {
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
        [self getEventDetail:self.eventId];
    }
    if (self.event.eventId > 0) {
        [self getEventDetail:self.event.eventId];
    }
}


#pragma mark - My Function
-(void)initializeView {
    [Utils setCornerRadiusofView:self.categoryBarView];
    
    self.unreadChatCountLbl.hidden = YES;
    self.badgeCountLbl.hidden = YES;
    
    self.unreadChatCountLbl.layer.cornerRadius = 12.5;
    self.unreadChatCountLbl.layer.borderWidth = 0.0;
    self.badgeCountLbl.layer.cornerRadius = 12.5;
    self.badgeCountLbl.layer.borderWidth = 0.0;
    
    self.eventMapView.hidden = NO;
    self.additionalInfoLabel.hidden = YES;
    [self.mapButton setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
    [self.infoButton setTitleColor:Rgb2UIColor(170, 170, 170) forState:UIControlStateNormal];
    self.labelXConstraint.constant = 0;
    [self.view layoutIfNeeded];
    
    if ([NRValidation isiPhone5])
    {
        self.contentViewHeight.constant=540;
        [self.view layoutIfNeeded];
    }
    else if ([NRValidation isiPhone6]) {
        self.contentViewHeight.constant=597;
        self.mapViewHeight.constant=615/3;
        self.infoViewHeight.constant=615/3;
        self.tapToGoTopSpace.constant=50;
        self.timeButtonTopSpace.constant=self.goingButtonTopSpace.constant=58;
        [self.view layoutIfNeeded];
    }
    else if([NRValidation isiPhone6Plus]){
        self.contentViewHeight.constant=666;
        self.mapViewHeight.constant=715/3;
        self.infoViewHeight.constant=715/3;
        self.tapToGoTopSpace.constant=60;
        self.timeButtonTopSpace.constant=self.goingButtonTopSpace.constant=68;
        [self.view layoutIfNeeded];
    }
  
    AppSharedClass.notificationCount = nil;
    TabBarViewController *tabBarController = (TabBarViewController *)appDelegate.window.rootViewController;
    [[tabBarController.tabBar.items objectAtIndex:4] setBadgeValue:nil];
    
    self.cantGoButton.layer.cornerRadius = 5.0;
    self.cantGoButton.layer.borderWidth = 1;
    
    
    for (id button in self.contentView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            ((UIButton *)button).exclusiveTouch = YES;
        }
        
    }
    
    if (self.event) {
         [self displayEventData:self.event];
    }
    else {
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
        [self getEventDetail:self.eventId];
    }
    self.eventResponseButton.enabled = !self.event.isDeleted;
    if (self.viewEventMode == CurrentPastFeedTableViewModePast) {
        self.chatButton.enabled = NO;
        self.eventResponseButton.enabled = NO;
        self.cantGoButton.enabled = NO;
    }
}

- (void)displayEventData :(EventModel *)event {
    
    if ([self.additionalInfoLabel.text length]>0)
    {
        self.eventMapView.hidden = YES;
        self.additionalInfoLabel.hidden = NO;
        [self.infoButton setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
        [self.mapButton setTitleColor:Rgb2UIColor(170, 170, 170) forState:UIControlStateNormal];
        self.labelXConstraint.constant = (self.mapButton.size.width + 40);
        [self.view layoutIfNeeded];
    }
    else
    {
        self.eventMapView.hidden = NO;
        self.additionalInfoLabel.hidden = YES;
        [self.mapButton setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
        [self.infoButton setTitleColor:Rgb2UIColor(170, 170, 170) forState:UIControlStateNormal];
        self.labelXConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }
    
    self.eventNameLabel.text = event.name;
    self.eventAddressLabel.text = [NSString stringWithFormat:@"%@\n%@", event.location.name, event.location.address];
    [self addAnnotationOnMap:event.location.coordinate title:event.name];
    
    self.creatorImageView.layer.cornerRadius = 22.5;
    self.creatorImageView.clipsToBounds = YES;
    [self.creatorImageView sd_setImageWithURL:[NSURL URLWithString:event.creator.image] placeholderImage:imgSync completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) {
            self.creatorImageView.image = [UIImage imageNamed:@"contactPlaceholder"];
        }
        self.creatorImageView.contentMode = UIViewContentModeScaleAspectFit;
        
    } animation:NaveenImageViewOptionsNone];
    
    self.creatorName.text = [NSString stringWithFormat:@"%@ %@",event.creator.firstName, event.creator.lastName];
    
    if (self.viewMode == EventDetailModeMyEvent)
    {
        self.chatButton.enabled = YES;
        
        [self.eventResponseButton setImage:[UIImage imageNamed:@"editButton"] forState:UIControlStateNormal];
        [self.eventResponseButton setImage:[UIImage imageNamed:@"editButton"] forState:UIControlStateSelected];
        self.joinLabel.text = @"Edit";
        self.cantGoButton.hidden = YES;
    }
    else if (self.viewMode == EventDetailModeNewEvent) {
        
    }
    else {
        if (self.event.eventRespose == EventResponseAccepted) {
            self.chatButton.enabled = YES;
            
            self.joinLabel.text = @"Going";
            self.eventResponseButton.selected = YES;
            self.cantGoButton.enabled = YES;
            self.cantGoButton.selected = NO;
            
            [self.cantGoButton setBackgroundColor:[UIColor clearColor]];
            self.cantGoButton.layer.borderColor = Rgb2UIColor(248, 80, 77).CGColor;
            [self.cantGoButton setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
            
            //self.cantGoButton.layer.borderColor = Rgb2UIColor(200, 200, 200).CGColor;
            //[self.cantGoButton setTitleColor:Rgb2UIColor(200, 200, 200) forState:UIControlStateNormal];
        }
        else if (self.event.eventRespose == EventResponseRejected) {
            self.chatButton.enabled = YES;//NO
            
            self.joinLabel.text = @"Tap to Go";
            self.eventResponseButton.selected = NO;
            self.cantGoButton.selected = YES;
            
            [self.cantGoButton setBackgroundColor:Rgb2UIColor(248, 80, 77)];
            self.cantGoButton.layer.borderColor = Rgb2UIColor(248, 80, 77).CGColor;
            [self.cantGoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //[self.cantGoButton setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
        }
        else if (self.event.eventRespose == EventResponseNoResponse) {
            self.chatButton.enabled = YES;//
            
            self.joinLabel.text = @"Tap to Go";
            [self.eventResponseButton setSelected:NO];
            self.cantGoButton.enabled = YES;
            self.cantGoButton.selected = NO;
            
            [self.cantGoButton setBackgroundColor:[UIColor clearColor]];
            self.cantGoButton.layer.borderColor = Rgb2UIColor(248, 80, 77).CGColor;
            [self.cantGoButton setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
            
            //self.cantGoButton.layer.borderColor = Rgb2UIColor(200, 200, 200).CGColor;
            //[self.cantGoButton setTitleColor:Rgb2UIColor(200, 200, 200) forState:UIControlStateNormal];
        }
        
        self.cantGoButton.hidden = NO;
        [self.eventResponseButton setImage:[UIImage imageNamed:@"join"] forState:UIControlStateNormal];
        [self.eventResponseButton setImage:[UIImage imageNamed:@"joinSelected"] forState:UIControlStateSelected];
    }
    [self setCountdownTime:event];
    
    //show badge count
    /********************/
    int totalBadgeCount = event.goingBadgeCount + event.cantGoingBadgeCount;
    int totalUnreadChatCount = event.groupUnreadMsgs + event.privateUnreadMsgs;
    if (totalUnreadChatCount>0) {
        self.unreadChatCountLbl.hidden = NO;
    }
    else{
        self.unreadChatCountLbl.hidden = YES;
    }
    self.unreadChatCountLbl.text = [NSString stringWithFormat:@"%i",totalUnreadChatCount];
    
    if (self.viewMode == EventDetailModeMyEvent)
    {
        if (totalBadgeCount>0) {
            self.badgeCountLbl.hidden = NO;
        }
        else{
            self.badgeCountLbl.hidden = YES;
        }
    }
    else{
        self.badgeCountLbl.hidden = YES;
    }
    
    self.badgeCountLbl.text = [NSString stringWithFormat:@"%i",totalBadgeCount];
    /********************/
    
    self.goingLabel.text = [NSString stringWithFormat:@"%@ going",event.goingCount];
    if ([event.goingCount intValue] == 1) {
       self.chatButton.enabled = YES;//NO
    }
    
    if (event.isDeleted) {
        self.additionalInfoLabel.text = event.cancelReason;
    }
    else {
        DLog(@"Addional Info11111======%@",event.additionalInfo);
        if ([self isBase64Data:event.additionalInfo]) {
            /********************Decode Data********************/
            NSData *nsdataFromBase64String = [[NSData alloc]
                                              initWithBase64EncodedString:event.additionalInfo options:0];
            
            
            // Decoded NSString from the NSData
            NSString *base64Decoded = [[NSString alloc]
                                       initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
            DLog(@"Decoded: %@", base64Decoded);
            self.additionalInfoLabel.text = [NSString stringWithFormat:@"%@",base64Decoded];
            /********************Decode Data********************/

        }
        else{
           self.additionalInfoLabel.text = event.additionalInfo;
        }
}

    self.eventResponseButton.enabled = !event.isDeleted;
    self.cantGoButton.enabled = !event.isDeleted;
    self.additionalInfoLabel.textColor = Rgb2UIColor(103, 103, 103);
    self.additionalInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    //FONT_ProximaNova_Light_WITH_SIZE(13.0);
    
    if (self.viewEventMode == CurrentPastFeedTableViewModePast) {
        self.chatButton.enabled = NO;
        self.eventResponseButton.enabled = NO;
        self.cantGoButton.enabled = NO;
    }
    
}

-(BOOL)isBase64Data:(NSString *)input
{
    if ([input length] % 4 == 0) {
        static NSCharacterSet *invertedBase64CharacterSet = nil;
        if (invertedBase64CharacterSet == nil) {
            invertedBase64CharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="]invertedSet];
        }
        return [input rangeOfCharacterFromSet:invertedBase64CharacterSet options:NSLiteralSearch].location == NSNotFound;
    }
    return NO;
}

- (void)setCountdownTime :(EventModel *)event {
    if (!event.isDeleted) {
        if ([event.startTime isEarlierThanDate:[NSDate date]]) {
            if ([event.endTime isLaterThanDate:[NSDate date]]) {
                self.timeLabel.text = @"Now";
            }
            else {
                self.timeLabel.text = [NSDate stringForDisplayFromDate:event.startTime];
            }
        }
        else {
            self.timeLabel.text = [NSString stringWithFormat:@"in %@",[NSDate stringForDisplayToDate:event.startTime]];
            
        }
    }
    else {
        self.timeLabel.text = @"Cancelled";
    }
}

- (void)setEventTime :(EventModel *)event {
    if([event.startTime isToday]) {
        self.timeLabel.text = [NSString stringWithFormat:@"Today %@",[event.startTime stringWithFormat:@"hh:mm a"]];
    }
    else if ([event.startTime isTomorrow]) {
        self.timeLabel.text = [NSString stringWithFormat:@"Tomorrow %@",[event.startTime stringWithFormat:@"hh:mm a"]];
    }
    else {
        self.timeLabel.text = [event.startTime string];
    }
}
- (void)addAnnotationOnMap : (CLLocationCoordinate2D)currentLocation title:(NSString *)title{
    
    CurrentPin *annotation = [[CurrentPin alloc] initWithTitle:title pinNumber:@"U" location:currentLocation];
    
    for (CurrentPin *pin in self.eventMapView.annotations) {
        if ([pin isKindOfClass:[CurrentPin class]]) {
            [self.eventMapView removeAnnotation:pin];
            break;
            
        }
    }
    [self.eventMapView showAnnotations:@[annotation] animated:YES];
}

-(void)googleMap
{
    NSString *url= [NSString stringWithFormat:@"comgooglemaps://?daddr=%@,%@&directionsmode=driving",[NSString stringWithFormat:@"%f",self.event.location.coordinate.latitude],[NSString stringWithFormat:@"%f",self.event.location.coordinate.longitude]];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

-(void)appleMap
{
    NSString* url = [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%f,%f&saddr=%f,%f",self.event.location.coordinate.latitude,self.event.location.coordinate.longitude,[kCurrentLatitude doubleValue],[kCurrentLongitude doubleValue]];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (void)getEventDetail:(NSNumber *)eventId {
    if (eventId) {
            [EventModel getEventDetailWithParams:@{kEventId:eventId} withCompletion:^(BOOL success, EventModel *event, NSError *error) {
                if (success && event) {
                    self.event = event;
                    [Utils createMainQueue:^{
                        
                        NSNumber *currentId = numberValue([UserDefaluts objectForKey:kCurrentUserID]);
                        
                        if ([self.event.creator.userId isEqualToNumber:currentId])
                        {
                            self.viewMode = EventDetailModeMyEvent;
                        }
                        else
                        {
                            if (event.eventRespose == EventResponseAccepted) {
                                self.viewMode = EventDetailModeAcceptedEvent;
                            }
                            else if (event.eventRespose == EventResponseNoResponse) {
                                self.viewMode = EventDetailModeNotAcceptedEvent;
                            }
                            else if (event.eventRespose == EventResponseRejected) {
                                self.viewMode = EventDetailModeRejected;
                            }
                            else {
                                self.viewMode = EventDetailModeNewEvent;
                            }
                        }
                        [self displayEventData:self.event];
                    }];
                }
            }];
      
    }
}

#pragma mark - IBAction

- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)cantGoClicked:(id)sender {
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    self.cantGoButton.selected=!self.cantGoButton.selected;
    if (self.event.eventId && self.cantGoButton.selected) {
        [EventModel sendEventResponseWithParams:@{kEventId:self.event.eventId, kDecide:[NSNumber numberWithInteger:EventResponseRejected]} withCompletion:^(BOOL success, EventModel *event, NSError *error) {
            
            [Utils createMainQueue:^{
                if (success) {
                    [self getEventDetail:self.event.eventId];
                }
            }];
        }];
    }else if(self.event.eventId && !self.cantGoButton.selected){
        [EventModel sendEventResponseWithParams:@{kEventId:self.event.eventId, kDecide:[NSNumber numberWithInteger:EventResponseNoResponse]} withCompletion:^(BOOL success, EventModel *event, NSError *error) {
            
            [Utils createMainQueue:^{
                if (success) {
                    [self getEventDetail:self.event.eventId];
                }
            }];
        }];

    }
}
- (void)editClicked {
    CreateEventViewController *createEventViewController = [[CreateEventViewController alloc]initWithEvent:self.event withViewMode:EventViewModeEdit];
    [self.navigationController pushViewController:createEventViewController animated:YES];
}
- (IBAction)reloadClicked:(id)sender {
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    [self getEventDetail:self.event.eventId];
}
- (IBAction)eventResponseClicked:(id)sender {
    
    if (self.viewMode == EventDetailModeMyEvent) {
        [self editClicked];
    }
    else {
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
        EventResponse eventResponse;
        if (self.event.eventRespose == EventResponseAccepted) {
           //dhirendra cahnge
            eventResponse = EventResponseNoResponse;//EventResponseNoResponse
        }
        else {
            eventResponse = EventResponseAccepted;
        }
        if (self.event.eventId) {
            [EventModel sendEventResponseWithParams:@{kEventId:self.event.eventId, kDecide:[NSNumber numberWithInteger:eventResponse]} withCompletion:^(BOOL success, EventModel *event, NSError *error) {
                
                NSNumber *currentUID = numberValue([UserDefaluts objectForKey:kCurrentUserID]);
                [[Mixpanel sharedInstance] track:@"UserJoined" properties:@{@"UserId" : currentUID}];
                [Utils createMainQueue:^{
                    if (success) {
                        [self getEventDetail:self.event.eventId];
                    }
                }];
            }];
        }
    }
}


- (IBAction)goingClicked:(id)sender {
    GoingViewMode goingViewMode;
    if (self.viewMode == EventDetailModeMyEvent) {
        goingViewMode = GoingViewModeCreator;
    }
    else {
        goingViewMode = GoingViewModeInvitee;
    }
    
    self.badgeCountLbl.text = [NSString stringWithFormat:@"%i",0];
    self.badgeCountLbl.hidden = YES;
    
    if (self.viewEventMode) {
        GoingViewController *goingViewController=[[GoingViewController alloc]initWithEventMode:self.event withMode:goingViewMode withPastCurrentMode:self.viewEventMode];
        
        if (self.event.goingBadgeCount>0) {
            goingViewController.openTabStr = kTabGoing;
        }else if (self.event.cantGoingBadgeCount>0) {
            goingViewController.openTabStr = kShowing;
        }
        else{
            goingViewController.openTabStr = kTabGoing;
        }
        
        goingViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:goingViewController animated:YES];
        
    }else
    {
        GoingViewController *goingViewController = [[GoingViewController alloc]initWithEvent:self.event withMode:goingViewMode];
        goingViewController.hidesBottomBarWhenPushed = YES;
        
        if (self.event.goingBadgeCount>0) {
            goingViewController.openTabStr = kTabGoing;
        }else if (self.event.cantGoingBadgeCount>0) {
            goingViewController.openTabStr = kShowing;
        }
        else{
            goingViewController.openTabStr = kTabGoing;
        }
        
        [self.navigationController pushViewController:goingViewController animated:YES];
    }
}

- (IBAction)navigationClicked:(id)sender {
    [[Mixpanel sharedInstance] track:@"NavigationUsed"];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Map" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Apple Maps",@"Google Maps",nil];
        popup.tag = 1;
        [popup showInView:[UIApplication sharedApplication].keyWindow];
    }else
    {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Map" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Apple Maps",nil];
        popup.tag = 1;
        [popup showInView:[UIApplication sharedApplication].keyWindow];
        
    }
}


- (IBAction)timeClicked:(id)sender {
    self.timeButton.selected = !self.timeButton.selected;
    if (self.timeButton.selected) {
        [self setEventTime:self.event];
    }
    else {
        [self setCountdownTime:self.event];
    }
}


#pragma mark- new method
//dhirendra cahnge
- (IBAction)mapFeedButtonClicked:(UIButton *)sender {
    self.eventMapView.hidden = NO;
    self.additionalInfoLabel.hidden = YES;
    [self.mapButton setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
    [self.infoButton setTitleColor:Rgb2UIColor(170, 170, 170) forState:UIControlStateNormal];
    [UIView animateWithDuration:0.3 animations:^{
        self.labelXConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
    

}

- (IBAction)infoFeedButtonClicked:(UIButton *)sender {
    self.eventMapView.hidden = YES;
    self.additionalInfoLabel.hidden = NO;
    [self.infoButton setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
    [self.mapButton setTitleColor:Rgb2UIColor(170, 170, 170) forState:UIControlStateNormal];
    [UIView animateWithDuration:0.3 animations:^{
        self.labelXConstraint.constant = (self.mapButton.size.width + 40);
        [self.view layoutIfNeeded];
    }];
}
- (IBAction)chatBtnClicked:(id)sender {
    self.unreadChatCountLbl.hidden = YES;
    if (self.event.chatInitiate == 0) {
        ChatViewController *chatViewController = [[ChatViewController alloc] initWithChat:self.event withViewMode:ChatModeGroup];
        chatViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatViewController animated:YES];
    }
    else{
        if (self.event.groupUnreadMsgs>0) {
            ChatViewController *chatViewController = [[ChatViewController alloc] initWithChat:self.event withViewMode:ChatModeGroup];
            chatViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:chatViewController animated:YES];
        }
        else if(self.event.privateUnreadMsgs>0)
        {
            ChatViewController *chatViewController = [[ChatViewController alloc] initWithChat:self.event withViewMode:ChatModeSingle];
            chatViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:chatViewController animated:YES];
        }
        else{
            NSString *chatType = [UserDefaluts objectForKey:kChatType];
            if ([chatType isEqualToString:kGroupChat]) {
                ChatViewController *chatViewController = [[ChatViewController alloc] initWithChat:self.event withViewMode:ChatModeGroup];
                chatViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:chatViewController animated:YES];
            }
            else if ([chatType isEqualToString:kPrivateChat])
            {
                ChatViewController *chatViewController = [[ChatViewController alloc] initWithChat:self.event withViewMode:ChatModeSingle];
                chatViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:chatViewController animated:YES];
            }
            else{
                ChatViewController *chatViewController = [[ChatViewController alloc] initWithChat:self.event withViewMode:ChatModeGroup];
                chatViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:chatViewController animated:YES];
            }
        }
    }
    
}

#pragma mark - Map View delegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[CurrentPin class]])
    {
        // Try to dequeue an existing pin view first.
        CurrentPin *placeLocation = (CurrentPin *)annotation;
        
        MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:[CurrentPin reuseIdentifier]];
        
        pinView = placeLocation.annotationView;
        
        pinView.canShowCallout = YES;
        UIImage *image = [UIImage imageNamed:MapPinImageName];
        pinView.centerOffset = CGPointMake(0, -image.size.height/ 2);
        pinView.image = image;
        
        return pinView;
    }
    
    return nil;
}

#pragma Mark-Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self appleMap];
                    break;
                case 1:
                    [self googleMap];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}


@end
