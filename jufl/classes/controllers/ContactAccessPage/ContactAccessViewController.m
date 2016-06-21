//
//  ContactAccessViewController.m
//  JUFL
//
//  Created by Ankur Arya on 09/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "ContactAccessViewController.h"
#import "KTSContactsManager.h"
#import "AppDelegate.h"
#import "Contacts.h"

@interface ContactAccessViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *disclaimerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *letMeInTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (nonatomic, strong) KTSContactsManager *contactsManager;
@end

@implementation ContactAccessViewController

#pragma mark - View life cycle

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
- (void)initializeView {
    self.contactsManager = [KTSContactsManager sharedManager];
    
    if ([NRValidation isiPhone4]) {
        self.separatorTopConstraint.constant = 10;
        self.disclaimerTopConstraint.constant = 10;
        self.letMeInTopConstraint.constant = 10;
        self.titleLabelTopConstraint.constant = 10;
    }
    [self.view layoutIfNeeded];
}

- (void)goToFeed {
    [appDelegate setRootForApp];
}
#pragma mark - IBActions
- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)letMeInClicked:(id)sender {
//    [self.contactsManager importContacts:^(NSArray *contacts) {
//        [self goToFeed];
//    }];
    [Utils startActivityIndicatorWithMessage:@"Fetching contacts"];
    [[Contacts sharedInstance]fetchContactsFromAddressBookWithHandler:^(BOOL success, NSArray *appUser, NSArray *nonAppUser, NSError *error) {
        [Utils stopActivityIndicatorInView];
        [self goToFeed];
    }];
    
}
- (IBAction)cancelClicked:(id)sender {
    [self goToFeed];
    
}

#pragma mark - Delegates
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    RESIGN_KEYBOARD
}
@end
