//
//  NRTableViewController.m
//  AroundAbout
//
//  Created by Naveen Rana on 21/01/15.
//  Copyright (c) 2015 Naveen Rana. All rights reserved.
//

#import "NRTutorial.h"
#import "GHWalkThroughView.h"
#import "AppDelegate.h"


static NSString * const sampleDesc1 = @"Discover who's around you in real time.";

static NSString * const sampleDesc2 = @"Have the option to send a virtual drink via the MyScene bar to anyone around you.";

static NSString * const sampleDesc3 = @"Connect and chat with real people instantly";

static NSString * const sampleDesc4 = @"FIND LIKED PLACES IN FAVOURITES \nSWIPE TO EDIT PLACES";

static NSString * const sampleDesc5 = @"CREATE YOUR DAY FROM\n FAVOURITES & SWIPE TO SHARE";

@interface NRTutorial ()<GHWalkThroughViewDataSource>

@property (nonatomic, strong) GHWalkThroughView* ghView ;

@property (nonatomic, strong) NSArray* descStrings;

@property (nonatomic, strong) UILabel* welcomeLabel;
@property (nonatomic,retain) NSArray *titleArray;

@end

@implementation NRTutorial


#pragma mark My Functions
+(id)sharedInstance
{
    static dispatch_once_t once=0;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        
    });
    return sharedInstance;
}
-(void)showWalkThrough
{
    self.ghView.isfixedBackground = NO;

    self.ghView.floatingHeaderView = nil;

    UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;
//#warning change this to main navigation controller
    if(![self showTutorial])return;
    [_ghView setWalkThroughDirection:GHWalkThroughViewDirectionHorizontal];
    UILabel* welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    welcomeLabel.text = @"Welcome";
    welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40];
    welcomeLabel.textColor = [UIColor whiteColor];
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    self.welcomeLabel = welcomeLabel;
    self.titleArray = [[NSArray alloc] initWithObjects:@"Check in", @"Invite for a drink", @"Start a conversation",@"FAVOURITES",@"MY DAY", nil];
    self.descStrings = [NSArray arrayWithObjects:sampleDesc1,sampleDesc2, sampleDesc3, sampleDesc4, sampleDesc5, nil];
    _ghView = [[GHWalkThroughView alloc] initWithFrame:navController.view.bounds];
    [_ghView setDataSourceCustom:self];
    [self.ghView showInView:navController.view animateDuration:0.3];
    
}
// Show Tutorial
- (BOOL)showTutorial
{
    BOOL isWatchTutorial = [UserDefaluts boolForKey:kIsWatchTutorial];
    NSString *currentBundleVersion=[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    NSString *savedBundleVersion = NULLVALUE([UserDefaluts objectForKey:kBundleCurrentVersion]);
    if(!isWatchTutorial||![currentBundleVersion isEqualToString:savedBundleVersion]) //show tutorial
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];

        [UserDefaluts setBool:YES forKey:kIsWatchTutorial];
        [UserDefaluts setObject:currentBundleVersion forKey:kBundleCurrentVersion];
        [UserDefaluts synchronize];
        return YES;
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];

    }
    return NO;
}

#pragma mark - GHDataSource

-(NSInteger)numberOfPages
{
    return 4;
}

- (void)configurePage:(GHWalkThroughPageCell *)cell atIndex:(NSInteger)index
{
    cell.title = [NSString stringWithFormat:@"%@",[self.titleArray objectAtIndex:index]];
    cell.titleImage = [UIImage imageNamed:[NSString stringWithFormat:@"title_%ld", (long)index+1]];
    cell.desc = [self.descStrings objectAtIndex:index];
}

- (UIImage*)bgImageforPage:(NSInteger)index
{
    NSString* imageName =[NSString stringWithFormat:@"bg_1"];
    UIImage* image = [UIImage imageNamed:imageName];
    return image;
}
@end
