//
//  ProfileViewController.m
//  JUFL
//
//  Created by Ankur Arya on 09/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "ProfileViewController.h"
#import "ContactAccessViewController.h"
#import "ImageAdjustViewController.h"
#import "ImageCropViewController.h"
#import "UIImage+ImageCompress.h"
#import "AppDelegate.h"
#import "Mixpanel.h"

#define ACCEPTABLE_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 1234567890"
#define kMaxLength 20

@interface ProfileViewController ()<UIGestureRecognizerDelegate, UITextFieldDelegate, ImageCropViewControllerDelegate>
@property (nonatomic, strong) UserModel *currentUser;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong,nonatomic) UIImage *originalImage;
@end

@implementation ProfileViewController

#pragma mark - View life cycle

- (instancetype)initWithUser:(UserModel *)user {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.currentUser = user;
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    RESIGN_KEYBOARD;
}


#pragma mark - My functions
- (void)initializeView {
    if (self.currentUser) {
        self.firstNameTextField.text = self.currentUser.firstName;
        self.lastNameTextField.text = self.currentUser.lastName;
        if ([NRValidation isValidString:self.currentUser.firstName] && [NRValidation isValidString:self.currentUser.lastName]) {
            self.nextButton.enabled = YES;
        }
        
        self.nextButton.backgroundColor = Rgb2UIColor(33, 205, 182);
        
        if ([NRValidation isValidString:self.currentUser.image]) {
            [self.uploadButton setTitle:@"" forState:UIControlStateNormal];
            [self.userImageView sd_setImageWithURL:[NSURL URLWithString:self.currentUser.image] placeholderImage:imgSync completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                self.userImageView.contentMode = UIViewContentModeScaleAspectFit;
                if (image) {
                    
                    self.originalImage = image;
                }
                else {
                    self.userImageView.image = [UIImage imageNamed:@"profilePlaceholder"];
                }
                
            } animation:NaveenImageViewOptionsNone];
        }
    }
    [self setUpTextField:self.firstNameTextField];
    [self setUpTextField:self.lastNameTextField];
    self.userImageView.layer.cornerRadius = 94.5;
    self.userImageView.clipsToBounds = YES;
}

- (void)setUpTextField :(UITextField *)textField {
    [textField paddingTextField:textField :15];
    textField.layer.borderWidth = 1.5;
    textField.layer.borderWidth = 1.5;
    textField.layer.borderColor = Rgb2UIColor(170, 170, 170).CGColor;
}
- (void)goToContactAccess {
    
    NSLocale *countryLocale = [NSLocale currentLocale];
    NSString *countryCode = [countryLocale objectForKey:NSLocaleCountryCode];
    NSString *country = [countryLocale displayNameForKey:NSLocaleCountryCode value:countryCode];
    
    [[Mixpanel sharedInstance] track:@"User" properties:@{@"Phone number" : self.currentUser.mobileNo, @"UserId" : self.currentUser.userId, @"Country" : country}];
     [appDelegate setRootForApp];
//    
//    ContactAccessViewController *contactAccessViewController = [[ContactAccessViewController alloc]initWithNibName:NSStringFromClass([ContactAccessViewController class]) bundle:nil];
//    [self.navigationController pushViewController:contactAccessViewController animated:YES];
}

- (void) selectImageFromCamera{
    
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
#if TARGET_IPHONE_SIMULATOR
        [self openImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
#endif
        
        [Utils showAlertView:kError message:KNoCameraFound delegate:self cancelButtonTitle:kAlertOK otherButtonTitles:nil];
    }
    else{
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusAuthorized:
            case AVAuthorizationStatusRestricted:
            case AVAuthorizationStatusNotDetermined:
                [self openImagePicker:UIImagePickerControllerSourceTypeCamera];
                break;
                
            case AVAuthorizationStatusDenied:
                [Utils showAlertView:kError message:KErrorCameraPermission delegate:self cancelButtonTitle:kAlertOK otherButtonTitles:nil];
                break;
                
            default:
                break;
        }
    }
}


- (void)openImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    [[Utils sharedInstance] openImagePickerController:sourceType isVideo:NO inViewController:self completion:^(UIImagePickerController *controller, NSDictionary *info) {
        UIImage *img = info[UIImagePickerControllerOriginalImage];
        _originalImage = [img compressImage:img];
        [controller dismissViewControllerAnimated:NO completion:nil];
        ImageAdjustViewController *imageCropVC = [[ImageAdjustViewController alloc] initWithImage:_originalImage cropMode:ImageCropModeCircle];
        imageCropVC.delegate = self;
        [self.navigationController pushViewController:imageCropVC animated:YES];
        
    } cancel:^{
        
    }];
}


- (void)updateUserProfile {
    NSDictionary *params = @{kFirstName:self.firstNameTextField.text, kLastName:self.lastNameTextField.text};
    if (self.originalImage) {
        [UserModel updateUserProfileWithParameters:params andImage:self.originalImage completion:^(BOOL success, UserModel *currentUser, NSString *otp, NSError *error) {
            if (success) {
                [CoreDataHandler saveUserDataWithModel:currentUser];
                [self goToContactAccess];
            }
        }];
    }
    else {
    [UserModel updateUserProfileWithParameters:params completion:^(BOOL success, UserModel *currentUser, NSString *otp, NSError *error) {
        if (success) {
            [CoreDataHandler saveUserDataWithModel:currentUser];
            [self goToContactAccess];
        }
    }];
    }
}
#pragma mark - IBActions
- (IBAction)nextClicked:(id)sender {
    [self updateUserProfile];
}
- (IBAction)uploadPhotoClicked:(id)sender {
    [[Utils sharedInstance] openActionSheetWithTitle:kImageTitle buttons:@[kSelectFromCamera, kSelectFromImageGallery]
                                          completion:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                              
                                              switch (buttonIndex)
                                              {
                                                  case 0:
                                                      [self selectImageFromCamera];
                                                      break;
                                                      
                                                  case 1:
                                                      [self openImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                                                      break;
                                                      
                                                  default:
                                                      break;
                                              }
                                          }];

}

#pragma mark - Delegates
#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

#pragma mark - ImageCropViewControllerDelegate -

- (void)imageCropViewControllerDidCancelCrop:(ImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropViewController:(ImageCropViewController *)controller didCropImage:(UIImage *)croppedImage
{
    [self.navigationController popViewControllerAnimated:YES];
    [self prepareWithOriginalImage:_originalImage andCroppedImage:croppedImage];
}

- (void)prepareWithOriginalImage:(UIImage *)originalImage andCroppedImage:(UIImage *)croppedImage
{
    self.userImageView.image = croppedImage;
    self.originalImage = croppedImage;
    [self.uploadButton setTitle:@"" forState:UIControlStateNormal];
    
    
}

#pragma mark - TextField Delegate
#pragma mark - Textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.firstNameTextField]) {
        [self.lastNameTextField becomeFirstResponder];
    }
    else {
        RESIGN_KEYBOARD
        [self updateUserProfile];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.firstNameTextField.text.length > 0 && self.lastNameTextField.text.length > 0) {
        self.nextButton.backgroundColor = Rgb2UIColor(33, 205, 182);
        self.nextButton.enabled = YES;
    }
    else {
        self.nextButton.backgroundColor = Rgb2UIColorWithAlpha(97, 97, 97, 0.4);
        self.nextButton.enabled = NO;
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length == 0 && [string isEqualToString:@" "]) {
        return NO;
    }
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSString *currentString = @"";
    if([string isEqualToString:@""])
    {
        if([textField.text length]>0)
        {
            currentString = [textField.text substringToIndex:textField.text.length-1];
        }
    }
    else
        currentString = [textField.text stringByAppendingString:string];
    
    if(textField== self.firstNameTextField)
    {
        if((currentString.length>0)&&(self.lastNameTextField.text.length>0))
        {
            self.nextButton.backgroundColor = Rgb2UIColor(33, 205, 182);
            self.nextButton.enabled = YES;
        }
        else{
            self.nextButton.backgroundColor = Rgb2UIColorWithAlpha(97, 97, 97, 0.4);
            self.nextButton.enabled = NO;
        }
    }
    else
    {
        if((currentString.length>0)&&(self.firstNameTextField.text.length>0))
        {
            self.nextButton.backgroundColor = Rgb2UIColor(33, 205, 182);
            self.nextButton.enabled = YES;
        }
        else{
            self.nextButton.backgroundColor = Rgb2UIColorWithAlpha(97, 97, 97, 0.4);
            self.nextButton.enabled = NO;
        }
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered] && newLength <= kMaxLength;
    
//    return newLength <= kMaxLength;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    RESIGN_KEYBOARD
}

// block Menucontroller
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    }];
    return [super canPerformAction:action withSender:sender];
}
@end
