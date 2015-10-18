//
//  AboutAppViewController.m
//  JUFL
//
//  Created by Rakesh Lohan on 19/08/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "AboutAppViewController.h"

@interface AboutAppViewController ()
- (IBAction)backButtonClicked:(UIButton *)sender;

@end

@implementation AboutAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-Action
- (IBAction)backButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
