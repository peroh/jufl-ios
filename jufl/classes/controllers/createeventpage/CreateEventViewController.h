//
//  CreateEventViewController.h
//  JUFL
//
//  Created by Ankur on 13/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateEventViewController : UIViewController

- (instancetype)initWithEvent:(EventModel *)event withViewMode:(EventViewMode)viewMode;

@end
