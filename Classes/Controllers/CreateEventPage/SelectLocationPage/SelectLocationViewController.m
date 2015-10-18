//
//  SelectLocationViewController.m
//  JUFL
//
//  Created by Ankur on 14/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "SelectLocationViewController.h"
#import "LocationTableViewCell.h"
#import "MyCustomAnnotation.h"
#import "CurrentPin.h"
#import "MKMapView+ZoomLevel.h"
#import "FriendsViewController.h"
#import "EventCreatedViewController.h"
#import "IQKeyboardManager.h"
#import "Mixpanel.h"
#import "AppDelegate.h"

#define MapPinImageName @"annotation"
#define LatitudeDelta 0.02
#define LongitudeDelta 0.02

static NSString *cellIdentifier = @"LocationTableViewCell";
static NSString *autocompleteCellIdentifier = @"autocompleteCellIdentifier";

@interface SelectLocationViewController ()<UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate> {
    BOOL isObserverAdded;
    BOOL shouldShowOldLocation;
    BOOL isEventLocationOld;
    BOOL shouldFetchLocation;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *autocompleteTableHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *autocompleteTableView;
@property (nonatomic, strong) NSMutableArray *autocompleteArray;
@property (weak, nonatomic) IBOutlet UILabel *currentLocationLabel;
@property (weak, nonatomic) IBOutlet MKMapView *locationMapView;
@property (nonatomic, strong) NSMutableArray *locationArray;
@property (weak, nonatomic) IBOutlet UITableView *locationTableView;
@property (strong, nonatomic) NSMutableString *selectedAddress;
@property (strong, nonatomic) NSString *selectedName;
@property (strong, nonatomic) NSString *selectedLocationId;
@property (nonatomic, strong) EventModel *currentEvent;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (nonatomic, assign) EventViewMode viewMode;
@property (weak, nonatomic) IBOutlet UIButton *crossButton;
@end

@implementation SelectLocationViewController

#pragma mark - View life cycle
- (instancetype)initWithEvent:(EventModel *)event andViewMode:(EventViewMode)mode {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.currentEvent = event;
        self.viewMode = mode;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager]setEnableAutoToolbar:NO];
    if (self.viewMode == EventViewModeEdit) {
        shouldShowOldLocation = YES;
    }
    else {
        shouldShowOldLocation = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager]setEnableAutoToolbar:YES];
}

#pragma mark - My functions
- (void)initializeView {
    [self.locationTableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [self.autocompleteTableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.locationMapView.showsUserLocation = YES;
    self.locationTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.autocompleteTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.selectedAddress = [[NSMutableString alloc]init];
    self.autocompleteArray = [[NSMutableArray alloc]init];
    [self.locationMapView.userLocation addObserver:self
                                        forKeyPath:@"location"
                                           options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                           context:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self toggleNextButtonState:NO];
    self.autocompleteTableView.hidden = YES;
    isObserverAdded = YES;
    [self addTapGestureToMapView];
    [self.searchTextField addImageInLeft:[UIImage imageNamed:@"searchIcon"] andImageInRight:nil];
    if (self.viewMode == EventViewModeEdit) {
        isEventLocationOld = YES;
    }
    else {
        isEventLocationOld = NO;
    }
    self.crossButton.hidden = YES;
    [self performSelector:@selector(getLocations) withObject:self afterDelay:0.1];
}

-(NSString *)randomStringWithLength: (int) len {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    CGFloat height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    self.autocompleteTableHeightConstraint.constant = ScreenHeight-height-120;
    [self.view layoutIfNeeded];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    //    CGFloat height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    self.autocompleteTableHeightConstraint.constant = ScreenHeight-120;
    [self.view layoutIfNeeded];
}


- (void)toggleNextButtonState:(BOOL)isEnabled {
    self.nextButton.enabled = isEnabled;
    self.nextButton.backgroundColor = Rgb2UIColorWithAlpha(97, 97, 97, 0.4);
    if (isEnabled) {
        self.nextButton.backgroundColor = Rgb2UIColor(33, 205, 182);
    }
    [self changeButtonTitle];
    
}

#pragma mark - Gesture - Method -

- (void)addTapGestureToMapView{
    
    UILongPressGestureRecognizer *tapGesture = [[UILongPressGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(longPressToGetLocation:)];
    tapGesture.delegate = self;
    tapGesture.allowableMovement = 0;
    [self.locationMapView addGestureRecognizer:tapGesture];
    _locationMapView.userInteractionEnabled = YES;
}

- (void)longPressToGetLocation:(UIGestureRecognizer *)gestureRecognizer
{
    RESIGN_KEYBOARD
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [gestureRecognizer locationInView:_locationMapView];
        CLLocationCoordinate2D location = [_locationMapView convertPoint:touchPoint
                                                    toCoordinateFromView:_locationMapView];
        
        if ([self getSelectedLocationArray].count>0) {
            [self deselectPreviousSelectedLocation];
        }
        self.currentLocation = [[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
        [self changeButtonTitle];
        [self reverseGeocoding];
    }
}

-(NSArray *)getSelectedLocationArray {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isLocationSelected == %@", [NSNumber numberWithBool:YES]];
    NSArray *selectedLocation = [self.locationArray filteredArrayUsingPredicate:predicate];
    return selectedLocation;
}

-(LocationModel *)getSelectedLocation {
    LocationModel *selectedLocation = [[LocationModel alloc]init];
    if ([self getSelectedLocationArray].count > 0) {
        selectedLocation = [[self getSelectedLocationArray] lastObject];
        NSString *eventLocationName = [[selectedLocation.name componentsSeparatedByString:@". - "] lastObject];
        selectedLocation.address = selectedLocation.address?selectedLocation.address:eventLocationName;
    }
    else if (isEventLocationOld){
        selectedLocation = self.currentEvent.location;
    }
    else {
        selectedLocation.name = self.selectedName;
        selectedLocation.address = self.selectedAddress;
        selectedLocation.locationId = self.selectedLocationId;
        selectedLocation.coordinate = self.currentLocation.coordinate;
    }
    
    return selectedLocation;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([self.locationMapView showsUserLocation]) {
        if (self.locationMapView.userLocation) {
            [self.locationMapView setCenterCoordinate:self.locationMapView.userLocation.location.coordinate zoomLevel:15 animated:YES];        // and of course you can use here old and new location values
            
            [Utils startActivityIndicatorWithMessage:@"Getting location"];
            self.currentLocation = [[CLLocation alloc]initWithLatitude:self.locationMapView.userLocation.coordinate.latitude longitude:self.locationMapView.userLocation.coordinate.longitude];
            [self reverseGeocoding];
            [self toggleNextButtonState:YES];
            if (self.locationArray.count == 0 && shouldFetchLocation) {
                [self performSelector:@selector(getLocations) withObject:self afterDelay:0.2];
            }
            [self.locationMapView.userLocation removeObserver:self forKeyPath:@"location"];
            isObserverAdded = NO;
        }
        else {
            [TSMessage showNotificationInViewController:self title:@"Couldn't find location" subtitle:@"Check your location services." type:TSMessageNotificationTypeMessage];
        }
    }
}

- (void)getLocations {
    if ([Location  isLocationServiceOn]) {
        shouldFetchLocation = NO;
        NSDictionary *parameters = @{@"ll":kFourSquareLatLong,@"client_id":kFourSquareClientID, @"client_secret":kFourSquareClientSecret, kFourSquareVersion:kFourSquareVersionIdentifier,kFourSquareVenuePhotos:@"1", KRadiusKey : kRadius};
        
        [LocationModel getLocationFromFourSquareWithParams:parameters completion:^(NSArray *locations, NSError *error) {
            [Utils createMainQueue:^{
                if (locations.count > 0) {
                    
                    self.locationArray = [NSMutableArray arrayWithArray:locations];
                    [self removeAnnotations];
//                    [self.locationMapView removeAnnotations:self.locationMapView.annotations];
                    [self.locationMapView addAnnotations:[self getAnnoArray:self.locationArray]];
                    
                    //        [self.locationMapView showAnnotations:[self getAnnoArray:self.locationArray] animated:YES];
                    [self.locationTableView reloadData];
                    [self.locationTableView setContentOffset:CGPointZero animated:YES];
                }
                else {
                    
                }
            }];
        }];
    }
    else {
        shouldFetchLocation = YES;
        [TSMessage showNotificationInViewController:self title:@"Couldn't find location" subtitle:@"Check your location services." type:TSMessageNotificationTypeMessage];
    }
}

- (void)removeAnnotations {
    for (id<MKAnnotation> anno in  self.locationMapView.annotations) {
        if (![anno isKindOfClass:[CurrentPin class]]) {
            [self.locationMapView removeAnnotation:anno];
        }
    }
}

- (void)getSearchedPlaces:(LocationModel *)selectedLocation {
    if ([Location  isLocationServiceOn]) {
        NSString *latLongString = [NSString stringWithFormat:@"%.10f,%.10f",selectedLocation.coordinate.latitude,selectedLocation.coordinate.longitude];
        
        NSDictionary *parameters = @{@"ll":latLongString,@"client_id":kFourSquareClientID, @"client_secret":kFourSquareClientSecret, kFourSquareVersion:kFourSquareVersionIdentifier,kFourSquareVenuePhotos:@"1", KRadiusKey : kRadius, @"query":selectedLocation.name};
        
        [LocationModel getLocationFromFourSquareWithParams:parameters completion:^(NSArray *locations, NSError *error) {
            [Utils createMainQueue:^{
                if (locations.count > 0) {
                    self.locationArray = [NSMutableArray arrayWithArray:locations];
                    [self.locationMapView removeAnnotations:self.locationMapView.annotations];
                    //                [self.locationMapView addAnnotations:[self getAnnoArray:self.locationArray]];
                    
                    [self.locationMapView showAnnotations:[self getAnnoArray:self.locationArray] animated:YES];
                    
                    [self.locationTableView reloadData];
                    [self.locationTableView setContentOffset:CGPointZero animated:YES];
                    [self selectFirstLocation];
                }
                else {
                    
                }
            }];
        }];
    }
    else {
        [TSMessage showNotificationInViewController:self title:@"Couldn't find location" subtitle:@"Check your location services." type:TSMessageNotificationTypeMessage];
    }
    
}

- (void)selectLocationAtIndex:(UIButton *)sender {
    
    if ([self getSelectedLocationArray].count>0) {
        [self deselectPreviousSelectedLocation];
    }
    
    sender.selected = !sender.selected;
    LocationModel *location = self.locationArray[sender.tag];
    location.isLocationSelected = sender.selected;
    [self.locationArray replaceObjectAtIndex:sender.tag withObject:location];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [self.locationTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    CLLocation *currentLocation = nil;
    NSString *pinTitle  = nil;
    if (sender.selected) {
        currentLocation = [[CLLocation alloc]initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        pinTitle = location.name;
        //        self.currentLocationLabel.text = location.address;
        self.searchTextField.placeholder = location.address;
    }
    else {
        currentLocation = [[CLLocation alloc]initWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
        pinTitle = self.selectedAddress;
        //        self.currentLocationLabel.text = self.selectedAddress;
        self.searchTextField.placeholder = self.selectedAddress;
    }
    
    [self changeButtonTitle];
    
    [self.locationMapView setCenterCoordinate:currentLocation.coordinate zoomLevel:15 animated:YES];
    [self addAnnotationOnMap:currentLocation title:pinTitle];
}

- (void)changeButtonTitle {
    double distance = [[Location sharedInstance]getDistanceBetweenTwoCordinates:self.currentLocation.coordinate.latitude longitude1:self.currentLocation.coordinate.longitude latitude2:self.locationMapView.userLocation.location.coordinate.latitude longitude2:self.locationMapView.userLocation.location.coordinate.longitude];
    if (shouldShowOldLocation) {
        [self.nextButton setTitle:@"Use same location" forState:UIControlStateNormal];
    }
    else {
        if ([self getSelectedLocationArray].count || distance >= 10) {
            [self.nextButton setTitle:@"Use this location" forState:UIControlStateNormal];
        }
        else {
            [self.nextButton setTitle:@"Use my location" forState:UIControlStateNormal];
        }
    }
}

- (void)deselectPreviousSelectedLocation {
    LocationModel *location = [[self getSelectedLocationArray] lastObject];
    NSUInteger index = [self.locationArray indexOfObject:location];
    
    location.isLocationSelected = NO;
    
    [self.locationArray replaceObjectAtIndex:index withObject:location];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.locationTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    
}

- (void)reverseGeocoding
{
    if (self.currentLocation) {
        [self addAnnotationOnMap:self.currentLocation title:self.selectedAddress];
        [[Location sharedInstance] getAddressInfoFromLocationLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude completionBlock:^(CLPlacemark *placeMark) {
            [self getAddressFromPlacemark : placeMark];
            //            if (self.viewMode == EventViewModeCreate) {
            //            [self addAnnotationOnMap:self.currentLocation title:self.selectedAddress];
            if (shouldShowOldLocation) {
                
                [self showEventLocation];
            }
            //            }
            //            else {
            
            
            //            }
            
        }];
    }
}


-(void)showEventLocation {
    CLLocation *eventLocation = [[CLLocation alloc]initWithLatitude:self.currentEvent.location.coordinate.latitude longitude:self.currentEvent.location.coordinate.longitude];
    [self addAnnotationOnMap:eventLocation title:self.currentEvent.location.address];
    self.searchTextField.placeholder = self.currentEvent.location.address;
    [self changeButtonTitle];
    shouldShowOldLocation = NO;
}
- (void)getAddressFromPlacemark : (CLPlacemark *)placeMark{
    
    self.selectedLocationId = [self randomStringWithLength:15];
    self.selectedName =  placeMark.thoroughfare?placeMark.thoroughfare:placeMark.locality;
    
    [_selectedAddress setString:@""];
    
    if (placeMark.subThoroughfare)
    {
        [_selectedAddress appendString: placeMark.subThoroughfare] ;
        [_selectedAddress appendString : @","];
    }
    
    if (placeMark.thoroughfare) {
        [_selectedAddress appendString : placeMark.thoroughfare];
        [_selectedAddress appendString : @","];
    }
    
    if (placeMark.locality){
        [_selectedAddress appendString : placeMark.locality];
        [_selectedAddress appendString : @","];
    }
    
    if (placeMark.administrativeArea){
        [_selectedAddress appendString : placeMark.administrativeArea];
        [_selectedAddress appendString : @","];
    }
    
    if (placeMark.country){
        [_selectedAddress appendString : placeMark.country];
        [_selectedAddress appendString : @","];
        
    }
    
    if (placeMark.postalCode){
        [_selectedAddress appendString : placeMark.postalCode];
    }
    
    if (_selectedAddress) {
        //        self.currentLocationLabel.text = _selectedAddress;
        self.searchTextField.placeholder = _selectedAddress;
    }
    
}

-(void)updateEventDetails {
    NSDictionary *eventInfo = [EventModel getDictionaryFromModel:self.currentEvent addLocation:YES];
    [EventModel updateEventWithParameters:eventInfo completion:^(BOOL success, EventModel *event, NSError *error) {
        [Utils createMainQueue:^{
            if (success) {
                [self goToSuccessPage];
            }
        }];
    }];
}

- (void)goToSuccessPage {
    //    if (self.viewMode == FinishViewModeEventInvite) {
    [SharedClass sharedInstance].currentEvent = [[EventModel alloc]init];
    
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [self performSelector:@selector(showToast) withObject:nil afterDelay:0.1];
    
    
    /*EventCreatedViewController *eventCreatedViewController = [[EventCreatedViewController alloc]initWithEventModel:self.currentEvent andFriends:@""]; // need to change number of friends
     eventCreatedViewController.hidesBottomBarWhenPushed = YES;
     [self.navigationController pushViewController:eventCreatedViewController animated:YES];*/
}

- (void)showToast {
    [TSMessage showNotificationInViewController:appDelegate.window.rootViewController title:[NSString stringWithFormat:@"You have edited the details of %@",self.currentEvent.name] subtitle:nil type:TSMessageNotificationTypeMessage];
}

- (void)autoComplete:(NSString *)text {
    [LocationModel autocompleteFourSquarePlacesWithText:text withCompletion:^(NSArray *locations, NSError *error) {
        [Utils createMainQueue:^{
            if (locations.count) {
                self.autocompleteArray = [NSMutableArray arrayWithArray:locations];
                [self.autocompleteTableView reloadData];
                self.autocompleteTableView.hidden = NO;
            }
            else {
                self.autocompleteTableView.hidden = YES;
            }
            
        }];
    }];
}

-(void)selectFirstLocation {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = 0;
    [self selectLocationAtIndex:button];
}

- (void)searchVenue:(NSString *)text {
    NSDictionary *parameters = @{@"ll":kFourSquareLatLong,@"client_id":kFourSquareClientID, @"client_secret":kFourSquareClientSecret, kFourSquareVersion:kFourSquareVersionIdentifier,kFourSquareVenuePhotos:@"1", KRadiusKey : kRadius, @"intent":@"global", @"query":text};
    [LocationModel getSearchedLocationWithParams:parameters completion:^(NSArray *locations, NSError *error) {
        [Utils createMainQueue:^{
            self.autocompleteTableView.hidden = YES;
            if (locations.count > 0) {
                self.locationArray = [NSMutableArray arrayWithArray:locations];
                [self.locationMapView removeAnnotations:self.locationMapView.annotations];
                //            [self.locationMapView addAnnotations:[self getAnnoArray:self.locationArray]];
                [self.locationMapView showAnnotations:[self getAnnoArray:self.locationArray] animated:YES];
                //        [self.locationMapView showAnnotations:[self getAnnoArray:self.locationArray] animated:YES];
                
                [self.locationTableView reloadData];
                [self.locationTableView setContentOffset:CGPointZero animated:YES];
                [self selectFirstLocation];
            }
            else {
                
            }
        }];
        
    }];
}
#pragma mark - IBActions
- (IBAction)backClicked:(id)sender {
    if (isObserverAdded) {
        [self.locationMapView.userLocation removeObserver:self forKeyPath:@"location"];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextClicked:(id)sender {
    if ([self getSelectedLocation]) {
        self.currentEvent.location = [self getSelectedLocation];
    }
    if (self.currentEvent.location.address.length > 0 && self.currentEvent.location.locationId.length > 0) {
        if (self.viewMode == EventViewModeCreate) {
            NSString *city=[[NSString alloc]initWithFormat:@" "];
            NSString *country=[[NSString alloc]initWithFormat:@" "];
            if(self.currentEvent.location.city)
            {
                city=self.currentEvent.location.city;
            }
            if(self.currentEvent.location.country)
            {
                country=self.currentEvent.location.country;
            }
            [[Mixpanel sharedInstance] track:@"Location" properties:@{@"LocationName":self.currentEvent.location.name,@"City":city,@"Country":country}];
            
            FriendsViewController *friendsViewController = [[FriendsViewController alloc]initWithViewMode:FriendViewModeInviteUsers eventModel:self.currentEvent];
            [self.navigationController pushViewController:friendsViewController animated:YES];
        }
        else {
            [self updateEventDetails];
        }
    }
    else {
        [TSMessage showNotificationInViewController:self title:@"Couldn't find location" subtitle:@"Check your Internet and location services." type:TSMessageNotificationTypeMessage];
    }
    
}
- (IBAction)crossClicked:(id)sender {
    [[Utils sharedInstance]openAlertViewWithTitle:kTitle message:@"Current event data will be lost. Do you want to continue?" buttons:@[@"Cancel", @"Ok"] completion:^(UIAlertView *alert, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [SharedClass sharedInstance].currentEvent = [[EventModel alloc]init];
            self.currentEvent = [SharedClass sharedInstance].currentEvent;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)currentLocationClicked:(id)sender {
    self.searchTextField.text = @"";
    [self.locationMapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    self.currentLocation = self.locationMapView.userLocation.location;
    [self reverseGeocoding];
    isEventLocationOld = NO;
    if ([self getSelectedLocationArray].count) {
        [self deselectPreviousSelectedLocation];
    }
    [self changeButtonTitle];
    [self performSelector:@selector(getLocations) withObject:self afterDelay:0.1];
}

#pragma mark - Delegates
#pragma mark - Table Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.autocompleteTableView]) {
        return self.autocompleteArray.count;
    }
    return self.locationArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.autocompleteTableView]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:autocompleteCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:autocompleteCellIdentifier];
        }
        LocationModel *location =  (LocationModel*)self.autocompleteArray[indexPath.row];
        cell.textLabel.text = location.name;
        cell.detailTextLabel.text = location.address;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        LocationModel *location =  (LocationModel*)self.locationArray[indexPath.row];
        
        [cell setLocationData:location];
        cell.selectButton.tag = indexPath.row;
        [cell.selectButton addTarget:self action:@selector(selectLocationAtIndex:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

#pragma mark - Table delegate
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.autocompleteTableView]) {
        LocationModel *location =  (LocationModel*)self.autocompleteArray[indexPath.row];
        self.searchTextField.text = location.name.length > 29 ? [location.name substringToIndex:29]:location.name;
        self.autocompleteTableView.hidden = YES;
        [self getSearchedPlaces:location];
        RESIGN_KEYBOARD
    }
    else {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = indexPath.row;
        [self selectLocationAtIndex:btn];
    }
}
#pragma mark - Map View delegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    else if ([annotation isKindOfClass:[MyCustomAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MyCustomAnnotation *placeLocation = (MyCustomAnnotation *)annotation;
        
        MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:[MyCustomAnnotation reuseIdentifier]];
        
        pinView = placeLocation.annotationView;
        
        pinView.tag = [placeLocation.pinNumber integerValue]-1;
        
        pinView.canShowCallout = YES;
        
        return pinView;
    }
    if ([annotation isKindOfClass:[CurrentPin class]])
    {
        // Try to dequeue an existing pin view first.
        CurrentPin *placeLocation = (CurrentPin *)annotation;
        
        MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:[CurrentPin reuseIdentifier]];
        
        pinView = placeLocation.annotationView;
        
        
        pinView.canShowCallout = YES;
        UIImage *image = [UIImage imageNamed:MapPinImageName];
        pinView.centerOffset = CGPointMake(0, -image.size.height/ 2);
        pinView.image = image;
        
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[MyCustomAnnotation class]]) {
        MyCustomAnnotation *annotation =  (MyCustomAnnotation *)view.annotation;
        NSInteger selectedTag = annotation.tag;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = selectedTag;
        [self selectLocationAtIndex:button];
        [self.locationTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedTag inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    //    if ([view.annotation isKindOfClass:[MyCustomAnnotation class]]) {
    //         [self deselectPreviousSelectedLocation];
    //    }
    
}
- (void)addAnnotationOnMap : (CLLocation *)currentLocation title:(NSString *)title{
    
    CurrentPin *annotation = [[CurrentPin alloc] initWithTitle:title pinNumber:@"U" location:currentLocation.coordinate];
    
    for (CurrentPin *pin in self.locationMapView.annotations) {
        if ([pin isKindOfClass:[CurrentPin class]]) {
            [self.locationMapView removeAnnotation:pin];
            break;
            
        }
    }
    [_locationMapView showAnnotations:@[annotation] animated:YES];
    //    [_locationMapView addAnnotation:annotation];
    [Utils stopActivityIndicatorInView];
}


- (NSArray *)getAnnoArray:(NSArray *)locations {
    NSMutableArray *annoArray = [[NSMutableArray alloc]init];
    for (LocationModel *location in locations) {
        NSString *pinNumberString = [[location.name componentsSeparatedByString:@". -"] firstObject];
        MyCustomAnnotation *annotation = [[MyCustomAnnotation alloc] initWithTitle:location.name pinNumber:pinNumberString location:location.coordinate];
        annotation.tag = [pinNumberString integerValue]-1;
        [annoArray addObject:annotation];
    }
    
    return annoArray;
}

- (void)zoomMapForLocation : (CLLocation *)currentLocation{
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = LatitudeDelta;
    span.longitudeDelta = LongitudeDelta;
    region.span = span;
    
    region.center = currentLocation.coordinate;
    
    [_locationMapView setRegion:region animated:TRUE];
    [_locationMapView regionThatFits:region];
}

#pragma mark - Textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    RESIGN_KEYBOARD
    if (textField.text.length > 0) {
        self.autocompleteTableView.hidden = YES;
        [self searchVenue:textField.text];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;

    if (newLength > 3) {
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
        
        
        [self autoComplete:currentString];
    }
    else {
        self.autocompleteTableView.hidden = YES;
    }
    return newLength <= 30;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    RESIGN_KEYBOARD
}
@end
