//
//  EventCreatedViewController.m
//  JUFL
//
//  Created by Ankur on 18/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "EventCreatedViewController.h"
#import "GoingViewController.h"

typedef NS_ENUM(NSUInteger, FinishViewMode) {
    FinishViewModeAppInvite = 0,
    FinishViewModeEventInvite
};

@interface EventCreatedViewController ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *okBottomConstraint;
@property (nonatomic, strong) NSString *friendsString;
@property (nonatomic, strong) EventModel *currentEvent;
@property (weak, nonatomic) IBOutlet UILabel *showActivityLabel;
@property (weak, nonatomic) IBOutlet UILabel *doneLabel;
@property (nonatomic, assign) FinishViewMode viewMode;
@end

@implementation EventCreatedViewController

- (instancetype)initWithEventModel:(EventModel *)event andFriends:(NSString *)totalFriends {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.currentEvent = event;
        self.friendsString = totalFriends;
        self.viewMode = FinishViewModeEventInvite;
    }
    
    return self;
}

- (instancetype)initWithFriends:(NSString *)totalFriends {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.friendsString = totalFriends;
        self.viewMode = FinishViewModeAppInvite;
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

-(void)viewWillAppear:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - My Function

- (void)initializeView {
    if ([NRValidation isiPhone4]) {
        self.okBottomConstraint.constant = 10;
        [self.view layoutIfNeeded];
    }
    NSString *friendStr = [self.friendsString isEqualToString:@"1"]?@"friend":@"friends";
    NSMutableAttributedString *showAttributedString = nil;
    NSDictionary *showAttributes =  @{NSFontAttributeName:FONT_ProximaNova_Light_WITH_SIZE(15.0),NSForegroundColorAttributeName: Rgb2UIColor(97, 97, 97)};
    
    NSDictionary *nameAttributes =  @{NSFontAttributeName:FONT_ProximaNova_Light_WITH_SIZE(15.0),NSForegroundColorAttributeName: Rgb2UIColor(248, 80, 77)};
    
    if (self.viewMode == FinishViewModeEventInvite) {
    NSString *eventNameString = self.currentEvent.name;
    showAttributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"Successfully showing\n%@ to %@ %@",eventNameString,self.friendsString,friendStr]];
    [showAttributedString addAttributes:showAttributes range:NSMakeRange(0,showAttributedString.length)];
    [showAttributedString addAttributes:nameAttributes range:NSMakeRange(21, eventNameString.length)];
    }
    else {
        self.doneLabel.text = @"Friends invited";
        self.doneLabel.font = FONT_ProximaNova_Thin_WITH_SIZE(25.0);
        
        showAttributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"You've successfully sent \nan invitation to Jufl app\nto %@ %@",self.friendsString,friendStr]];
        [showAttributedString addAttributes:showAttributes range:NSMakeRange(0,showAttributedString.length)];
        [showAttributedString addAttributes:nameAttributes range:NSMakeRange(43, 8)];
        
    }
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:4];
    [paragrahStyle setAlignment:NSTextAlignmentCenter];
    [showAttributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [showAttributedString length])];
    
    self.showActivityLabel.attributedText = showAttributedString;
}

#pragma mark - IBActions

- (IBAction)okClicked:(id)sender {
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    if (self.viewMode == FinishViewModeEventInvite) {
        [SharedClass sharedInstance].currentEvent = [[EventModel alloc]init];
        [self.tabBarController setSelectedIndex:0];
    }
   
    [self.navigationController popToRootViewControllerAnimated:YES];
//    GoingViewController *goingViewController = [[GoingViewController alloc]initWithEvent:[SharedClass sharedInstance].currentEvent withMode:GoingViewModeCreator];
//    goingViewController.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:goingViewController animated:YES];
}

#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    RESIGN_KEYBOARD
}
@end
