//
//  TutorialViewController.m
//  MiVista
//
//  Created by Ankur Arya on 30/06/15.
//  Copyright (c) 2015 Naveen Rana. All rights reserved.
//

#import "TutorialViewController.h"
#import "TutorialCollectionViewCell.h"
#import "MobileViewController.h"
 #import <AddressBookUI/AddressBookUI.h>

#define CellIdentifier @"TutorialCollectionViewCell"

static NSString * const sampleDesc1 = @"Scroll through your feed\n to see what friends are doing";

static NSString * const sampleDesc2 = @"If you are free, join up\n with a tap";

static NSString * const sampleDesc3 = @"Name when you are free,\n and what you want to do";

static NSString * const sampleDesc4 = @"Let people know your current\n location, or choose a cafe";

static NSString * const sampleDesc5 = @"Select which friends will see what\n you are doing, and wait\n for them to join!";

static NSString * const sampleDesc6 = @"We need access to your contacts\n so you can join up with friends!";


@interface TutorialViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *tutCollectionView;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *detailArray;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (nonatomic, assign) TutorialViewMode viewMode;

- (IBAction)skipButton:(UIButton *)sender;
@end

@implementation TutorialViewController
- (instancetype)initWithViewMode:(TutorialViewMode)mode {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.viewMode = mode;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tutCollectionView.delegate=self;
    self.tutCollectionView.dataSource=self;
    [self initializeView];
}

-(void)viewWillDisappear:(BOOL)animated{
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Mark-function
- (void)initializeView {
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kIsWatchTutorial];
    [self.okButton setHidden:YES];
    if (self.viewMode == TutorialViewModeSettings) {
        [self.okButton setTitle:@"Done" forState:UIControlStateNormal];
    }
    else {
        [self.okButton setTitle:@"OK, let's go!" forState:UIControlStateNormal];
    }
    self.titleArray = [[NSArray alloc] initWithObjects:@"Check who is free", @"Join in", @"Say what you are doing", @"Choose where", @"Show it to friends",@"Last thing!",nil];
    self.detailArray = @[sampleDesc1, sampleDesc2, sampleDesc3, sampleDesc4, sampleDesc5 ,sampleDesc6];
    [self.tutCollectionView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellWithReuseIdentifier:CellIdentifier];
}

#pragma Mark-Delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    _pageControl.currentPage = indexPath.row;
    TutorialCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *imageName = [NSString stringWithFormat:@"title_%ld",(long)indexPath.row];
    cell.tutDetailLabel.text = self.detailArray[indexPath.row];
    cell.tutTitleLabel.text = self.titleArray[indexPath.row];
    cell.tutImageView.image = [UIImage imageNamed:imageName];
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView indexPathsForVisibleItems];
    }

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSIndexPath *indexPath = nil;
    for (UICollectionViewCell *cell in [self.tutCollectionView visibleCells]) {
        indexPath = [self.tutCollectionView indexPathForCell:cell];
        NSLog(@"%li",(long)indexPath.row);
    }
    
    if (indexPath.row==5) {
            [self.okButton setHidden:NO];
            [self.skipButton setHidden:YES];

    }
    else
        {
                [self.okButton setHidden:YES];
                [self.skipButton setHidden:NO];
            
        }

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath; {
    
    return CGSizeMake(ScreenWidth, ScreenHeight);
}


#pragma Mark-Actions
- (IBAction)okButton:(id)sender {
    if (self.viewMode == TutorialViewModeSettings) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [Contacts askContactPermission:^(BOOL success) {
            [Utils createMainQueue:^{
                MobileViewController *mobileViewController = [[MobileViewController alloc]initWithNibName:NSStringFromClass([MobileViewController class]) bundle:nil];
                [self.navigationController pushViewController:mobileViewController animated:YES];
            }];
        }];
    }
}



- (IBAction)skipButton:(UIButton *)sender {
    _pageControl.currentPage=5;
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:5 inSection:0];
    [self.tutCollectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:0 animated:NO];
        [self.okButton setHidden:NO];
        [self.skipButton setHidden:YES];
}
@end
