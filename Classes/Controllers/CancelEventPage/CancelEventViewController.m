//
//  CancelEventViewController.m
//  JUFL
//
//  Created by Ankur on 05/08/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "CancelEventViewController.h"
#import "UITextView+Placeholder.h"

#define ACCEPTABLE_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define kMaxLength 150

@interface CancelEventViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDetailLabel;
@property (weak, nonatomic) IBOutlet UITextView *cancelMessageTextView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) EventModel *event;
@end

@implementation CancelEventViewController

#pragma mark - View Lifecycle
- (instancetype)initWithEvent:(EventModel *)event {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
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

#pragma mark - My Function

- (void)initializeView {
    self.eventNameLabel.text = self.event.name;
    if([self.event.startTime isToday]) {
        self.eventDetailLabel.attributedText = [self getAttributedString:[NSString stringWithFormat:@"today %@",[self.event.startTime stringWithFormat:@"hh:mm a"]] :self.event.location.name];
    }
    else if ([self.event.startTime isTomorrow]) {
        self.eventDetailLabel.attributedText = [self getAttributedString:[NSString stringWithFormat:@"tomorrow %@",[self.event.startTime stringWithFormat:@"hh:mm a"]] :self.event.location.name];
    }
    else {
        self.eventDetailLabel.attributedText = [self getAttributedString:[self.event.startTime string] :self.event.location.name];
    }
    
    self.cancelMessageTextView.layer.borderColor = Rgb2UIColor(170, 170, 170).CGColor;
    self.cancelMessageTextView.layer.borderWidth = 1.5;
    self.cancelMessageTextView.layer.cornerRadius = 1.0;
    self.cancelMessageTextView.placeholder = @"Enter the reason why you want to cancel this activity.";
    self.cancelMessageTextView.placeholderColor = Rgb2UIColor(170, 170, 170);
    self.cancelButton.enabled = NO;
    self.cancelButton.backgroundColor = Rgb2UIColorWithAlpha(97, 97, 97, 0.4);
}

-(NSMutableAttributedString *)getAttributedString:(NSString *)firstString :(NSString *)secondString {
    
    NSMutableAttributedString *showAttributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@",firstString, secondString]];
    
    NSDictionary *secondAttributes =  @{NSFontAttributeName:FONT_ProximaNova_Semibold_WITH_SIZE(13.0),NSForegroundColorAttributeName: Rgb2UIColor(109, 110, 113)};
    
    NSDictionary *firstAttributes =  @{NSFontAttributeName:FONT_ProximaNova_Light_WITH_SIZE(13.0),NSForegroundColorAttributeName: Rgb2UIColor(109, 110, 113)};
    
    [showAttributedString addAttributes:firstAttributes range:NSMakeRange(0,showAttributedString.length)];
    [showAttributedString addAttributes:secondAttributes range:NSMakeRange(0, firstString.length)];
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:4];
    [paragrahStyle setAlignment:NSTextAlignmentCenter];
    [showAttributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [showAttributedString length])];
    
    return showAttributedString;
}

#pragma mark - IBAction
- (IBAction)cancelClicked:(id)sender {
    [EventModel cancelEventWithParameters:@{kEventId:self.event.eventId, kReason:self.cancelMessageTextView.text, kEventName:self.event.name} completion:^(BOOL success, EventModel *event, NSError *error) {
        if (success) {
            self.cancelMessageTextView.text = @"";
            [Utils createMainQueue:^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }
    }];
}
- (IBAction)backClicked:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length == 0 && [text isEqualToString:@" "]) {
        return NO;
    }
    
    if(range.length + range.location > textView.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    NSString *currentString = @"";
    if([text isEqualToString:@""])
    {
        if([textView.text length]>0)
        {
            currentString = [textView.text substringToIndex:textView.text.length-1];
        }
    }
    else
        currentString = [textView.text stringByAppendingString:text];
    
    if (currentString.length>0) {
        self.cancelButton.enabled = YES;
        self.cancelButton.backgroundColor = Rgb2UIColorWithAlpha(248, 80, 77, 1);
    }
    else {
        self.cancelButton.enabled = NO;
        self.cancelButton.backgroundColor = Rgb2UIColorWithAlpha(97, 97, 97, 0.4);
    }
//    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
//    
//    NSString *filtered = [[text componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
//    return [text isEqualToString:filtered] && newLength <= kMaxLength;
    return  newLength <= kMaxLength;

}

- (void)textViewDidEndEditing:(UITextView *)textView {
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (self.cancelMessageTextView.text.length > 0) {
        self.cancelButton.enabled = YES;
        self.cancelButton.backgroundColor = Rgb2UIColorWithAlpha(248, 80, 77, 1);
    }
    else {
        self.cancelButton.enabled = NO;
        self.cancelButton.backgroundColor = Rgb2UIColorWithAlpha(97, 97, 97, 0.4);
    }
}
@end
