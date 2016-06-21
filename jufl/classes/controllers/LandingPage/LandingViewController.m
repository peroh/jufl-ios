//
//  LandingViewController.m
//  JUFL
//
//  Created by Ankur Arya on 07/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "LandingViewController.h"
#import "MobileViewController.h"
#import "TutorialViewController.h"

@interface LandingViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation LandingViewController


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
    if ([NRValidation isiPhone4]) {
        self.nameTopConstraint.constant = 10;
        self.descriptionTopConstraint.constant = 10;
        self.buttonTopConstraint.constant = 10;
        [self.view layoutIfNeeded];
    }
    
    
}
#pragma mark - IBActions
- (IBAction)startClicked:(id)sender {
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kIsWatchTutorial]) {
        MobileViewController *mobileViewController = [[MobileViewController alloc]initWithNibName:NSStringFromClass([MobileViewController class]) bundle:nil];
        
        [self.navigationController pushViewController:mobileViewController animated:YES];
    }
    else {
        TutorialViewController *tutorialViewController=[[TutorialViewController alloc]initWithNibName:NSStringFromClass([TutorialViewController class]) bundle:nil];
        [self.navigationController pushViewController:tutorialViewController animated:YES];
    }
    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    RESIGN_KEYBOARD
}

@end
