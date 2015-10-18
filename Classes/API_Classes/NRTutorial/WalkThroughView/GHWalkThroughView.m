//
//  GHWalkThroughView.m
//  GHWalkThrough
//
//  Created by Tapasya on 21/01/14.
//  Copyright (c) 2014 Tapasya. All rights reserved.
//

#import "GHWalkThroughView.h"

@interface GHWalkThroughView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) UIImageView* bgFrontLayer;
@property (nonatomic, strong) UIImageView* bgBackLayer;
@property (nonatomic, strong) UIImageView *phoneFrontLayer;

@property (nonatomic, strong) UIPageControl* pageControl;
@property (nonatomic, strong) UIButton* skipButton;

@property (nonatomic, weak) UICollectionViewFlowLayout* layout;

@end

@implementation GHWalkThroughView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void) setup
{
    self.backgroundColor = [UIColor clearColor];
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:self.screenFrame];
    [backgroundImageView setImage:[UIImage imageNamed:@"Background"]];
    [self addSubview:backgroundImageView];
    CGRect backgroundFrame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 246);
    
    _bgFrontLayer = [[UIImageView alloc] initWithFrame:backgroundFrame];
    _bgBackLayer = [[UIImageView alloc] initWithFrame:backgroundFrame];
//    _phoneFrontLayer = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth-100)];
    
    UIView* bgView = [[UIView alloc] initWithFrame:self.frame];
    [bgView addSubview:_bgBackLayer];
    [bgView addSubview:_bgFrontLayer];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    self.layout = flowLayout;

    _collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.backgroundView = bgView;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[GHWalkThroughPageCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.collectionView setPagingEnabled:YES];
    [self addSubview:_collectionView];
    
    [self buildFooterView];
    [self insertSubview:_phoneFrontLayer aboveSubview:_collectionView];

}

- (void) setFloatingHeaderView:(UIView *)floatingHeaderView
{
    if (_floatingHeaderView != nil) {
        [_floatingHeaderView removeFromSuperview];
    }
    
    _floatingHeaderView = floatingHeaderView;
    CGRect frame = _floatingHeaderView.frame;
    frame.origin.y = 50;
    frame.origin.x = self.frame.size.width/2 - frame.size.width/2;
    _floatingHeaderView.frame = frame;
    
    [self addSubview:_floatingHeaderView];
    [self bringSubviewToFront:_floatingHeaderView];
}

- (void) setWalkThroughDirection:(GHWalkThroughViewDirection)walkThroughDirection
{
    _walkThroughDirection = walkThroughDirection;
    UICollectionViewScrollDirection dir = _walkThroughDirection == GHWalkThroughViewDirectionVertical ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
    UICollectionViewFlowLayout* layout =  (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    [layout setScrollDirection:dir];
    [layout invalidateLayout];
    [self orientFooter];
}

- (void)setCloseTitle:(NSString *)closeTitle
{
    _closeTitle = closeTitle;
    [self.skipButton setTitle:_closeTitle forState:UIControlStateNormal];
}

- (void)orientFooter
{
    self.pageControl.userInteractionEnabled = NO;
    if (self.walkThroughDirection == GHWalkThroughViewDirectionVertical) {
        BOOL isRotated = !CGAffineTransformEqualToTransform(self.pageControl.transform, CGAffineTransformIdentity);
        if (!isRotated) {
            CGRect butonFrame = self.skipButton.frame;
            butonFrame.origin.x -= 30;
            self.skipButton.frame = butonFrame;
            
            self.pageControl.transform = CGAffineTransformRotate(self.pageControl.transform, M_PI_2);
            CGRect frame = self.pageControl.frame;
            frame.size.height = ([self.dataSourceCustom numberOfPages] + 1 ) * 16;
            frame.origin.x = self.frame.size.width - frame.size.width - 10;
            frame.origin.y = butonFrame.origin.y+butonFrame.size.height - frame.size.height;
            self.pageControl.frame = frame;
        
        }
    } else{
        BOOL isRotated = !CGAffineTransformEqualToTransform(self.pageControl.transform, CGAffineTransformIdentity);
        if (isRotated) {
            // Rotate back the page control
            self.pageControl.transform = CGAffineTransformRotate(self.pageControl.transform, -M_PI_2);
            self.pageControl.frame = CGRectMake(0, self.frame.size.height - 60, self.frame.size.width, 20);
            
            self.skipButton.frame = CGRectMake(self.frame.size.width - 80, self.pageControl.frame.origin.y - ((30 - self.pageControl.frame.size.height)/2), 80, 30);

        }
    }
}

- (void)buildFooterView {
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 210, self.frame.size.width, 20)];
    
    //Set defersCurrentPageDisplay to YES to prevent page control jerking when switching pages with page control. This prevents page control from instant change of page indication.
    
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.defersCurrentPageDisplay = YES;
    self.pageControl.pageIndicatorTintColor = Rgb2UIColor(145, 145, 145);
    self.pageControl.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    [self.pageControl addTarget:self action:@selector(showPanelAtPageControl:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.pageControl];
    [self bringSubviewToFront:self.pageControl];
    
    self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.skipButton.frame = CGRectMake(self.frame.size.width/2 - 87.5, self.frame.size.height - 78, 175, 50);
    self.skipButton.layer.cornerRadius = 25.0;
    self.skipButton.backgroundColor = Rgb2UIColor(255, 184, 46);
    self.skipButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    [self.skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.skipButton addTarget:self action:@selector(skipIntroduction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.skipButton];
//    self.skipButton.titleLabel.font = FONT_OpenSans_Semibold_WITH_SIZE(17.5);
    [self bringSubviewToFront:self.skipButton];
}

- (void)skipIntroduction
{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished){
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)0);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self removeFromSuperview];
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(walkthroughDidDismissView:)]) {
                    [self.delegate walkthroughDidDismissView:self];
                }
            });
        }];
    
}

- (void)showPanelAtPageControl:(UIPageControl*) sender
{
    [self.pageControl setCurrentPage:sender.currentPage];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self.pageControl.currentPageIndicatorTintColor = Rgb2UIColor(253, 192, 75);
    
    NSInteger nPages = [self.dataSourceCustom numberOfPages];
    return nPages;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //self.pageControl.currentPage = indexPath.row;
    GHWalkThroughPageCell *cell = (GHWalkThroughPageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    if (self.dataSourceCustom != nil && [self.dataSourceCustom respondsToSelector:@selector(configurePage:atIndex:)]) {
        [self.dataSourceCustom configurePage:cell atIndex:indexPath.row];
    }
    return cell;
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    
    return 0.0f;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.frame.size;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = [self horizontalPageNumber:scrollView];
    float offset = self.walkThroughDirection == GHWalkThroughViewDirectionHorizontal ? self.collectionView.contentOffset.x / self.collectionView.frame.size.width : self.collectionView.contentOffset.y / self.collectionView.frame.size.height ;
    [self crossDissolveForOffset:offset page:self.pageControl.currentPage];
//    if ([self.dataSourceCustom respondsToSelector:@selector(bgImageforPage:)]) {
//        self.bgFrontLayer.image = [self.dataSourceCustom bgImageforPage:self.pageControl.currentPage];
//    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    /*
    // Get scrolling position, and send the alpha values.
    if (!self.isfixedBackground) {
        float offset = self.walkThroughDirection == GHWalkThroughViewDirectionHorizontal ? self.collectionView.contentOffset.x / self.collectionView.frame.size.width : self.collectionView.contentOffset.y / self.collectionView.frame.size.height ;
        [self crossDissolveForOffset:offset];
    }
    
    CGFloat pageMetric = 0.0f;
    CGFloat contentOffset = 0.0f;
    
    switch (self.walkThroughDirection) {
        case GHWalkThroughViewDirectionHorizontal:
            pageMetric = scrollView.frame.size.width;
            contentOffset = scrollView.contentOffset.x;
            break;
        case GHWalkThroughViewDirectionVertical:
            pageMetric = scrollView.frame.size.height;
            contentOffset = scrollView.contentOffset.y;
            break;
    }
    
    int page = floor((contentOffset - pageMetric / 2) / pageMetric) + 1;
    self.pageControl.currentPage = page;*/
}

- (void)crossDissolveForOffset:(float)offset page:(NSInteger)page {
    float alphaValue = offset - (int)offset;
    
    if (alphaValue < 0 && self.pageControl.currentPage == 0){
        self.bgBackLayer.image = nil;
        self.bgFrontLayer.alpha = (1 + alphaValue);
        return;
    }
    
    self.bgFrontLayer.alpha = 1;
    self.bgFrontLayer.image = [self.dataSourceCustom bgImageforPage:page];
    self.phoneFrontLayer.image = self.bgFrontLayer.image;
    self.bgBackLayer.alpha = 0;
    self.bgBackLayer.image = [self.dataSourceCustom bgImageforPage:page+1];
    
    float backLayerAlpha = alphaValue;
    float frontLayerAlpha = (1 - alphaValue);
    
    backLayerAlpha = easeOutValue(backLayerAlpha);
    frontLayerAlpha = easeOutValue(frontLayerAlpha);
    
    self.bgBackLayer.alpha = backLayerAlpha;
    self.bgFrontLayer.alpha = frontLayerAlpha;
}

float easeOutValue(float value) {
    float inverse = value - 1.0;
    return 1.0 + inverse * inverse * inverse;
}

- (void)showInView:(UIView *)view animateDuration:(CGFloat) duration
{
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = [self.dataSourceCustom numberOfPages];;

    if (self.isfixedBackground) {
        self.bgFrontLayer.image = self.bgImage;
    } else{
        self.bgFrontLayer.image = [self.dataSourceCustom bgImageforPage:0];
    }
    
    self.phoneFrontLayer.image = self.bgFrontLayer.image;

    self.alpha = 0;
    self.collectionView.contentOffset = CGPointZero;
    [view addSubview:self];
    
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 1;
    }];
}

-(NSInteger)horizontalPageNumber:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    CGSize viewSize = scrollView.bounds.size;
    
    NSInteger horizontalPage = MAX(0.0, contentOffset.x / viewSize.width);
    
    // Here's how vertical would work...
    //NSInteger verticalPage = MAX(0.0, contentOffset.y / viewSize.height);
    
    return horizontalPage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
