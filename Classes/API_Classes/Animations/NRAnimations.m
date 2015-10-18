//
//  NRAnimations.m
//  AroundAbout
//
//  Created by Naveen Rana on 23/12/14.
//  Copyright (c) 2014 Naveen Rana. All rights reserved.
//

#import "NRAnimations.h"
#import "WTURLImageView.h"


@implementation UIView (Animations)

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

static CGFloat animationDuration = 2.0f;

-(void)makeImageTrasition:(UIView *)viewTemp effect :(NaveenImageViewOptions) effect;
{
    UIButton *tempButton = nil;
    UIImageView *tempImageView = nil;
    UIImage *image= nil;
    if([viewTemp isKindOfClass:[UIButton class]])
    {
        tempButton = (UIButton *)viewTemp;
        image = tempButton.currentImage;
    }else if ([viewTemp isKindOfClass:[UIImageView class]])
    {
        tempImageView = (UIImageView *)viewTemp;
        image = tempImageView.image;

    }
    switch (effect) {
            // OS-provided CALayer CATranstion type transition animation
        case NaveenImageViewOptionTransitionCrossDissolve:
        
        case NaveenImageViewOptionTransitionRipple:
        case NaveenImageViewOptionTransitionCubeFromRight:
        case NaveenImageViewOptionTransitionCubeFromLeft:
        case NaveenImageViewOptionTransitionCubeFromTop:
        case NaveenImageViewOptionTransitionCubeFromBottom:
        {
            CATransition *animation = [CATransition animation];
            [animation setDuration:animationDuration];
            //[animation setSubtype:kCATransitionFromLeft];
            //rippleEffect, cube, oglFlip...
            switch (effect) {
                default:
                    [animation setType:kCATransitionFade]; break;
                case NaveenImageViewOptionTransitionCubeFromTop:
                    [animation setType:@"cube"]; [animation setSubtype:kCATransitionFromTop]; break;
                case NaveenImageViewOptionTransitionCubeFromBottom:
                    [animation setType:@"cube"]; [animation setSubtype:kCATransitionFromBottom]; break;
                case NaveenImageViewOptionTransitionCubeFromLeft:
                    [animation setType:@"cube"]; [animation setSubtype:kCATransitionFromLeft]; break;
                case NaveenImageViewOptionTransitionCubeFromRight:
                    [animation setType:@"cube"]; [animation setSubtype:kCATransitionFromRight]; break;
                case NaveenImageViewOptionTransitionRipple:
                    [animation setType:@"rippleEffect"]; break;
            }
            
            [viewTemp.layer addAnimation:animation forKey:@"transition"];
            //[self setBackgroundImage:image forState:self.state];
        } break;
            // Custom dissolve type animation
        case NaveenImageViewOptionTransitionScaleDissolve:
        case NaveenImageViewOptionTransitionPerspectiveDissolve:
        {
            CALayer *layer = [self wt_layerFromImage:nil viewTemp:viewTemp];
            switch (effect) {
                default:
                    //case NaveenImageViewOptionTransitionCrossDissolve:
                    //    break;
                case NaveenImageViewOptionTransitionScaleDissolve:
                    layer.affineTransform = CGAffineTransformMakeScale(1.5, 1.5); break;
                case NaveenImageViewOptionTransitionPerspectiveDissolve:
                {
                    CATransform3D t = CATransform3DIdentity;
                    t.m34 = 1.0/-450.0;
                    t = CATransform3DScale(t, 1.2, 1.2, 1);
                    t = CATransform3DRotate(t, 45.0f*M_PI/180.0f, 1, 0, 0);
                    t = CATransform3DTranslate(t, 0, viewTemp.bounds.size.height * 0.1, 0);
                    layer.transform = t;
                } break;
            }
            layer.opacity = 0.0f;
            [viewTemp.layer addSublayer: layer];
            [CATransaction flush];
            [CATransaction begin];
            [CATransaction setAnimationDuration: animationDuration];
            [CATransaction setCompletionBlock: ^ {
                [layer removeFromSuperlayer];
               // [self setBackgroundImage:image forState:self.state];
            }];
            layer.opacity = 1.0f;
            layer.affineTransform = CGAffineTransformIdentity;
            [CATransaction commit];
            
        } break;
            // Custom slide type animation
        case NaveenImageViewOptionTransitionSlideInTop:
        case NaveenImageViewOptionTransitionSlideInLeft:
        case NaveenImageViewOptionTransitionSlideInBottom:
        case NaveenImageViewOptionTransitionSlideInRight:
        {
            CALayer *layer ;//= [self wt_layerFromImage:image];
            BOOL clipsToBoundsSave = viewTemp.clipsToBounds;
            viewTemp.clipsToBounds = YES;
            switch (effect) {
                default:
                case NaveenImageViewOptionTransitionSlideInTop:
                    layer.affineTransform = CGAffineTransformMakeTranslation(0, -viewTemp.bounds.size.height); break;
                case NaveenImageViewOptionTransitionSlideInLeft:
                    layer.affineTransform = CGAffineTransformMakeTranslation(-viewTemp.bounds.size.width, 0); break;
                case NaveenImageViewOptionTransitionSlideInBottom:
                    layer.affineTransform = CGAffineTransformMakeTranslation(0, viewTemp.bounds.size.height); break;
                case NaveenImageViewOptionTransitionSlideInRight:
                    layer.affineTransform = CGAffineTransformMakeTranslation(viewTemp.bounds.size.width, 0); break;
                    break;
            }
            [viewTemp.layer addSublayer: layer];
            [CATransaction flush];
            [CATransaction begin];
            [CATransaction setAnimationDuration: animationDuration];
            [CATransaction setCompletionBlock: ^ {
                [layer removeFromSuperlayer];
               // [self setBackgroundImage:image forState:self.state];
                // have sublayer means animation in progress
                NSArray *sublayer = viewTemp.layer.sublayers;
                if (sublayer.count==1)
                    viewTemp.clipsToBounds = clipsToBoundsSave;
            }];
            layer.affineTransform = CGAffineTransformIdentity;
            [CATransaction commit];
        } break;
            // OS-provided UIView type transition animation
        case NaveenImageViewOptionTransitionFlipFromLeft:
        case NaveenImageViewOptionTransitionFlipFromRight:
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:animationDuration];
            switch (effect) {
                case NaveenImageViewOptionTransitionFlipFromLeft:
                    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES]; break;
                case NaveenImageViewOptionTransitionFlipFromRight:
                    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self cache:YES]; break;
                default:
                    break;
            }
            //[self setBackgroundImage:image forState:self.state];
            [UIView commitAnimations];
            break;
        } break;
        default:
            break;
    }
}

-(CALayer*)wt_layerFromImage:(UIImage*) image viewTemp:(UIView *)viewTemp
{
    CALayer *layer = [CALayer layer];
    layer.contents = (__bridge id)([image wt_normalizeOrientation].CGImage);
    layer.frame = viewTemp.bounds;
    return layer;
}

-(void)fadeInAnimation:(UIView *)viewTemp delay:(NSTimeInterval)delay
{
    [UIView animateWithDuration:animationDuration delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        viewTemp.alpha = 1.0f;

    } completion:^(BOOL finished) {
        
    }];
    
    /*[UIView animateWithDuration:animationDuration delay:0.0 usingSpringWithDamping:1 initialSpringVelocity:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        viewTemp.alpha = 1.0f;

    } completion:^(BOOL finished) {
        
    }];*/
    
}
@end


@implementation NRAnimations


+ (UIImageView *)animateImageViewWithImages:(NSArray *)imagesArray
{
    UIImage *tempImage = [UIImage imageNamed:imagesArray[0]];
    UIImageView* loadingImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tempImage.size.width+20, tempImage.size.height+20)];
    
    NSMutableArray* animatedImages = [[NSMutableArray alloc] init];
    for (int i = 0; i <imagesArray.count; i++) {
        
        UIImage * image = [UIImage imageNamed:imagesArray[i]];
        [animatedImages addObject:image];
    }
    
    loadingImage.animationImages = animatedImages;
    loadingImage.animationDuration = 1.5f;
    loadingImage.animationRepeatCount = 0;
    [loadingImage startAnimating];
    animatedImages = nil;
    return loadingImage;
}


@end
