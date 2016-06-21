//
//  CSAlertView.h
//  CultureSphere
//
//  Created by CultureSphere on 18/12/13.
//  Copyright (c) 2013 CultureSphere. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum ButtonType
{
    buttonOK,
    buttonCancel
}ButtonType;

@interface CSAlertView : UIView<UITextFieldDelegate>

/*  Default AlertView  */
/*  AlertView with TextField  */


- (id)initWithTitle:(NSString *)title Body:(NSString *)body WithYesNO:(BOOL)isYesNO;
@property (copy) void (^onButtonTouchUpInside)(CSAlertView *alertView, ButtonType buttonType);
- (void)setOnButtonTouchUpInside:(void (^)(CSAlertView *alertView, ButtonType buttonType))onButtonTouchUpInside;
- (void)close;
- (void)show;
@property (nonatomic, retain) IBOutlet UILabel *lblTitle, *lblBody;
@property (nonatomic, retain) IBOutlet UIButton *btnOk, *btnCancel;
@property (nonatomic, retain) IBOutlet UITextField *txt;
@property (nonatomic, assign) BOOL useMotionEffects;
@property(nonatomic,assign)ButtonType buttonType;
@end
