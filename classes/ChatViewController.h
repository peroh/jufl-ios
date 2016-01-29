//
//  ChatViewController.h
//  jufl
//
//  Created by Dhirendra Kumar on 1/18/16.
//  Copyright © 2016 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
@interface ChatViewController : UIViewController<HPGrowingTextViewDelegate>
{
  
   HPGrowingTextView *textView;
}
@property(nonatomic, strong) UIView *containerView;
-(void)resignTextView;

- (instancetype)initWithChat:(EventModel *)event withViewMode:(ChatViewMode)viewMode;
@end
