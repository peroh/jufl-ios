//
//  ProfileImageViewController.m
//  JUFL
//
//  Created by Ankur on 24/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "ProfileImageViewController.h"

@interface ProfileImageViewController ()
@property (nonatomic, strong) UserModel *user;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *flagButton;
@end

@implementation ProfileImageViewController

- (instancetype)initWithUser:(UserModel *)user {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.user = user;
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
    self.flagButton.enabled = !self.user.isImageFlagged;
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.user.image] placeholderImage:imgSync completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
        if (image) {
            
            
        }
        else {
            self.profileImageView.image = [UIImage imageNamed:@"profilePlaceholder"];
        }
        
    } animation:NaveenImageViewOptionsNone];
}

-(void)flagUserImage
{
    [UserModel flagUserWithParameters:@{kFriendId:self.user.userId} completion:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            self.user.isImageFlagged = !self.user.isImageFlagged;
            self.flagButton.enabled = !self.user.isImageFlagged;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flag Image"
                                                            message:@"Image flagged successfully."
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}

#pragma mark - Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 1) {
        [self flagUserImage];
    }
}

#pragma mark - IBAction
- (IBAction)closeClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)flagClicked:(id)sender {
    if (!self.user.isImageFlagged) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flag Image"
                                                        message:@"Are you sure you want to flag this image as inappropriate? You cannot undo this action."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Ok",nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flag Image"
                                                        message:@"Image already flagged."
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
