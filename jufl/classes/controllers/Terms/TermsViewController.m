//
//  TermsViewController.m
//  JUFL
//
//  Created by Rakesh Lohan on 19/08/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "TermsViewController.h"

@interface TermsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint;
@property (nonatomic, assign) TermsPolicyMode tPMode;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)backButtonClicked:(UIButton *)sender;
@end

@implementation TermsViewController
- (instancetype)initWithMode :(TermsPolicyMode)mode {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.tPMode = mode;
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

#pragma mark-My Functions
- (void)initializeView {
    
    if (ScreenHeight == 480) {
        self.logoTopConstraint.constant = 20;
        [self.view layoutIfNeeded];
    }
    
    self.webView.opaque = NO;
    if (self.tPMode==TermsMode) {
            if ([Connection isInternetAvailable])
            {
                [Utils startActivityIndicatorWithMessage:kPleaseWait];
                [Connection callServiceWithName:KTermsPolicy postData:nil callBackBlock:^(id response, NSError *error) {
                    [Utils stopActivityIndicatorInView];
        
                    if (success(response, error)){
        
                        WebServiceResponse *data = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
        
                        if(data.result.count>0){
        
                            NSString *string = [[data.result objectAtIndex:0]valueForKey:@"term_condition"];
                            string = [self changeFont:string];
                            [[NSUserDefaults standardUserDefaults] setObject:string forKey:kUserTermsPolicy];
                            [self.webView loadHTMLString:[[NSUserDefaults standardUserDefaults] objectForKey:kUserTermsPolicy] baseURL:nil];
                        }
                        [Utils stopActivityIndicatorInView];
                    }
        
                    else if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserTermsPolicy])
                    {
                        NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:kUserTermsPolicy];
                        [self.webView loadHTMLString:string baseURL:nil];
                    }
                }];
            }
        
            else if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserTermsPolicy])
            {
                NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:kUserTermsPolicy];
                [self.webView loadHTMLString:string baseURL:nil];
//                
//                [self.webView loadHTMLString:[[NSUserDefaults standardUserDefaults] objectForKey:kUserTermsPolicy] baseURL:nil];
            }

    }else
    {
        self.titleLabel.text=@"PRIVACY POLICY";
        if ([Connection isInternetAvailable])
        {
            [Utils startActivityIndicatorWithMessage:kPleaseWait];
            [Connection callServiceWithName:KPrivacyPolicy postData:nil callBackBlock:^(id response, NSError *error) {
                [Utils stopActivityIndicatorInView];
                
                if (success(response, error)){
                    
                    WebServiceResponse *data = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
                    
                    if(data.result.count>0){
                        
                        NSString *string = [[data.result objectAtIndex:0]valueForKey:@"privacy"];
                        string = [self changeFont:string];
                        [[NSUserDefaults standardUserDefaults] setObject:string forKey:kUserPrivacyPolicy];
                        [self.webView loadHTMLString:[[NSUserDefaults standardUserDefaults] objectForKey:kUserPrivacyPolicy] baseURL:nil];
                    }
                    [Utils stopActivityIndicatorInView];
                }
                else if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserPrivacyPolicy])
                {
                    [self.webView loadHTMLString:[[NSUserDefaults standardUserDefaults] objectForKey:kUserPrivacyPolicy] baseURL:nil];
                }
            }];
        }
        else if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserPrivacyPolicy])
        {
            [self.webView loadHTMLString:[[NSUserDefaults standardUserDefaults] objectForKey:kUserPrivacyPolicy] baseURL:nil];
        }
    }
}

- (NSString *)changeFont:(NSString *)original {
    UIFont *font = FONT_ProximaNova_Regular_WITH_SIZE(15.0);
    
   NSString *string = [NSString stringWithFormat:@"<span style=\"font-family: %@; font-size: %i; color:rgb(97,97,97)\">%@</span>",
              font.fontName,
              (int) font.pointSize,
              original];
    
    return string;
}
#pragma mark-Action
- (IBAction)backButtonClicked:(UIButton *)sender {
    if (self.navigationController.viewControllers.count > 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
