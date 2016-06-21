//
//  EventDetailViewController.h
//  JUFL
//
//  Created by Ankur on 28/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailViewController : UIViewController

@property (nonatomic, strong) NSNumber *eventId;
@property (nonatomic, assign)CurrentPastFeedTableViewMode viewEventMode;

- (instancetype)initWithEvent :(EventModel *)event andMode:(EventDetailMode)mode;
- (instancetype)initWithEventMode :(EventModel *)event andMode:(CurrentPastFeedTableViewMode)mode;
- (instancetype)initWithEventId:(NSNumber *)eventId;

- (void)getEventDetail:(NSNumber *)eventId;
@end
