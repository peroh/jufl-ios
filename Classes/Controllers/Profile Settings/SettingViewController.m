//
//  SettingViewController.m
//  JUFL
//
//  Created by Rakesh Lohan on 29/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableViewCell.h"
#import "UserModel.h"
#import "AppDelegate.h"
#import "ImageAdjustViewController.h"
#import "ImageCropViewController.h"
#import "UIImage+ImageCompress.h"
#import "NotificationPageViewController.h"
#import "Mixpanel.h"
#import "AboutAppViewController.h"
#import "TermsViewController.h"
#import "TutorialViewController.h"

#define kEdit @"Edit"
#define kSave @"Save"

static NSString *cellIdentifier = @"SettingTableViewCell";

@interface SettingViewController () <ImageCropViewControllerDelegate,MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) UIImage *originalImage;
@property (nonatomic, strong) NSDictionary *notificationSettingsDict;

- (IBAction)backButtonClicked:(UIButton *)sender;
- (IBAction)editButtonClicked:(UIButton *)sender;
@end

@implementation SettingViewController
{
    NSArray *sectionIndex;
    NSArray *index1Titles;
    NSArray *index3Titles;
    NSArray *index2Titles;
    UserModel *user;
    BOOL save;
    BOOL notificationClicked;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self initializeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [Utils createBackGroundQueue:^{
        [self fetchNotificationSettings];
    }];
}
#pragma mark-MyFunctions
-(void)initializeView
{
    notificationClicked=YES;
    [self.editButton setTitle:kEdit forState:UIControlStateNormal];
    save=NO;
    user=[[UserModel alloc]initWithUserTable:[UserModel currentUser]];
    //firstName=user.firstName;
    // lastName=user.lastName;
    sectionIndex=[[NSArray alloc]initWithObjects:@"ACCOUNT",@"NOTIFICATIONS",@"APP", nil];
    index1Titles=[[NSArray alloc]initWithObjects:@"Firstname", @"Lastname", @"Profile Picture", nil];
    index3Titles=[[NSArray alloc]initWithObjects:@"Tutorial", @"About App", @"Terms & Conditions", @"Privacy Policy",@"Share App",@"Contact Us",@"Log Out", nil];
    index2Titles=[[NSArray alloc]initWithObjects:@"Notifications", nil];
    [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
}

- (void)fetchNotificationSettings {
    [EventModel notificationDetail:^(BOOL success,NSDictionary *dictionary, NSError *error) {
        if(success)
        {
            self.notificationSettingsDict = dictionary;
        }
    }];
}

-(void)updateOnServer
{
    NSDictionary *params = @{kFirstName:user.firstName, kLastName:user.lastName};
    if (self.originalImage) {
        [UserModel updateUserProfileWithParameters:params andImage:self.originalImage completion:^(BOOL success, UserModel *currentUser, NSString *otp, NSError *error) {
            if (success) {
                [CoreDataHandler saveUserDataWithModel:currentUser];
            }
        }];
    }
    else {
        [UserModel updateUserProfileWithParameters:params completion:^(BOOL success, UserModel *currentUser, NSString *otp, NSError *error) {
            if (success) {
                [CoreDataHandler saveUserDataWithModel:currentUser];
            }
        }];
    }
}

- (void)goToNotificationsSettings {
    NotificationPageViewController *notificationPageViewController=[[NotificationPageViewController alloc]initWithDictionary:self.notificationSettingsDict];
    [self.navigationController pushViewController:notificationPageViewController animated:YES];
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

-(void)share
{
    NSString *textToShare = @"I’m catching up with friends on Jufl. Check out the iPhone app if you want to join us!";
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/jufl/id1040129321?ls=1&mt=8"];
    
    UIActivityViewController *activityViewController =[[UIActivityViewController alloc] initWithActivityItems:@[textToShare, url]applicationActivities:nil];
//    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
//                                   UIActivityTypeCopyToPasteboard,
//                                   UIActivityTypePrint,
//                                   UIActivityTypeAssignToContact,
//                                   UIActivityTypeSaveToCameraRoll,
//                                   UIActivityTypeAddToReadingList,
//                                   UIActivityTypePostToFlickr,
//                                   UIActivityTypePostToVimeo];
//    
//    activityViewController.excludedActivityTypes = excludeActivities;
    [self.navigationController presentViewController:activityViewController
                                            animated:YES
                                          completion:^{
                                             // [self.navigationController popViewControllerAnimated:YES];
                                          }];
}

- (void)logoutUser {
    [[Utils sharedInstance]openActionSheetWithTitle:@"Are you sure you want to log out?" buttons:@[@"Log Out"] completion:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [UserModel logoutUserWithParameters:@{} completion:^(BOOL success, NSDictionary *response, NSError *error) {
                if (success) {
                    NSDate *loginDate=[UserDefaluts valueForKey:kLoginTime];
                    NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:loginDate];
                    NSNumber *minutes=[NSNumber numberWithUnsignedLong:secondsBetween/60];
                    [[Mixpanel sharedInstance] track:@"LoginTime" properties:@{@"Minutes":minutes}];
                    
                    [UserDefaluts removeObjectForKey:kCurrentUserID];
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
                    [[UIApplication sharedApplication] cancelAllLocalNotifications];
                    [SharedClass sharedInstance].currentEvent = [[EventModel alloc]init];
                    [[CoreDataConfiguration sharedInstance] clearCoreDataBase];
                    [appDelegate setRootForApp];
                }
            }];
        }
    }];
    
}
- (void)openImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    [[Utils sharedInstance] openImagePickerController:sourceType isVideo:NO inViewController:self completion:^(UIImagePickerController *controller, NSDictionary *info) {
        UIImage *img = info[UIImagePickerControllerOriginalImage];
        _originalImage = [img compressImage:img];
        [controller dismissViewControllerAnimated:NO completion:nil];
        
        //        ImageAdjustViewController *imageCropVC = [[ImageAdjustViewController alloc] initWithImage:img cropMode:ImageCropModeCircle];
        ImageAdjustViewController *imageCropVC = [[ImageAdjustViewController alloc] initWithImage:_originalImage cropMode:ImageCropModeCircle];
        imageCropVC.delegate = self;
        [self.navigationController pushViewController:imageCropVC animated:NO];
        
    } cancel:^{
        
    }];
}

- (void)showTutorial {
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:kIsWatchTutorial];
    TutorialViewController *tutorialViewController = [[TutorialViewController alloc]initWithViewMode:TutorialViewModeSettings];
//    [self.navigationController pushViewController:tutorialViewController animated:YES];
    tutorialViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:tutorialViewController animated:YES completion:nil];
}

- (void)emailComposer
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        //[composeViewController setToRecipients:@[@"support@jufl.io"]];
        [composeViewController setToRecipients:@[@"support@jufl.io"]];
        [composeViewController setSubject:@"Jufl Support Request"];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }else{
        [[Utils sharedInstance]openAlertViewWithTitle:kTitle message:@"Please configure from device settings." buttons:@[@"Ok", @"Settings"] completion:^(UIAlertView *alert, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:"]];
            }
        }];

    }
}

#pragma mark - MailComposerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [sectionIndex count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [[UIScreen mainScreen] bounds].size.height/8;
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionIndex objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = Rgb2UIColor(170, 170, 170);
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    header.textLabel.font = [UIFont fontWithName:@"ProximaNova-SemiBold" size:12];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return [index1Titles count];
            break;
            
        case 1:
            return [index2Titles count];
            break;
            
        case 2:
            return [index3Titles count];
            break;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell.forwardButton setHidden:NO];
    [cell.profileImageView setHidden:YES];
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.bounds.size.width/2;
    cell.profileImageView.layer.masksToBounds = YES;
    cell.textField.delegate=self;
    [cell.textField setHidden:YES];
    [cell.textField setTextColor:Rgb2UIColor(97, 97, 97)];
    cell.textField.font = [UIFont fontWithName:@"ProximaNova-Light" size:15];
    cell.textLabel.font=[UIFont fontWithName:@"ProximaNova-Light" size:15];
    [cell.textLabel setTextColor:Rgb2UIColor(97, 97, 97)];
    
    if (indexPath.section==0) {
        [cell.forwardButton setHidden:YES];
        cell.textLabel.text = [index1Titles objectAtIndex:indexPath.row];
        if ([cell.textLabel.text isEqualToString:@"Firstname"] || [cell.textLabel.text isEqualToString:@"Lastname"]) {
            [cell.textField setHidden:NO];
            cell.textField.userInteractionEnabled=NO;
            if ([cell.textLabel.text isEqualToString:@"Firstname"]) {
                [cell.textField setTag:1];
                cell.textField.text=user.firstName;
                if (cell.textField.text) {
                    user.firstName=cell.textField.text;
                }
            }
            else if(user && [cell.textLabel.text isEqualToString:@"Lastname"])
            {
                [cell.textField setTag:2];
                cell.textField.text=user.lastName;
                if (cell.textField.text) {
                    user.lastName=cell.textField.text;
                }
            }
            else
            {
                [cell.textField setPlaceholder:cell.textLabel.text];
            }
            if (save)
            {
                cell.textField.userInteractionEnabled=YES;
            }
        }
        if ([cell.textLabel.text isEqualToString:@"Profile Picture"])
        {
            [cell.profileImageView setHidden:NO];
            if (![self.editButton.titleLabel.text isEqualToString:kSave] && !self.originalImage)
            {
                [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:user.image] placeholderImage:imgSync completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    cell.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
                    if (image) {
                        
                        cell.profileImageView.image = image;
                    }
                    else {
                        cell.profileImageView.image = [UIImage imageNamed:@"profilePlaceholder"];
                    }
                    
                } animation:NaveenImageViewOptionsNone];
            }
            else if(self.originalImage)
            {
                cell.profileImageView.image=nil;
                cell.profileImageView.image=_originalImage;
            }
        }
    }
    
    if (indexPath.section==1) {
        cell.textLabel.text = [index2Titles objectAtIndex:indexPath.row];
    }
    
    if (indexPath.section==2) {
        cell.textLabel.text = [index3Titles objectAtIndex:indexPath.row];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.editButton.titleLabel.text isEqualToString:kSave])
    {
        if (indexPath.section == 0) {
            if (indexPath.row == 2) {
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
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if (notificationClicked) {
                UIRemoteNotificationType types = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
                if (types) {
                    notificationClicked=NO;
                    [self goToNotificationsSettings];
                }else{
                    [[Utils sharedInstance]openAlertViewWithTitle:@"Notification turned off" message:@"Turn on notifications from device settings." buttons:@[@"Ok", @"Settings"] completion:^(UIAlertView *alert, NSInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }
                    }];
                }
            }else
            {
                notificationClicked=YES;
            }
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self showTutorial];
        }
        if (indexPath.row == 1) {
            AboutAppViewController *aboutAppViewController=[[AboutAppViewController alloc]init];
            [self.navigationController pushViewController:aboutAppViewController animated:YES];
        }
        if (indexPath.row == 2) {
            TermsViewController *termsViewController=[[TermsViewController alloc]initWithMode:TermsMode];
            [self.navigationController pushViewController:termsViewController animated:YES];
        }

        if (indexPath.row == 3) {
            TermsViewController *termsViewController=[[TermsViewController alloc]initWithMode:PolicyMode];
            [self.navigationController pushViewController:termsViewController animated:YES];
        }

        if (indexPath.row == 4) {
            [self share];
        }
        
        if (indexPath.row == 5) {
            [self emailComposer];
        }
        
        if (indexPath.row == 6) {
            [self logoutUser];
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
#pragma mark - TextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag==1) {
        user.firstName=textField.text;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (textField.tag==2)
    {
        user.lastName=textField.text;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    // [self.tableView reloadData];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= 25 && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else
    {
        return YES;
    }
}

#pragma mark - ImageCropViewControllerDelegate
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
    self.originalImage = croppedImage;
    [self.tableView reloadData];
}

#pragma mark-Action
- (IBAction)backButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editButtonClicked:(UIButton *)sender {
    if ([self.editButton.titleLabel.text isEqualToString:kEdit]) {
        [self.editButton setTitle:kSave forState:UIControlStateNormal];
        save=YES;
        [self.tableView reloadData];
    }
    else if ([self.editButton.titleLabel.text isEqualToString:kSave]){
        save=NO;
        [self.tableView reloadData];
        [self.editButton setTitle:kEdit forState:UIControlStateNormal];
        [self updateOnServer];
    }
}
@end
