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
@interface ChatViewController ()
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
@property (nonatomic, strong) PrivateChatListModel *chooseMemberToChat;

@property (nonatomic, strong) NSNumber *groupNextPage;
@property (nonatomic, strong) NSMutableArray *chatTableArray;
@property (nonatomic, strong) NSMutableArray *privateChatListTableArray;


@end
static NSString *chatCellIdentifier = @"ChatTableViewCell";
static NSString *privCellIdentifier = @"PrivateChatListCell";
@implementation ChatViewController
{
    BOOL _wasKeyboardManagerEnabled;
    BOOL isSigleChatOn;

}

#pragma mark - View life cycle
- (instancetype)initWithChat:(EventModel *)event withViewMode:(ChatViewMode)viewMode {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.chatViewMode = viewMode;
        if (event) {
            self.currEvent = event;
            
        }
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
    [self registerForKeyboardNotifications];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[IQKeyboardManager sharedManager] setEnable:_wasKeyboardManagerEnabled];
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
- (void)initializeView {
     self.chatTableArray = [[NSMutableArray alloc]init];
    [self.groupButton.titleLabel setTextColor:Rgb2UIColor(248, 80, 77)];
    [self.privateButton.titleLabel setTextColor:Rgb2UIColor(170, 170, 170)];
    self.groupButton.selected = YES;
    self.privateButton.selected = NO;
    
    self.chatTableView.hidden = NO;
    self.privateTableView.hidden = YES;

    [self updateChatTypeTitle:@"Chatting with everyone in" secondStr:self.currEvent.name];
    [self getGroupChatFromServer];
}

-(void)addChatFieldView
{
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 40, [UIScreen mainScreen].bounds.size.width, 40)];
    
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, ([UIScreen mainScreen].bounds.size.width-80), 40)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    textView.returnKeyType = UIReturnKeyGo; //just as an example
    textView.font = [UIFont systemFontOfSize:15.0f];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.placeholder = @"Write comment";
    
    // textView.text = @"test\n\ntest";
    // textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:_containerView];
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, ([UIScreen mainScreen].bounds.size.width-72), 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, _containerView.frame.size.width, _containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
        [_containerView addSubview:imageView];
        [_containerView addSubview:textView];
        [_containerView addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(_containerView.frame.size.width - 69, 8, 63, 27);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [doneBtn setTitle:@"Send" forState:UIControlStateNormal];
    
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(sendChatMessage) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
    [_containerView addSubview:doneBtn];
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
    NSString *msg = textView.text;
    [textView resignFirstResponder];
    if (self.chatViewMode == ChatModeGroup) {
        NSMutableDictionary *postGroupMgsDict = [[NSMutableDictionary alloc]init];
        [postGroupMgsDict setObject:self.currEvent.eventId forKey:kEventId];
        [postGroupMgsDict setObject: [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]] forKey:kDateTime];
        [postGroupMgsDict setObject:msg forKey:kChatMessage];
        
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
        [self postGroupChatToServer:postGroupMgsDict];
       
    }
    else{
        
        NSMutableDictionary *postPrivateMgsDict = [[NSMutableDictionary alloc]init];
        [postPrivateMgsDict setObject:self.currEvent.eventId forKey:kEventId];
        if (self.chooseMemberToChat.toUserId) {
            [postPrivateMgsDict setObject:self.chooseMemberToChat.toUserId forKey:kReceiptId];
        }
        [postPrivateMgsDict setObject: [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]] forKey:kDateTime];
        [postPrivateMgsDict setObject:msg forKey:kChatMessage];
        
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
        [self postPrivateChatToServer:postPrivateMgsDict];
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
    self.chatTableView.hidden = NO;
    self.privateTableView.hidden = YES;
    self.containerView.hidden = NO;
    [self.chatTableView reloadData];
    
}

///////////////////


#pragma mark - IBActions
- (IBAction)backClicked:(id)sender {
    if (isSigleChatOn) {
        isSigleChatOn = NO;
        self.chatTableView.hidden = YES;
        self.privateTableView.hidden = NO;
        [self.chatTableView reloadData];
    }
    else{
    [self.navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)groupClicked:(UIButton *)sender {
    [self updateChatTypeTitle:@"Chatting with everyone in" secondStr:self.currEvent.name];
    self.chatViewMode = ChatModeGroup;
    self.groupButton.selected = YES;
    self.privateButton.selected = YES;
    self.chatTableView.hidden = NO;
    self.privateTableView.hidden = YES;
    self.containerView.hidden = NO;
    
    isSigleChatOn = NO;
    [self.chatTableView reloadData];
    
    [self.groupButton setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
    [self.privateButton setTitleColor:Rgb2UIColor(170, 170, 170) forState:UIControlStateNormal];
    [UIView animateWithDuration:0.3 animations:^{
        self.labelXConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}
- (IBAction)privateClicked:(UIButton *)sender {
    self.chatViewMode = ChatModeSingle;
    if (isSigleChatOn) {
      //do nothing
    }
    else{
    self.groupButton.selected = NO;
    self.privateButton.selected = YES;
    self.chatTableView.hidden = YES;
    self.privateTableView.hidden = NO;
    self.containerView.hidden = YES;
    }
    
    [self.privateButton setTitleColor:Rgb2UIColor(248, 80, 77) forState:UIControlStateNormal];
    [self.groupButton setTitleColor:Rgb2UIColor(170, 170, 170) forState:UIControlStateNormal];
    [UIView animateWithDuration:0.3 animations:^{
        self.labelXConstraint.constant = -(self.groupButton.size.width + 10);
        [self.view layoutIfNeeded];
    }];
    
    if (self.privateChatListTableArray.count == 0) {
        [self getPrivateChatListFromServer];
    }
    
    
}

#pragma mark - Table Data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.chatTableView.hidden == NO)
    {
        if (self.chatTableArray.count>0)
            return self.chatTableArray.count;
        else
            return 0;
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
       return 72;
    }
    else{
        return 60.0;
    }
   
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.chatTableView.hidden == NO) {
        //Group cell
            ChatTableViewCell *cell = nil;
            cell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:chatCellIdentifier];
            if( !cell )
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
               
            }
            ChatModel *chatObj = self.chatTableArray[indexPath.row];
            [cell setChatCellData:chatObj];
            return cell;
            
    }
    else{
        //Private cell
        PrivateChatListCell *cell = nil;
        cell = (PrivateChatListCell *)[tableView dequeueReusableCellWithIdentifier:privCellIdentifier];
        if( !cell )
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PrivateChatListCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        PrivateChatListModel *chatmember = self.privateChatListTableArray[indexPath.row];
        [cell setPrivateChatListCellData:chatmember];
        return cell;
    }

}

#pragma mark - Table Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.privateTableView.hidden == NO) {
        isSigleChatOn = YES;
        if (self.privateChatListTableArray.count>0) {
            self.chooseMemberToChat = self.privateChatListTableArray[indexPath.row];
            [self updateChatTypeTitle:@"Chatting with" secondStr:[NSString stringWithFormat:@"%@ %@",self.chooseMemberToChat.fisrtName,self.chooseMemberToChat.lastName]];
            [self privateChatToSelectedMember];
        }
        
    }
}


#pragma mark - Text View Delegate
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"text----%@    growing Text---- %@",text,growingTextView.text);
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
        [textView resignFirstResponder];
        
        [self resignTextView];
        
        NSString *msg=[NSString stringWithFormat:@"Maximum limit reached.You can add maximum %d characters",limit];
        [Utils showOKAlertWithTitle:@"" message:msg];
        
        return NO;
    }
    else
        return YES;
    
}



#pragma mark - APIs call

#pragma mark Get Chat List
-(void)getPrivateChatListFromServer
{
    if (self.privateChatListTableArray.count==0) {
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
    }
    [PrivateChatListModel getChatListData:@{kEventId:self.currEvent.eventId} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
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
            [self.privateTableView reloadData];
                
            }
            
        }];
    }];
}

#pragma mark Get Chat
- (void)getGroupChatFromServer {
    if (self.chatTableArray.count==0) {
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
    }
       [ChatModel getGroupChatData:@{kPageNumber : @(1),kEventId:self.currEvent.eventId} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        [Utils createMainQueue:^{
            if (success) {
//                 self.chatTableArray = [[NSMutableArray alloc]init];
//                if([response objectNonNullForKey:kPageNumber])
//                    self.groupNextPage = numberValue([response objectForKey:kPageNumber]);
//                if ([response objectNonNullForKey:kUserEvents]) {
//                    NSArray *arrResult = [response objectForKey:kUserEvents];
//                    for (NSDictionary *dict in arrResult) {
//                        ChatModel *chat  = [[ChatModel alloc]initWithChatDictionary:dict];
//                        [self.chatTableArray addObject:chat];
//                    }
//                
//                }
                 [self.chatTableView reloadData];
                //            if (self.tableDataArray.count) {
                //                [self.noDataLabel setHidden:YES];
                //            }
                //            else {
                //                [self.noDataLabel setHidden:NO];
                //
            }
                
            }];
    }];
}

- (void)getPreviousChatFromServer
{
    [ChatModel getGroupChatData:@{kPageNumber : @(1),kEventId:@""} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        //[Utils stopActivityIndicatorInView];
        [Utils createMainQueue:^{
            if (success) {
                if([response objectNonNullForKey:kPageNumber])
                    self.groupNextPage = numberValue([response objectForKey:kPageNumber]);
                if ([response objectNonNullForKey:kUserEvents]) {
                    NSArray *arrResult = [response objectForKey:kUserEvents];
                    for (NSDictionary *dict in arrResult) {
                        ChatModel *chatObj  = [[ChatModel alloc]initWithChatDictionary:dict];
                        [self.chatTableArray addObject:chatObj];
                        [self.chatTableView reloadData];
                    }
                }
                [self.chatTableView reloadData];
                
            }
            
        }];
    }];
}
#pragma mark Post Chat
-(void)postGroupChatToServer:(NSDictionary*)dict
{
    [ChatModel postGroupChatData:dict withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        [Utils createMainQueue:^{
            if (success) {
                textView.text = @"";
                ChatModel *chatObj  = [[ChatModel alloc]initWithChatDictionary:response];
                [self.chatTableArray addObject:chatObj];
                [self.chatTableView reloadData];
            }
            
        }];
    }];
}

-(void)postPrivateChatToServer:(NSDictionary*)dict
{
    [ChatModel postPrivateChatData:dict withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        [Utils createMainQueue:^{
            if (success) {
                textView.text = @"";
                ChatModel *chatObj  = [[ChatModel alloc]initWithChatDictionary:response];
                [self.chatTableArray addObject:chatObj];
                [self.chatTableView reloadData];
            }
            
        }];
    }];
}

#pragma mark Refresh Chat
- (void)getLatestChatFromServer {
    
    [ChatModel getLatestChatData:@{kPageNumber : @(1),kEventId:@""} withSuccessBlock:^(BOOL success, NSDictionary *response, NSError *error) {
        //[Utils stopActivityIndicatorInView];
        [Utils createMainQueue:^{
            if (success) {
                if([response objectNonNullForKey:kPageNumber])
                    self.groupNextPage = numberValue([response objectForKey:kPageNumber]);
                if ([response objectNonNullForKey:kUserEvents]) {
                    self.chatTableArray = [[NSMutableArray alloc]init];
                    NSArray *arrResult = [response objectForKey:kUserEvents];
                    for (NSDictionary *dict in arrResult) {
                        ChatModel *chat  = [[ChatModel alloc]initWithChatDictionary:dict];
                        [self.chatTableArray addObject:chat];
                    }
                    
                }
                [self.chatTableView reloadData];
                //            if (self.tableDataArray.count) {
                //                [self.noDataLabel setHidden:YES];
                //            }
                //            else {
                //                [self.noDataLabel setHidden:NO];
                //
            }
            
        }];
    }];
}





@end
