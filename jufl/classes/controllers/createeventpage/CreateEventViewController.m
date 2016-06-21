//
//  CreateEventViewController.m
//  JUFL
//
//  Created by Ankur on 13/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "CreateEventViewController.h"
#import "CreateEventTableViewCell.h"
#import "EventModel.h"
#import "SelectLocationViewController.h"
#import "YIPopupTextView.h"
#import "IQKeyboardManager.h"
#import "EventCreatedViewController.h"
#import "CancelEventViewController.h"
#import "AdditionalInfoViewController.h"
#import "Mixpanel.h"
#import "AppDelegate.h"

#define ACCEPTABLE_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()/.,;: -_"


typedef NS_ENUM(NSUInteger, EventInfo) {
    EventInfoName = 0,
    EventInfoAdditionalInfo,
    EventInfoStartTime,
    EventInfoEndTime
};

static NSString *cellIdentifier = @"CreateEventTableViewCell";

@interface CreateEventViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, YIPopupTextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *eventInfoTableView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *crossButton;
@property (nonatomic, strong) NSArray *tableDataArray;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) EventModel *currentEvent;
@property (nonatomic, assign) EventViewMode viewMode;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@end

@implementation CreateEventViewController

#pragma mark - View life cycle
- (instancetype)initWithEvent:(EventModel *)event withViewMode:(EventViewMode)viewMode {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.viewMode = viewMode;
        if (event) {
            _currentEvent = event;
        }
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
    
    [[Mixpanel sharedInstance] track:@"CreateEventTapped"];
    
    if (self.viewMode == EventViewModeCreate) {
        self.backButton.hidden = YES;
        self.cancelButton.hidden = YES;
        self.currentEvent = [SharedClass sharedInstance].currentEvent;
        self.currentEvent.startTime = self.currentEvent.startTime?self.currentEvent.startTime:[self minuteRoundOff:[NSDate date]];
        self.currentEvent.endTime = self.currentEvent.endTime?self.currentEvent.endTime:[self minuteRoundOff:[[NSDate date]dateByAddingHours:1]];
        [self.eventInfoTableView reloadData];
    }
    else {
        self.titleLabel.text = @"Edit";
        self.crossButton.hidden = YES;
        self.cancelButton.hidden = NO;
    }
    if (!self.currentEvent.name || !self.currentEvent.startTime || !self.currentEvent.endTime) {
        [self toggleNextButtonState:NO];
    }
    else {
        [self toggleNextButtonState:YES];
    }
    if (self.viewMode == EventViewModeEdit && [self.currentEvent.startTime isEarlierThanDate:[NSDate date]] && [self.currentEvent.goingCount integerValue] > 1) {
        self.cancelButton.enabled = NO;
        [self.cancelButton setTitleColor:Rgb2UIColorWithAlpha(97, 97, 97, 0.3) forState:UIControlStateNormal] ;
    }
    else {
        self.cancelButton.enabled = YES;
        [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal] ;
    }
}
#pragma mark - My functions

- (NSDate*)minuteRoundOff:(NSDate*)inDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSCalendarUnitYear| NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate: inDate];
//    [comps setHour: [comps hour]+1];//NSDateComponents handles rolling over between days, months, years, etc
    if (comps.minute % 5 != 0) {
        NSInteger min = 5-(comps.minute % 5);
        [comps setMinute:comps.minute+min];
    }
    
    return [calendar dateFromComponents:comps];
}

- (void)initializeView {
    self.datePicker = [[UIDatePicker alloc]init];
    self.datePicker.minimumDate = [NSDate date];
    self.datePicker.minuteInterval = 5;
    [self.datePicker addTarget:self action:@selector(startDateChange:) forControlEvents:UIControlEventValueChanged];
    
    [self.eventInfoTableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.eventInfoTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableDataArray = @[@"What's happening", @"Extra info", @"When", @"Until"];
    [self toggleNextButtonState:NO];
//    self.currentEvent = [SharedClass sharedInstance].currentEvent;
//    self.currentEvent.startTime = [NSDate date];
//    self.currentEvent.endTime = [[NSDate date]dateByAddingHours:1];
//    [self.eventInfoTableView reloadData];
}

- (void)startDateChange:(id)sender {
    
}

- (void)showPopUp {
    AdditionalInfoViewController *additionalInfoViewController = [[AdditionalInfoViewController alloc]initWithInfo:self.currentEvent.additionalInfo withCompletion:^(NSString *info) {
        self.currentEvent.additionalInfo = info;
        [self.eventInfoTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [self presentViewController:additionalInfoViewController animated:YES completion:^{
        
    }];
}
- (void)toggleNextButtonState:(BOOL)isEnabled {
    self.nextButton.enabled = isEnabled;
    self.nextButton.backgroundColor = Rgb2UIColorWithAlpha(97, 97, 97, 0.4);
    if (isEnabled) {
        self.nextButton.backgroundColor = Rgb2UIColor(33, 205, 182);
    }
    
}

#pragma mark - IBActions
- (IBAction)nextClicked:(id)sender {
    [self.view endEditing:YES];
        SelectLocationViewController *selectLocationViewController = [[SelectLocationViewController alloc]initWithEvent:self.currentEvent andViewMode:self.viewMode];
        selectLocationViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:selectLocationViewController animated:YES];
}
- (IBAction)crossClicked:(id)sender {
    if (self.currentEvent.name || self.currentEvent.additionalInfo || self.currentEvent.startTime || self.currentEvent.endTime) {
        [[Utils sharedInstance]openAlertViewWithTitle:kTitle message:@"Current event data will be lost. Do you want to continue?" buttons:@[@"Cancel", @"Ok"] completion:^(UIAlertView *alert, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if(self.viewMode == EventViewModeCreate) {
                    [SharedClass sharedInstance].currentEvent = [[EventModel alloc]init];
                    self.currentEvent = [SharedClass sharedInstance].currentEvent;
                }
                else {
                    self.currentEvent = nil;
                    [self.navigationController popViewControllerAnimated:YES];
                }
                [self toggleNextButtonState:NO];
                [self.eventInfoTableView reloadData];
            }
        }];
    }
}

- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelEventClicked:(id)sender {
    CancelEventViewController *cancelEventViewController = [[CancelEventViewController alloc]initWithEvent:self.currentEvent];
    [self.navigationController pushViewController:cancelEventViewController animated:YES];
}
#pragma mark - Delegates
#pragma mark - Table Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreateEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.infoTitle.text = self.tableDataArray[indexPath.row];
    cell.infoDetail.delegate = self;
    cell.infoDetail.tag = indexPath.row;
    
    switch (indexPath.row) {
        case EventInfoName:
        {
            cell.infoDetail.text = self.currentEvent.name;
            cell.infoDetail.placeholder = @"eg. Coffee, Drinks";
        }
            break;
        case EventInfoAdditionalInfo:
        {
            
            cell.infoDetail.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
            if ([self isBase64Data:self.currentEvent.additionalInfo]) {
                /********************Decode Data********************/
                NSData *nsdataFromBase64String = [[NSData alloc]
                                                  initWithBase64EncodedString:self.currentEvent.additionalInfo options:0];
                
                
                // Decoded NSString from the NSData
                NSString *base64Decoded = [[NSString alloc]
                                           initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
                DLog(@"Decoded: %@", base64Decoded);
                cell.infoDetail.text = [NSString stringWithFormat:@"%@",base64Decoded];
                /********************Decode Data********************/

            }
            else{
                cell.infoDetail.text = self.currentEvent.additionalInfo;
            }
            
            cell.infoDetail.placeholder = @"(optional)";
            cell.infoDetail.enabled = NO;
        }
            break;
        case EventInfoStartTime:
        {
            if (self.viewMode == EventViewModeEdit && [self.currentEvent.startTime isEarlierThanDate:[NSDate date]]) {
                cell.infoDetail.enabled = NO;
                [cell.infoDetail setTextColor:Rgb2UIColorWithAlpha(97, 97, 97, .3)];
            }
            else {
                cell.infoDetail.enabled = YES;
            }
            cell.infoDetail.inputView = self.datePicker;
            cell.infoDetail.text = self.currentEvent.startTime?[NSString stringWithFormat: @"%@", [Utils stringFromDate:self.currentEvent.startTime withFormat:@"hh:mm a dd/MM/yy"]]:@"";
            
            
            cell.infoDetail.placeholder = @"Select start time";
        }
            break;
        case EventInfoEndTime:
        {
            cell.infoDetail.enabled = YES;
            cell.infoDetail.inputView = self.datePicker;
            cell.infoDetail.text = self.currentEvent.endTime?[NSString stringWithFormat: @"%@", [Utils stringFromDate:self.currentEvent.endTime withFormat:@"hh:mm a dd/MM/yy"]]:@"";
            cell.infoDetail.placeholder = @"Select end time";
        }
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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

#pragma mark - Table View Delegates

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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        [self showPopUp];
    }
}

#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == EventInfoEndTime) {
        if (!self.currentEvent.startTime ) {
            return NO;
        }
        else {
        return YES;
        }
    }
    else if (textField.tag == EventInfoAdditionalInfo) {
        //        [self showPopUp];
        return NO;
    }
    else {
    return YES;
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    switch (textField.tag) {
        case EventInfoStartTime:
        {
            self.datePicker.tag = textField.tag;
            self.datePicker.maximumDate = nil;
            self.datePicker.minimumDate = [self minuteRoundOff:[NSDate date]];
            self.datePicker.date = self.currentEvent.startTime?self.currentEvent.startTime:[self minuteRoundOff:[NSDate date]];
        }
            break;
        case EventInfoEndTime:
        {
            self.datePicker.minimumDate = [[self.currentEvent.startTime dateByAddingMinutes:5] isEarlierThanDate:[NSDate date]]?[self minuteRoundOff:[NSDate date]]:[self.currentEvent.startTime dateByAddingMinutes:5];
            self.datePicker.maximumDate = [self.currentEvent.startTime dateByAddingDays:1];
            self.datePicker.date = self.currentEvent.endTime?self.currentEvent.endTime:[self minuteRoundOff:[NSDate date]];
            
            self.datePicker.tag = textField.tag;
        }
            break;
        case EventInfoAdditionalInfo:
        {
            
        }
            break;
        default:
            break;
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case EventInfoStartTime:
        {
            self.currentEvent.startTime = [self.datePicker date];
            self.currentEvent.endTime = [[self.datePicker date]dateByAddingHours:1];
            
            textField.text = [NSString stringWithFormat: @"%@", [Utils stringFromDate:self.currentEvent.startTime withFormat:@"hh:mm a dd/MM/yy"]];
            
//            NSString *strdate= [Utils stringFromDate:self.currentEvent.startTime withFormat:@"hh:mm a dd/MM/yy"];
//             NSLog(@"%@",strdate);
////            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
//            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//            [formatter setLocale:[NSLocale systemLocale]];
//            [formatter setDateFormat:@"hh:mm a dd/MM/yy"];
//            NSDate * date = [formatter dateFromString:strdate];
//            
//            NSLog(@"%@",date);
//            
//            
//               NSLog(@"%@",[NSDate date]);
            
         //    NSLog(@"%@", self.currentEvent.startTime);
            
            

            
            NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
            [self.eventInfoTableView reloadRowsAtIndexPaths:@[endIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
            break;
        case EventInfoEndTime:
        {
            if (self.viewMode == EventViewModeEdit && [self.currentEvent.startTime isEarlierThanDate:[NSDate date]]) {
                if ([self.datePicker date]>self.currentEvent.startTime) {
                    self.currentEvent.endTime = [self.datePicker date];
                    textField.text = [NSString stringWithFormat: @"%@", [Utils stringFromDate:self.currentEvent.endTime withFormat:@"hh:mm a dd/MM/yy"]];
                }
                
            }
            else
            {
                self.currentEvent.endTime = [self.datePicker date];
                textField.text = [NSString stringWithFormat: @"%@", [Utils stringFromDate:self.currentEvent.endTime withFormat:@"hh:mm a dd/MM/yy"]];
            }
            
            //            textField.text = [NSString stringWithFormat: @"%@", [Utils stringFromDate:self.currentEvent.endTime withFormat:@"hh:mm a dd/MM/yy"]];
        }
            break;
        case EventInfoName:
        {
            self.currentEvent.name = [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "];
            //            textField.text = self.currentEvent.name;
        }
            break;
        case EventInfoAdditionalInfo:
        {
            
            self.currentEvent.additionalInfo = textField.text;
            
        }
            break;
        default:
            break;
    }
    
    if ([NRValidation isValidString:self.currentEvent.name] && self.currentEvent.startTime && self.currentEvent.endTime) {
        [self toggleNextButtonState:YES];
    }
    else {
        [self toggleNextButtonState:NO];
    }
    
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (range.location == textField.text.length && [string isEqualToString:@" "]) {
        // ignore replacement string and add your own
        if (textField.text.length < 25) {
            textField.text = [textField.text stringByAppendingString:@"\u00a0"];
        }
        
        return NO;
    }
    
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;

    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered] && newLength <= 25;
    
    //    return newLength <= 25;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    RESIGN_KEYBOARD
}

- (UIRectEdge)edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom;
}

// block Menucontroller
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    }];
    return [super canPerformAction:action withSender:sender];
}

@end
