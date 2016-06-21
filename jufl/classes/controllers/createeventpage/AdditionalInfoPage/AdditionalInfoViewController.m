//
//  AdditionalInfoViewController.m
//  JUFL
//
//  Created by Ankur on 17/08/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "AdditionalInfoViewController.h"
#import "UITextView+Placeholder.h"

#define ACCEPTABLE_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define kMaxLength 300

@interface AdditionalInfoViewController ()
@property (weak, nonatomic) IBOutlet UITextView *additionalInfoText;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) NSString *additionalInfoString;
@property (weak, nonatomic) IBOutlet UIButton *crossButton;
@end

@implementation AdditionalInfoViewController

#pragma mark - View lifecycle
- (instancetype)initWithInfo:(NSString *)info withCompletion:(AdditionalInfoCompletionHandler)block {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _additionalInfoCompletionHandler = block;
        self.additionalInfoString = info;
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

#pragma mark - My functions

-(void)initializeView {
    self.additionalInfoText.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15.0f];
    if ([self isBase64Data:self.additionalInfoString]) {
        
        /********************Decode Data********************/
        NSData *nsdataFromBase64String = [[NSData alloc]
                                          initWithBase64EncodedString:self.additionalInfoString options:0];
        
        // Decoded NSString from the NSData
        NSString *base64Decoded = [[NSString alloc]
                                   initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
        DLog(@"Decoded: %@", base64Decoded);
        self.additionalInfoText.text = [NSString stringWithFormat:@"%@",base64Decoded];
        /********************Decode Data********************/
        

    }
    else{
         self.additionalInfoText.text = self.additionalInfoString;
    }

    self.additionalInfoText.layer.borderColor = Rgb2UIColor(170, 170, 170).CGColor;
    self.additionalInfoText.layer.borderWidth = 1.5;
    self.additionalInfoText.layer.cornerRadius = 1.0;
    
    self.additionalInfoText.placeholder = @"Enter additional info.";
    self.additionalInfoText.placeholderColor = Rgb2UIColor(170, 170, 170);
    
//    self.additionalInfoText.textContainer.maximumNumberOfLines = 6;
    
    [self.additionalInfoText becomeFirstResponder];
    
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

- (void)getAdditionalInfoWithCompletionHandler:(AdditionalInfoCompletionHandler)handler {
    _additionalInfoCompletionHandler = handler;
}
#pragma mark - IBActions

- (IBAction)crossClicked:(id)sender {
    RESIGN_KEYBOARD
    [self dismissViewControllerAnimated:YES completion:^{
        _additionalInfoCompletionHandler(self.additionalInfoString);
    }];
}
- (IBAction)doneClicked:(id)sender {
    
    
    RESIGN_KEYBOARD
    [self dismissViewControllerAnimated:YES completion:^{
        _additionalInfoCompletionHandler(self.additionalInfoText.text);
    }];
}


#pragma mark - Delegate
#pragma mark - Textview delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if(range.length + range.location > textView.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
 
    return  newLength <= kMaxLength;
    
}

@end
