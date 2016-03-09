//
//  GoingViewController.h
//  JUFL
//
//  Created by Ankur on 26/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoingViewController : UIViewController

- (instancetype)initWithEvent:(EventModel *)event withMode:(GoingViewMode)mode;
- (instancetype)initWithEventMode:(EventModel *)event withMode:(GoingViewMode)mode withPastCurrentMode:(CurrentPastFeedTableViewMode)pastCurrentMode;
@property (nonatomic, strong) NSString * openTabStr;

@end
