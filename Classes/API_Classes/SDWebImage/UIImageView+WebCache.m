/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "objc/runtime.h"
#import "UIView+WebCacheOperation.h"
#import <QuartzCore/QuartzCore.h>

static char imageURLKey;
@implementation UIImageView (WebCache)

- (void)sd_setImageWithURL:(NSURL *)url animation:(NaveenImageViewOptions)animation {
    [self sd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil animation:animation];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder animation:(NaveenImageViewOptions)animation {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil
     animation:animation];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options animation:(NaveenImageViewOptions)animation{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil animation:animation];
}

- (void)sd_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock animation:(NaveenImageViewOptions)animation{
    [self sd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock animation:animation];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock animation:(NaveenImageViewOptions)animation {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:nil completed:completedBlock animation:animation];
}

- (void)sd_setImageWithURLToReloadImage:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock animation:(NaveenImageViewOptions)animation {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRefreshCached progress:nil completed:completedBlock animation:animation];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock animation:(NaveenImageViewOptions)animation {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock animation:animation];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock animation:(NaveenImageViewOptions)animation{
    [self sd_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            self.image = placeholder;
        });
    }
    
    if (url) {
        if ([placeholder isEqual:imgSync])
        {
            [self setContentMode:UIViewContentModeCenter];
            [self startRotate];
        }

        __weak UIImageView *wself = self;
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progressBlock  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (image) {
                    [self stopRotate];

                    wself.image = image;
                    if (options!= SDWebImageProgressiveDownload)
                    {
                        if(animation!=NaveenImageViewOptionsNone)
                        {
                            [self setAlpha:0];
                            [UIView beginAnimations:nil context:NULL];
                            [UIView setAnimationDuration:1.0];
                            wself.image = image;
                            [self setAlpha:1];
                            
                            [UIView commitAnimations];
                        }
                        
                        
                    }
                    if(animation!=NaveenImageViewOptionsNone)
                        [self makeImageTrasition:self effect:NaveenImageViewOptionTransitionCubeFromTop];
                    [wself setNeedsLayout];


                } else {
                    if ((options & SDWebImageDelayPlaceholder)) {
                        wself.image = placeholder;
                        [wself setNeedsLayout];
                    }
                }
                if (completedBlock && finished) {
                    [self setContentMode:UIViewContentModeCenter];
                    [self stopRotate];
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:@"SDWebImageErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)sd_setImageWithPreviousCachedImageWithURL:(NSURL *)url andPlaceholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock animation:(NaveenImageViewOptions)animation {
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *lastPreviousCachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    
    [self sd_setImageWithURL:url placeholderImage:lastPreviousCachedImage ?: placeholder options:options progress:progressBlock completed:completedBlock animation:animation];
}

- (NSURL *)sd_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)sd_setAnimationImagesWithURLs:(NSArray *)arrayOfURLs {
    [self sd_cancelCurrentAnimationImagesLoad];
    __weak UIImageView *wself = self;

    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];

    for (NSURL *logoImageURL in arrayOfURLs) {
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:logoImageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                __strong UIImageView *sself = wself;
                [sself stopAnimating];
                if (sself && image) {
                    NSMutableArray *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages) {
                        currentImages = [[NSMutableArray alloc] init];
                    }
                    [currentImages addObject:image];

                    sself.animationImages = currentImages;
                    [sself setNeedsLayout];
                }
                [sself startAnimating];
            });
        }];
        [operationsArray addObject:operation];
    }

    [self sd_setImageLoadOperation:[NSArray arrayWithArray:operationsArray] forKey:@"UIImageViewAnimationImages"];
}

- (void)sd_cancelCurrentImageLoad {
    [self stopRotate];

    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewImageLoad"];
}

- (void)sd_cancelCurrentAnimationImagesLoad {
    [self stopRotate];

    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewAnimationImages"];
}


#pragma mark transitions
-(void)startRotate
{
    CABasicAnimation *fullRotation;
    fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration = 1.5f;
    fullRotation.repeatCount = MAXFLOAT;
    
    [self.layer addAnimation:fullRotation forKey:@"360"];
}
-(void)stopRotate
{
    [self setContentMode:UIViewContentModeScaleToFill];
    [self.layer removeAnimationForKey:@"360"];
}



@end
