//
//  SelectLocationViewController.h
//  JUFL
//
//  Created by Ankur on 14/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventModel.h"

@interface SelectLocationViewController : UIViewController

- (instancetype)initWithEvent:(EventModel *)event andViewMode:(EventViewMode)mode;

@end
