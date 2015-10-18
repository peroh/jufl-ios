//
//  AdditionalInfoViewController.h
//  JUFL
//
//  Created by Ankur on 17/08/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdditionalInfoViewController : UIViewController

typedef void(^AdditionalInfoCompletionHandler)(NSString *info);

@property (nonatomic,copy)AdditionalInfoCompletionHandler additionalInfoCompletionHandler ;

- (instancetype)initWithInfo:(NSString *)info withCompletion:(AdditionalInfoCompletionHandler)block;

- (void)getAdditionalInfoWithCompletionHandler:(AdditionalInfoCompletionHandler)handler;

@end
