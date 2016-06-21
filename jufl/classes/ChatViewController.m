//
//  ChatViewController.m
//  jufl
//
//  Created by Dhirendra Kumar on 1/18/16.
//  Copyright © 2016 Ankur Arya. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatTableViewCell.h"
#import "IQKeyboardManager.h"
#import "PrivateChatListCell.h"
#import "ChatModel.h"
#import "PrivateChatListModel.h"
#define kMessageLimit 250
@interface ChatViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) EventModel *currEvent;
@property (nonatomic, assign) ChatViewMode chatViewMode;
@property (weak, nonatomic) IBOutlet UITableView *privateTableView;
@property (weak, nonatomic) IBOutlet UILabel *chatTypeTitleLbl;

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelXConstraint;
@property (weak, nonatomic) IBOutlet UIButton *privateButton;
@property (weak, nonatomic) IBOutlet UIButton *groupButton;
@property (nonatomic, strong) ChatModel *chatModel;

@property (weak, nonatomic) IBOutlet UIButton *btnMuteGroupChatNoti;
@property (assign) int groupNextPage;
@property (assign) int privateNextPage;
@property (nonatomic, strong) NSString *lastMsgId;
@property (nonatomic, strong) NSString *lastestMsgId;
@property (nonatomic, strong) NSMutableArray *chatGroupTableArray;
@property (nonatomic, strong) NSMutableArray *chatPrivateTableArray;
@property (nonatomic, strong) NSMutableArray *privateChatListTableArray;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;

@property (nonatomic, assign) int groupUnreadMsgs;
@property (nonatomic, assign) int privateUnreadMsgs;
@property (nonatomic, assign) int chatNotification;
@property (nonatomic, assign) int eventNotification;
@property (nonatomic, strong) NSNumber *senderUserId;
@property (nonatomic, strong) NSString *senderUserName;
@property (nonatomic, strong) NSNumber *currEventId;
@property (nonatomic, strong) NSString *currEventName;
@property (nonatomic, strong) UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UILabel *noChatListLabel;
@end
static NSString *chatCellIdentifier = @"ChatTableViewCell";
static NSString *privCellIdentifier = @"PrivateChatListCell";
@implementation ChatViewController
{
    BOOL _wasKeyboardManagerEnabled;//desable IQ keyboard manager
    BOOL isSigleChatOn;//to check chat private list
    BOOL _isTableFirstTimeLoad;//to refresh table on tab change
    float keboardHieght;//to check keyboard height
    BOOL isCotinueTimers;//to stop timers
}

#pragma mark - View life cycle
- (instancetype)initWithChat:(EventModel *)event withViewMode:(ChatViewMode)viewMode {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.chatViewMode = viewMode;
        if (event) {
            self.currEvent = event;
            self.currEventId = self.currEvent.eventId;
            self.currEventName = self.currEvent.name;
            
            //intialize for mute and unmute notification
            self.chatNotification = self.currEvent.chatNotification;
            self.eventNotification = self.currEvent.eventNotification;
            self.groupUnreadMsgs = self.currEvent.groupUnreadMsgs;
            self.privateUnreadMsgs = self.currEvent.privateUnreadMsgs;
        }
    }
    return self;
}

- (instancetype)initWithNtotiChatEventId:(NSNumber *)eventId eventName:(NSString *)eventname chatUserName:(NSString *)username  withViewMode:(ChatViewMode)viewMode {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.chatViewMode = viewMode;
        self.currEventId = eventId;
        self.currEventName = eventname;
        self.senderUserName = username;
        
        DLog(@"***INIT==****EVENT NAME *******%@ USER NAME******** %@",self.currEventName,self.senderUserName);
        
        //intialize for mute and unmute notification
        self.chatNotification = 1;
        self.eventNotification = 1;
        self.groupUnreadMsgs = 0;
        self.privateUnreadMsgs = 0;
    }
    return self;
}
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
     DLog(@"*******viewDidLoad********");
    [self performSelector:@selector(addChatFieldView) withObject:nil afterDelay:0.2];
    [self initializeView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _wasKeyboardManagerEnabled = [[IQKeyboardManager sharedManager] isEnabled];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    

    [super viewWillAppear:animated];
    DLog(@"*******viewWillAppear********");
    [self registerForKeyboardNotifications];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    isCotinueTimers = NO;
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[IQKeyboardManager sharedManager] setEnable:_wasKeyboardManagerEnabled];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    isCotinueTimers = NO;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - My Functions
- (void)eventWithNotifiChatEventId:(NSNumber *)eventId chatUserName:(NSString *)username eventName:(NSString *)eventname withViewMode:(ChatViewMode)viewMode
{
    self.chatViewMode = viewMode;
    self.currEventId = eventId;
    self.currEventName = eventname;
    self.senderUserName = username;
    
    DLog(@"*******EVENT NAME*******%@ USER NAME******** %@",self.currEventName,self.senderUserName);
    
    DLog(@"*******EVENT*******%@ EVENT ID******** %@",self.currEvent,self.currEvent.eventId);
    //intialize for mute and unmute notification
    self.chatNotification = 1;
    self.eventNotification = 1;
    self.groupUnreadMsgs = self.currEvent.groupUnreadMsgs;
    self.privateUnreadMsgs = self.currEvent.privateUnreadMsgs;
    
    self.chatTypeTitleLbl.hidden = NO;
        [self initializeView];
}




- (void)initializeView {
    //Add tapgesture on chat table
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    [self.chatTableView addGestureRecognizer:tap];
    
    DLog(@"group count=== %i private=== %i chat noti === %i  event noti==== %i",self.groupUnreadMsgs,self.privateUnreadMsgs,self.chatNotification,self.eventNotification);
    
    if (self.eventNotification) {
        [self.btnMuteGroupChatNoti setImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
    }
    else{
        [self.btnMuteGroupChatNoti setImage:[UIImage imageNamed:@"unmute"] forState:UIControlStateNormal];
    }
    
    if (self.chatNotification) {
        self.btnMuteGroupChatNoti.enabled = YES;
    }
    else{
        self.btnMuteGroupChatNoti.enabled = NO;
    }
    
    keboardHieght = 0.0;
    self.chatGroupTableArray = [[NSMutableArray alloc] init];
    self.chatPrivateTableArray = [[NSMutableArray alloc] init];
    
    self.chatTableView.estimatedRowHeight = 172.0; // for example. Set your average height
    self.chatTableView.rowHeight = UITableViewAutomaticDimension;

    
    //deafult choose message id
    _isTableFirstTimeLoad = YES;
    self.lastestMsgId = @"0";
    self.lastMsgId = @"0";
    
    if (self.chatViewMode == ChatModeGroup) {
         //intialize unread msg count
         self.groupUnreadMsgs = 0;
        
        //Intialize for group chat
        [self.groupButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
        [self.privateButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
        
        self.groupButton.selected = YES;
        self.privateButton.selected = NO;
        
        self.chatTableView.hidden = NO;
        self.privateTableView.hidden = YES;
        
        [self updateChatTypeTitle:@"Chatting with everyone in" secondStr:self.currEventName];
        [self getGroupChatFromServer:self.currEventId];
    }
    else{
        //Intialize for private chat
        if (self.privateUnreadMsgs>0) {
            [self privateClicked:nil];
        }
        else{
            [self.groupButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
            [self.privateButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
            
            self.groupButton.selected = NO;
            self.privateButton.selected = YES;
            
            self.chatTableView.hidden = NO;
            self.privateTableView.hidden = YES;
            self.btnMuteGroupChatNoti.hidden = YES;
            isSigleChatOn = YES;
            
            [UIView animateWithDuration:0.0 animations:^{
                self.labelXConstraint.constant = -(self.groupButton.size.width + 10);
                [self.view layoutIfNeeded];
            }];
            
            isCotinueTimers = YES;
            self.senderUserName = [UserDefaluts objectForKey:kLastSenderName];
            self.senderUserId = [UserDefaluts objectForKey:kLastSenderId];
            [self updateChatTypeTitle:@"Chatting with" secondStr:self.senderUserName];
            [self getPrivateChatFromServer:self.currEventId andSenderId:self.senderUserId];
        }
        
    }
   
   
    [self setUnreadMessageCount];
   
}

-(void)addChatFieldView
{
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
    if(rect.size.height == 40.0)
    {
      _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 60, [UIScreen mainScreen].bounds.size.width, 40)];
    }
    else{
      _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 40, [UIScreen mainScreen].bounds.size.width, 40)];
    }
    
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, ([UIScreen mainScreen].bounds.size.width-80), 40)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    textView.returnKeyType = UIReturnKeyGo; //just as an example
    //textView.font = [UIFont systemFontOfSize:15.0f];
    textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];// FONT_ProximaNova_Light_WITH_SIZE(16.0);
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.placeholder = @"Write comment";
    textView.returnKeyType = UIReturnKeyDefault;
    
    // textView.text = @"test\n\ntest";
    // textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:_containerView];
    
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField1.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, ([UIScreen mainScreen].bounds.size.width-72), 38);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground1.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, _containerView.frame.size.width, _containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
        [_containerView addSubview:imageView];
        [_containerView addSubview:textView];
        [_containerView addSubview:entryImageView];
    
   // UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
   // UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
    self.doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneBtn.frame = CGRectMake(_containerView.frame.size.width - 69, 8, 63, 27);
    self.doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.doneBtn setTitle:@"Send" forState:UIControlStateNormal];
    
    //[doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    //doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    //doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.doneBtn.titleLabel.font = FONT_ProximaNova_Regular_WITH_SIZE(16.0);
    
    //[doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.doneBtn setTitleColor:Rgb2UIColor(170, 170, 170) forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(sendChatMessage) forControlEvents:UIControlEventTouchUpInside];
    //[doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    //[doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
    [_containerView addSubview:self.doneBtn];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
}

-(void)updateChatTypeTitle:(NSString *)firstStr secondStr:(NSString *)secondStr
{
    NSRange range = NSMakeRange([firstStr length], [secondStr length]+1);
    self.chatTypeTitleLbl.text = [NSString stringWithFormat:@"%@ %@",firstStr,secondStr];
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:self.chatTypeTitleLbl.text];
    [attText addAttribute:NSForegroundColorAttributeName
                    value:Rgb2UIColor(248, 80, 77)
                    range:range];
    [attText addAttribute:NSFontAttributeName
                    value:FONT_ProximaNova_Bold_WITH_SIZE(13.0)
                    range:range];
    
    self.chatTypeTitleLbl.attributedText = attText;
}

-(void)sendChatMessage
{
    
    NSString *trimmedString = [textView.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
     DLog(@"trimmedString===== %@",trimmedString);
    
    if(!(trimmedString.length>0))
    {
        [TSMessage showNotificationWithTitle:@"Please write comment!" type:TSMessageNotificationTypeMessage];
    }
    else
    {
        /********************Encode Data to base64********************/
        NSData *nsdata = [trimmedString
                          dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
        /********************Encode Data to base64********************/
        
        if (self.chatViewMode == ChatModeGroup)
        {
            NSMutableDictionary *postGroupMgsDict = [[NSMutableDictionary alloc]init];
            [postGroupMgsDict setObject:self.currEventId forKey:kEventId];
            [postGroupMgsDict setObject: [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]] forKey:kDateTime];
            [postGroupMgsDict setObject:base64Encoded forKey:kChatMessage];
            
            //[Utils startActivityIndicatorWithMessage:kPleaseWait];
            [self postGroupChatToServer:postGroupMgsDict];
            
        }
        else{
            NSMutableDictionary *postPrivateMgsDict = [[NSMutableDictionary alloc]init];
            [postPrivateMgsDict setObject:self.currEventId forKey:kEventId];
            [postPrivateMgsDict setObject:self.senderUserId forKey:kReceiptId];
            [postPrivateMgsDict setObject: [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]] forKey:kDateTime];
            [postPrivateMgsDict setObject:base64Encoded forKey:kChatMessage];
            
            //[Utils startActivityIndicatorWithMessage:kPleaseWait];
            [self postPrivateChatToServer:postPrivateMgsDict];
        }

    }
}
-(void)resignTextView
{
    [textView resignFirstResponder];
}
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    //set table content Inset
    self.chatTableView.contentInset =  UIEdgeInsetsMake(0, 0, keyboardBounds.size.height, 0);
    keboardHieght = keyboardBounds.size.height;
    // get a rect for the textView frame
    CGRect containerFrame = _containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    _containerView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    keboardHieght = 0.0;
    self.chatTableView.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0);
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = _containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    _containerView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}



- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = _containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    _containerView.frame = r;
}

-(void)privateChatToSelectedMember
{
    self.privateUnreadMsgs = 0;
    [self setUnreadMessageCount];
    
    self.chatTypeTitleLbl.hidden = NO;
    self.chatTableView.hidden = NO;
    self.privateTableView.hidden = YES;
    self.containerView.hidden = NO;
    
    
    _isTableFirstTimeLoad = YES;
    
    self.lastMsgId = @"0";
    self.lastestMsgId = @"0";
    
    //refesh table on tab change
    if(self.chatPrivateTableArray.count>0){
        [self.chatPrivateTableArray removeAllObjects];
    }
    [self.chatTableView reloadData];
    [self getPrivateChatFromServer:self.currEventId andSenderId:self.senderUserId];
    
}
//For load earlier chat
-(void)loadEarlierMessage
{
    _isTableFirstTimeLoad = NO;
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    if (self.chatViewMode == ChatModeGroup){
        [self getGroupChatFromServer:self.currEventId];
    }
    else{
         [self getPrivateChatFromServer:self.currEventId andSenderId:self.senderUserId];
    }
}
//For set unread message count
-(void)setUnreadMessageCount
{
    if (self.privateUnreadMsgs>0) {
        self.privateButton.titleLabel.font = FONT_ProximaNova_Bold_WITH_SIZE(15.0);
        [self.privateButton setTitle:[NSString stringWithFormat:@"Private(%i)",self.privateUnreadMsgs] forState:UIControlStateNormal];
    }
    else{
        self.privateButton.titleLabel.font = FONT_ProximaNova_Light_WITH_SIZE(15.0);
        [self.privateButton setTitle:@"Private" forState:UIControlStateNormal];
    }
    
    if (self.groupUnreadMsgs>0) {
        self.groupButton.titleLabel.font = FONT_ProximaNova_Bold_WITH_SIZE(15.0);
        [self.groupButton setTitle:[NSString stringWithFormat:@"Group(%i)",self.groupUnreadMsgs] forState:UIControlStateNormal];
    }
    else{
        self.groupButton.titleLabel.font = FONT_ProximaNova_Light_WITH_SIZE(15.0);
        [self.groupButton setTitle:@"Group" forState:UIControlStateNormal];
    }
    
    if (self.chatViewMode == ChatModeGroup){
        [self.groupButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
        [self.privateButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
    }
    else{
        [self.groupButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
        [self.privateButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
    }
}

//For refresh chat
-(void)timerCallToRefreshGroupChat
{
    isCotinueTimers = YES;
    DLog(@"******timer Call To Refresh Group Chat******");
    [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(getLatestGroupChatFromServer) userInfo:nil repeats:NO];
}


-(void)timerCallToRefreshPrivateChat
{
    isCotinueTimers = YES;
    DLog(@"******timer Call To Refresh Private Chat******");
    [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(getLatestPrivateChatFromServer) userInfo:nil repeats:NO];
}



#pragma mark - IBActions

- (IBAction)backClicked:(id)sender {
    if (isSigleChatOn) {
        [self.noDataLabel setHidden:YES];
        [self resignTextView];
        self.containerView.hidden = YES;
        self.chatTypeTitleLbl.hidden = YES;
        isSigleChatOn = NO;
        self.chatTableView.hidden = YES;
        self.privateTableView.hidden = NO;
        self.lastestMsgId = @"0";
       
        [self.privateTableView reloadData];
        
        if (self.privateChatListTableArray.count==0) {
            [Utils startActivityIndicatorWithMessage:kPleaseWait];
        }
        [self getPrivateChatListFromServer];
    }
    else{
        if (self.chatViewMode == ChatModeGroup) {
            [UserDefaluts setObject:kGroupChat forKey:kChatType];
        }
        else{
            [UserDefaluts setObject:kPrivateChat forKey:kChatType];
        }
            [UserDefaluts setObject:self.senderUserId forKey:kLastSenderId];
            [UserDefaluts setObject:self.senderUserName forKey:kLastSenderName];
        
     [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)muteGroupChatNotiBtnClicked:(id)sender
{
    [self resignTextView];
    if (self.eventNotification)
    {
    [[Utils sharedInstance] openActionSheetWithTitle:kImageTitle buttons:@[kMuteGroupConversation]
                                              completion:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                                  switch (buttonIndex)
                                                  {
                                                      case 0:
                                                          [self muteGroupNotification];
                                                          break;
                                                          
                                                      default:
                                                          break;
                                                  }
                                              }];
    }
    else{
    [[Utils sharedInstance] openActionSheetWithTitle:kImageTitle buttons:@[kUnMuteGroupConversation]
                                          completion:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                              switch (buttonIndex)
                                              {
                                                  case 0:
                                                      [self unmuteGroupNotification];
                                                      break;
                                                      
                                                    default:
                                                      break;
                                              }
                                          }];
    }
}
-(void)muteGroupNotification
{
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    [self postEventNotificationStatusToServer:@"0"];
}
-(void)unmuteGroupNotification
{
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    [self postEventNotificationStatusToServer:@"1"];
}
- (IBAction)groupClicked:(UIButton *)sender {
    [self.noChatListLabel setHidden:YES];
    if(!self.groupButton.selected)
    {
        [self resignTextView];
        self.groupUnreadMsgs = 0;
        [self setUnreadMessageCount];
        
        self.btnMuteGroupChatNoti.hidden = NO;
        [self updateChatTypeTitle:@"Chatting with everyone in" secondStr:self.currEventName];
        self.chatViewMode = ChatModeGroup;
        self.groupButton.selected = YES;
        self.privateButton.selected = NO;
        self.chatTableView.hidden = NO;
        self.privateTableView.hidden = YES;
        self.containerView.hidden = NO;
        self.chatTypeTitleLbl.hidden = NO;
        
        //check for private chat list
        isSigleChatOn = NO;
        
        [self.groupButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
        [self.privateButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.labelXConstraint.constant = 0;
            [self.view layoutIfNeeded];
        }];
        
        _isTableFirstTimeLoad = YES;
        
        
        //refresh table on tab change
        if(self.chatGroupTableArray.count>0){
            [self.noDataLabel setHidden:YES];
            ChatModel *firstChatObj = [self.chatGroupTableArray firstObject];
            ChatModel *lastChatObj = [self.chatGroupTableArray lastObject];
            self.lastMsgId = [NSString stringWithFormat:@"%@",firstChatObj.messageId];
            self.lastestMsgId = [NSString stringWithFormat:@"%@",lastChatObj.messageId];
//            self.lastMsgId = firstChatObj.messageId;
//            self.lastestMsgId = lastChatObj.messageId;
            
            [self.chatTableView reloadData];
            //start auto refresh group chat
            [self performSelector:@selector(getLatestGroupChatFromServer) withObject:nil afterDelay:0.0];
            
        }
        else{
            self.lastMsgId = @"0";
            self.lastestMsgId = @"0";
            [self getGroupChatFromServer:self.currEventId];
        }
       
      
    }
}
- (IBAction)privateClicked:(UIButton *)sender {
    [self.noDataLabel setHidden:YES];
    if (!self.privateButton.selected)
    {
        [self resignTextView];
        [self setUnreadMessageCount];
        
        self.btnMuteGroupChatNoti.hidden = YES;
        self.chatViewMode = ChatModeSingle;
        if (isSigleChatOn) {
            self.chatTypeTitleLbl.hidden = NO;
        }
        else{
            self.groupButton.selected = NO;
            self.privateButton.selected = YES;
            self.chatTableView.hidden = YES;
            self.privateTableView.hidden = NO;
            self.containerView.hidden = YES;
            self.chatTypeTitleLbl.hidden = YES;
        }
        
        [self.groupButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
        [self.privateButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.labelXConstraint.constant = -(self.groupButton.size.width + 10);
            [self.view layoutIfNeeded];
        }];
        
        self.lastMsgId = @"0";
        self.lastestMsgId = @"0";
       
        [self.privateTableView reloadData];
        
        if (self.privateChatListTableArray.count==0) {
            [Utils startActivityIndicatorWithMessage:kPleaseWait];
        }
        [self getPrivateChatListFromServer];
    }
}

#pragma mark - Table Data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.chatTableView.hidden == NO){
       if (self.chatViewMode == ChatModeGroup){
           if (self.chatGroupTableArray.count>0) {
               if (self.groupNextPage>0) {
                   return self.chatGroupTableArray.count+1;
               }
               else
                   return self.chatGroupTableArray.count;
           }
           else{
               return 0;
           }
       }
       else{
           if (self.chatPrivateTableArray.count>0) {
               if (self.privateNextPage>0) {
                   return self.chatPrivateTableArray.count+1;
               }
               else
                   return self.chatPrivateTableArray.count;
           }
           else{
               return 0;
           }
       }
    
    }
    else
    {
        if (self.privateChatListTableArray.count>0)
            return self.privateChatListTableArray.count;
        else
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.chatTableView.hidden == NO) {
        int nextPage = 0;
        if (self.chatViewMode == ChatModeGroup){
            nextPage = self.groupNextPage;
        }
        else{
            nextPage = self.privateNextPage;
        }
        
        if (nextPage>0) {
            if (indexPath.row==0) {
                return 40;
            }
            else{
                 return UITableViewAutomaticDimension;
            }
            
        }
        else{
            return UITableViewAutomaticDimension;
        }
    }
    else{
        return 60.0;
    }
 
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int nextPage = 0;
    if (self.chatViewMode == ChatModeGroup){
        nextPage = self.groupNextPage;
    }
    else{
        nextPage = self.privateNextPage;
    }
    if (self.chatTableView.hidden == NO) {
        //Chat cell
            ChatTableViewCell *cell = nil;
            cell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:chatCellIdentifier];
            if( !cell )
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
               
            }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.loadMsgButton addTarget:self action:@selector(loadEarlierMessage) forControlEvents:UIControlEventTouchUpInside];
        if (nextPage>0)
        {
            if (indexPath.row==0)
            {
                cell.loadMsgButton.hidden = NO;
                cell.userImgView.hidden = YES;
                cell.userNameLbl.hidden = YES;
                cell.messageLbl.hidden = YES;
                cell.dateTimeLbl.hidden = YES;
            }
            else{
                cell.loadMsgButton.hidden = YES;
                cell.userImgView.hidden = NO;
                cell.userNameLbl.hidden = NO;
                cell.messageLbl.hidden = NO;
                cell.dateTimeLbl.hidden = NO;
                if (self.chatViewMode == ChatModeGroup){
                    if (indexPath.row-1 < self.chatGroupTableArray.count) {
                        ChatModel *chatObj = self.chatGroupTableArray[indexPath.row-1];
                        [cell setChatCellData:chatObj];
                    }
                }
                else{
                    if (indexPath.row-1 < self.chatPrivateTableArray.count) {
                        ChatModel *chatObj = self.chatPrivateTableArray[indexPath.row-1];
                        [cell setChatCellData:chatObj];
                    }
                }
                
            }
        }
        else{
            cell.loadMsgButton.hidden = YES;
            cell.userImgView.hidden = NO;
            cell.userNameLbl.hidden = NO;
            cell.messageLbl.hidden = NO;
            cell.dateTimeLbl.hidden = NO;
            if (self.chatViewMode == ChatModeGroup){
                if (indexPath.row < self.chatGroupTableArray.count) {
                    ChatModel *chatObj = self.chatGroupTableArray[indexPath.row];
                    [cell setChatCellData:chatObj];
                }
            }
            else{
                if (indexPath.row < self.chatPrivateTableArray.count) {
                    ChatModel *chatObj = self.chatPrivateTableArray[indexPath.row];
                    [cell setChatCellData:chatObj];
                }
            }
        
        }
        
            return cell;
    }
    else{
        //Private chat list cell
        PrivateChatListCell *cell = nil;
        cell = (PrivateChatListCell *)[tableView dequeueReusableCellWithIdentifier:privCellIdentifier];
        if( !cell )
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PrivateChatListCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row < self.privateChatListTableArray.count) {
            PrivateChatListModel *chatmember = self.privateChatListTableArray[indexPath.row];
            [cell setPrivateChatListCellData:chatmember];
        }
        
        return cell;
    }

}

#pragma mark - Table Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.privateTableView.hidden == NO) {
        isSigleChatOn = YES;
        if (self.privateChatListTableArray.count>0) {
            if (indexPath.row < self.privateChatListTableArray.count) {
                PrivateChatListModel *updateMemberListObj = self.privateChatListTableArray[indexPath.row];
                updateMemberListObj.unreadMsgCount = [NSNumber numberWithInt:0];
                [self.privateChatListTableArray replaceObjectAtIndex:indexPath.row withObject:updateMemberListObj];
                
                PrivateChatListModel* chooseMemberToChat = self.privateChatListTableArray[indexPath.row];
                self.senderUserId = chooseMemberToChat.toUserId;
                self.senderUserName = [NSString stringWithFormat:@"%@ %@",chooseMemberToChat.fisrtName,chooseMemberToChat.lastName];
                [self updateChatTypeTitle:@"Chatting with" secondStr:self.senderUserName];
                [self privateChatToSelectedMember];
            }
        }
        
    }
    
}



#pragma mark - Text View Delegate
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
     DLog(@"text----%@    growing Text---- %@",text,growingTextView.text);
    NSString *trimmedString = [text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString.length>0)
    {
        [self.doneBtn setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
    }
    else if (growingTextView.text.length>1)
    {
        [self.doneBtn setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
    }
    else{
        [self.doneBtn setTitleColor:Rgb2UIColor(170, 170, 170) forState:UIControlStateNormal];
    }
   
    if (growingTextView.text.length==0 && [text isEqualToString:@"\n"])
    {
        return NO;
    }
    else
    {
        BOOL isReturn=[self checkLimitOfTextView:text andTextView:growingTextView andLimit:kMessageLimit andRange:range];
        if(isReturn)
            return YES;
        else
            return NO;
    }
}


-(BOOL)checkLimitOfTextView:(NSString *)string andTextView:(HPGrowingTextView *)growingTextView andLimit:(int)_limit andRange:(NSRange )range
{
    NSString *stringAppended=[NSString stringWithFormat:@"%@%@",growingTextView.text,string];
    int limit = _limit;
    
    if((growingTextView.text.length+string.length)>limit &&[string length] > range.length)
    {
        stringAppended=[stringAppended substringToIndex:limit];
        textView.text=stringAppended;
        [self resignTextView];
        
        NSString *msg=[NSString stringWithFormat:@"You can add maximum %d characters.",limit];
        [TSMessage showNotificationInViewController:self title:@"Maximum limit reached." subtitle:msg type:TSMessageNotificationTypeMessage];
        
        return NO;
    }
    else
        return YES;
    
}

#pragma mark - Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch ;
    touch = [[event allTouches] anyObject];
    if ([touch view] == _containerView)
    {
        //Do what ever you want
    }
    else{
        [self resignTextView];
    }
}
-(void)tap
{
    [self resignTextView];
}

#pragma mark - APIs call

#pragma mark Get Chat List
-(void)getPrivateChatListFromServer
{
    DLog(@"****** Refresh Chat List******");
    
    [PrivateChatListModel getChatListData:@{kEventId:self.currEventId} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        [Utils createMainQueue:^{
            if (success) {
                self.privateChatListTableArray = [[NSMutableArray alloc]init];
                NSArray *arrResult = [response objectForKey:kParticipantList];
                for (NSDictionary *dict in arrResult) {
                    PrivateChatListModel *chatList  = [[PrivateChatListModel alloc]initWithChatListDictionary:dict];
                    chatList.imagePath = [response objectForKey:kChatImagePath];
                    [self.privateChatListTableArray addObject:chatList];
                }
                if (self.privateChatListTableArray.count) {
                    //update unread message count
                    self.groupUnreadMsgs = [[[[arrResult firstObject] objectForKey:kBadgeCount] objectForKey:kGroupUnreadMsgCount] intValue];
                    self.privateUnreadMsgs = [[[[arrResult firstObject] objectForKey:kBadgeCount] objectForKey:kPrivateUnreadMsgCount] intValue];
                    [self setUnreadMessageCount];

                }
               [self.privateTableView reloadData];
                
                if (self.privateChatListTableArray.count) {
                    [self.noChatListLabel setHidden:YES];
                }
                else {
                    if (self.chatViewMode == ChatModeSingle)
                    {
                       [self.noChatListLabel setHidden:NO];
                    }
                    else{
                        [self.noChatListLabel setHidden:YES];
                    }
                }

               
            }
            
        }];
    }];
    
    if (isCotinueTimers) {
        if (self.chatViewMode == ChatModeSingle) {
            if (isSigleChatOn == NO) {
                [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(getPrivateChatListFromServer) userInfo:nil repeats:NO];
            }
        }
    }

}

#pragma mark Get Chat

- (void)getGroupChatFromServer:(NSNumber *)eventId  {
    if (self.chatGroupTableArray.count==0) {
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
    }
       [ChatModel getGroupChatData:@{kLastMsgId : self.lastMsgId,kEventId:eventId} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        [Utils createMainQueue:^{
            if (success) {
                
                if([response objectNonNullForKey:kPageNumber])
                    self.groupNextPage = [[response objectForKey:kPageNumber] intValue];
                NSLog(@"Group page===== %i key page======= %@",self.groupNextPage,[response objectForKey:kPageNumber]);
                if ([response objectForKey:kChatInfo]) {
                    NSArray *arrResult = [response objectForKey:kChatInfo];
                    for (NSDictionary *dict in arrResult) {
                        ChatModel *chatObj  = [[ChatModel alloc]initWithChatDictionary:dict];
                        [self.chatGroupTableArray insertObject:chatObj atIndex:0];
                    }
                }
                
                if (self.chatGroupTableArray.count>0) {
                    ChatModel *firstChatObj = [self.chatGroupTableArray firstObject];
                    ChatModel *lastChatObj = [self.chatGroupTableArray lastObject];
                    self.lastMsgId = [NSString stringWithFormat:@"%@",firstChatObj.messageId];
                    self.lastestMsgId = [NSString stringWithFormat:@"%@",lastChatObj.messageId];
                }
                
                [self.chatTableView reloadData];
                
                if (self.chatGroupTableArray.count) {
                    [self.noDataLabel setHidden:YES];
                }
                else {
                    [self.noDataLabel setHidden:NO];
                }
                if(_isTableFirstTimeLoad)
                {
                    if (self.chatTableView .contentSize.height > self.chatTableView .frame.size.height)
                    {
                    if(self.chatGroupTableArray.count>0){
                       //[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatGroupTableArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        
                        //[self.chatTableView reloadData];
                        NSInteger inPath = [self.chatTableView numberOfRowsInSection:0] - 1 ;
                        
                        NSIndexPath* ip = [NSIndexPath indexPathForRow:inPath inSection:0];
                        [self.chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    }
                    
                    }
            
                }
                else{
                    if (self.chatTableView .contentSize.height > self.chatTableView .frame.size.height)
                    {
                        if(self.chatGroupTableArray.count>10){
                        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        }
                        
                    }
                }
                //start auto refresh group chat
                [self performSelector:@selector(timerCallToRefreshGroupChat) withObject:nil afterDelay:0.0];
            }
                
            }];
    }];
}



- (void)getPrivateChatFromServer:(NSNumber *)eventId andSenderId:(NSNumber *)senderId
{
    if (self.chatPrivateTableArray.count==0) {
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
    }
    [ChatModel getPrivateChatData:@{kLastMsgId : self.lastMsgId,kEventId:eventId, kSenderId:senderId} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        [Utils createMainQueue:^{
            if (success) {
                
                if([response objectNonNullForKey:kPageNumber])
                    self.privateNextPage = [[response objectForKey:kPageNumber] intValue];
                DLog(@"Private Page===== %i key page======= %@",self.privateNextPage,[response objectForKey:kPageNumber]);
                if ([response objectForKey:kChatInfo]) {
                    NSArray *arrResult = [response objectForKey:kChatInfo];
                    for (NSDictionary *dict in arrResult) {
                        ChatModel *chatObj  = [[ChatModel alloc]initWithChatDictionary:dict];
                        [self.chatPrivateTableArray insertObject:chatObj atIndex:0];
                    }
                }
               
                
                if (self.chatPrivateTableArray.count>0) {
                    ChatModel *firstChatObj = [self.chatPrivateTableArray firstObject];
                    ChatModel *lastChatObj = [self.chatPrivateTableArray lastObject];
                    self.lastMsgId = [NSString stringWithFormat:@"%@",firstChatObj.messageId];
                    self.lastestMsgId = [NSString stringWithFormat:@"%@",lastChatObj.messageId];

                }
                [self.chatTableView reloadData];
                
                if (self.chatPrivateTableArray.count) {
                    [self.noDataLabel setHidden:YES];
                }
                else {
                    [self.noDataLabel setHidden:NO];
                }
                
                if(_isTableFirstTimeLoad)
                {
                    if (self.chatTableView .contentSize.height > self.chatTableView .frame.size.height)
                    {
                    if(self.chatPrivateTableArray.count>0){
                        //[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatPrivateTableArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        NSInteger inPath = [self.chatTableView numberOfRowsInSection:0] - 1 ;
                        NSIndexPath* ip = [NSIndexPath indexPathForRow:inPath inSection:0];
                        [self.chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];

                         }
                    }
                }
                else{
                    if (self.chatTableView .contentSize.height > self.chatTableView .frame.size.height)
                    {
                        if(self.chatPrivateTableArray.count>10){
                        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        }
                        
                    }
                }
                //start auto refresh private chat
                [self performSelector:@selector(timerCallToRefreshPrivateChat) withObject:nil afterDelay:0.0];
            }
            
        }];
    }];
}

#pragma mark Get Latest Chat
- (void)getLatestGroupChatFromServer {
     DLog(@"****** Refresh Group's Chat ******");
       [ChatModel getLatestGroupChatData:@{kLatestMsgId : self.lastestMsgId,kEventId:self.currEventId} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils createMainQueue:^{
            if (success) {
                if (self.chatViewMode == ChatModeGroup) {
                    if ([response objectForKey:kChatInfo]) {
                        NSArray *arrResult = [response objectForKey:kChatInfo];
                        
                        //update unread message count
                        self.groupUnreadMsgs = [[[response objectForKey:kBadgeCount] objectForKey:kGroupUnreadMsgCount] intValue];
                        self.privateUnreadMsgs = [[[response objectForKey:kBadgeCount] objectForKey:kPrivateUnreadMsgCount] intValue];
                        [self setUnreadMessageCount];
                        
                        for (NSDictionary *dict in arrResult) {
                            ChatModel *chatObj  = [[ChatModel alloc]initWithChatDictionary:dict];
                            if (![self.chatGroupTableArray containsObject:chatObj]) {
                                if (![[NSString stringWithFormat:@"%@",chatObj.messageId] isEqualToString:self.lastestMsgId]) {
                                    [self.chatGroupTableArray addObject:chatObj];
                                }
                            }
                        }
                    }
                    
                    NSArray *arrResult = [response objectForKey:kChatInfo];
                    //for sort arry using msg id
                    if (arrResult.count>0) {
                        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:YES];
                        NSArray * sortArr = [self.chatGroupTableArray sortedArrayUsingDescriptors:@[sort]];
                        self.chatGroupTableArray = [NSMutableArray arrayWithArray:sortArr];
                    }
                    DLog(@"Refresh Group Arr===== %@",self.chatPrivateTableArray);
                    
                    if (self.chatGroupTableArray.count>0) {
                        ChatModel *firstChatObj = [self.chatGroupTableArray firstObject];
                        ChatModel *lastChatObj = [self.chatGroupTableArray lastObject];
                        self.lastMsgId = [NSString stringWithFormat:@"%@",firstChatObj.messageId];
                        self.lastestMsgId = [NSString stringWithFormat:@"%@",lastChatObj.messageId];

                    }
                                        
                    if (arrResult.count>0) {
                         [self.chatTableView reloadData];
                        if (self.chatTableView .contentSize.height > self.chatTableView .frame.size.height)
                        {
                            if(self.chatGroupTableArray.count>0){
                            //[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatGroupTableArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                                
                                NSInteger inPath = [self.chatTableView numberOfRowsInSection:0] - 1 ;
                                NSIndexPath* ip = [NSIndexPath indexPathForRow:inPath inSection:0];
                                [self.chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];

                            }
                        }
                       
                    }
                    
                }
                else{
                //do nothing
                }
              
         
            }
            
        }];
    }];
    
    if (isCotinueTimers) {
        if (self.chatViewMode == ChatModeGroup) {
         [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(getLatestGroupChatFromServer) userInfo:nil repeats:NO];
        }
    }
   
}

- (void)getLatestPrivateChatFromServer {
  DLog(@"****** Refresh Private's Chat ******");
    [ChatModel getLatestPrivateChatData:@{kLatestMsgId : self.lastestMsgId,kEventId:self.currEventId, kSenderId:self.senderUserId} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils createMainQueue:^{
            if (success) {
                if (self.chatViewMode == ChatModeSingle) {
                    if ([response objectForKey:kChatInfo]) {
                        
                        NSArray *arrResult = [response objectForKey:kChatInfo];
                        //update unread message count
                        self.groupUnreadMsgs = [[[response objectForKey:kBadgeCount] objectForKey:kGroupUnreadMsgCount] intValue];
                        self.privateUnreadMsgs = [[[response objectForKey:kBadgeCount] objectForKey:kPrivateUnreadMsgCount] intValue];
                        [self setUnreadMessageCount];
                        
                        for (NSDictionary *dict in arrResult) {
                            ChatModel *chatObj  = [[ChatModel alloc]initWithChatDictionary:dict];
                            if (![self.chatPrivateTableArray containsObject:chatObj]) {
                                NSString *templatestMsgId = [NSString stringWithFormat:@"%@",chatObj.messageId];
                                if (![templatestMsgId isEqualToString:self.lastestMsgId]) {
                                    [self.chatPrivateTableArray addObject:chatObj];
                                }
                            }
                        }
                    }
                  
                    NSArray *arrResult = [response objectForKey:kChatInfo];
                    //for sort arry using msg id
                    [Utils createMainQueue:^{
                        if (arrResult.count>0) {
                            
                            NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:YES];
                            NSArray * sortArr = [self.chatPrivateTableArray sortedArrayUsingDescriptors:@[sort]];
                            self.chatPrivateTableArray = [NSMutableArray arrayWithArray:sortArr];
                        }
                    }];
                   
                    
                    if (self.chatPrivateTableArray.count>0) {
                        ChatModel *firstChatObj = [self.chatPrivateTableArray firstObject];
                        ChatModel *lastChatObj = [self.chatPrivateTableArray lastObject];
                        self.lastMsgId = [NSString stringWithFormat:@"%@",firstChatObj.messageId];//firstChatObj.messageId;
                        self.lastestMsgId = [NSString stringWithFormat:@"%@",lastChatObj.messageId];//lastChatObj.messageId;
                    }
                    
                    if (arrResult.count>0) {
                        [self.chatTableView reloadData];
                        if (self.chatTableView .contentSize.height > self.chatTableView .frame.size.height)
                        {
                            if(self.chatPrivateTableArray.count>0){
                               // [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatPrivateTableArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                                NSInteger inPath = [self.chatTableView numberOfRowsInSection:0] - 1 ;
                                
                                NSIndexPath* ip = [NSIndexPath indexPathForRow:inPath inSection:0];
                                [self.chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];

                            }
                        }
                    }
                    
                }
                else{
                //do nothing
                }
            }
            
        }];
    }];
    
    if (isCotinueTimers) {
    if (self.chatViewMode == ChatModeSingle) {
        if (isSigleChatOn) {
            [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(getLatestPrivateChatFromServer) userInfo:nil repeats:NO];
        }
    }
 }
}


#pragma mark Post Chat
-(void)postGroupChatToServer:(NSDictionary*)dict
{
    textView.text = @"";
    [ChatModel postGroupChatData:dict withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        [Utils createMainQueue:^{
            if (success) {
                textView.text = @"";
                [self.doneBtn setTitleColor:Rgb2UIColor(170, 170, 170) forState:UIControlStateNormal];
                
                NSDictionary *dict = [[response objectForKey:kChatInfo] lastObject];
                
                //update unread message count
                self.groupUnreadMsgs = [[dict objectForKey:kGroupUnreadMsgCount] intValue];
                self.privateUnreadMsgs = [[dict objectForKey:kPrivateUnreadMsgCount] intValue];
                [self setUnreadMessageCount];
                
                ChatModel *chatObj  = [[ChatModel alloc]initWithChatDictionary:dict];
                
                //[self.chatGroupTableArray addObject:chatObj];
                
                //////
                    if (![self.chatGroupTableArray containsObject:chatObj]) {
                        if (![[NSString stringWithFormat:@"%@",chatObj.messageId] isEqualToString:self.lastestMsgId]) {
                            [self.chatGroupTableArray addObject:chatObj];
                        }
                    }
                /////

                
                if (self.chatGroupTableArray.count>0) {
                    ChatModel *firstChatObj = [self.chatGroupTableArray firstObject];
                    ChatModel *lastChatObj = [self.chatGroupTableArray lastObject];
                    self.lastMsgId = [NSString stringWithFormat:@"%@",firstChatObj.messageId];//firstChatObj.messageId;
                    self.lastestMsgId = [NSString stringWithFormat:@"%@",lastChatObj.messageId];//lastChatObj.messageId;
                }

                [self.chatTableView reloadData];
                if (self.chatGroupTableArray.count) {
                    [self.noDataLabel setHidden:YES];
                }
                else {
                    [self.noDataLabel setHidden:NO];
                }
                
                if (self.chatTableView .contentSize.height > self.chatTableView .frame.size.height)
                {
                    if(self.chatGroupTableArray.count>0){
                        //[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatGroupTableArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        NSInteger inPath = [self.chatTableView numberOfRowsInSection:0] - 1 ;
                        
                        NSIndexPath* ip = [NSIndexPath indexPathForRow:inPath inSection:0];
                        [self.chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];


                    }
                }
                
            }
            
        }];
    }];
}

-(void)postPrivateChatToServer:(NSDictionary*)dict
{
    textView.text = @"";
    [ChatModel postPrivateChatData:dict withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        [Utils createMainQueue:^{
            if (success) {
                textView.text = @"";
                [self.doneBtn setTitleColor:Rgb2UIColor(170, 170, 170) forState:UIControlStateNormal];
                
                NSDictionary *dict = [[response objectForKey:kChatInfo] lastObject];
                //update unread message count
                self.groupUnreadMsgs = [[dict objectForKey:kGroupUnreadMsgCount] intValue];
                self.privateUnreadMsgs = [[dict objectForKey:kPrivateUnreadMsgCount] intValue];
                [self setUnreadMessageCount];
                
                ChatModel *chatObj  = [[ChatModel alloc]initWithChatDictionary:dict];
                //[self.chatPrivateTableArray addObject:chatObj];
                
                //////
                if (![self.chatPrivateTableArray containsObject:chatObj]) {
                    NSString *templatestMsgId = [NSString stringWithFormat:@"%@",chatObj.messageId];
                    if (![templatestMsgId isEqualToString:self.lastestMsgId]) {
                        [self.chatPrivateTableArray addObject:chatObj];
                    }
                }
                /////
                
                if (self.chatPrivateTableArray.count>0) {
                    ChatModel *firstChatObj = [self.chatPrivateTableArray firstObject];
                    ChatModel *lastChatObj = [self.chatPrivateTableArray lastObject];
                    self.lastMsgId = [NSString stringWithFormat:@"%@",firstChatObj.messageId];
                    self.lastestMsgId = [NSString stringWithFormat:@"%@",lastChatObj.messageId];
                }
                [self.chatTableView reloadData];
                if (self.chatPrivateTableArray.count) {
                    [self.noDataLabel setHidden:YES];
                }
                else {
                    [self.noDataLabel setHidden:NO];
                }
                
                if (self.chatTableView .contentSize.height > self.chatTableView .frame.size.height)
                {
                    if(self.chatPrivateTableArray.count>0){
                        
                        NSInteger inPath = [self.chatTableView numberOfRowsInSection:0] - 1 ;
                        
                        NSIndexPath* ip = [NSIndexPath indexPathForRow:inPath inSection:0];
                        [self.chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];

                    }
                }
            }
            
        }];
    }];
}


#pragma mark Get Chat
- (void)postEventNotificationStatusToServer:(NSString*)notificationStatus {
  
    [ChatModel setEventMuteUnmuteNotification:@{kNotificationEvent : notificationStatus,kEventId:self.currEventId} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        [Utils createMainQueue:^{
            if (success)
            {
                if ([notificationStatus isEqualToString:@"0"]) {
                    self.eventNotification = 0;
                    [self.btnMuteGroupChatNoti setImage:[UIImage imageNamed:@"unmute"] forState:UIControlStateNormal];
                }
                if ([notificationStatus isEqualToString:@"1"]) {
                    self.eventNotification = 1;
                    [self.btnMuteGroupChatNoti setImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
                }
            }
            
        }];
    }];
}





@end
