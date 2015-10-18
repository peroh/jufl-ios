//
//  GHWalkThroughCell.m
//  GHWalkThrough
//
//  Created by Tapasya on 21/01/14.
//  Copyright (c) 2014 Tapasya. All rights reserved.
//

#import "GHWalkThroughPageCell.h"

@interface GHWalkThroughPageCell ()

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UITextView* descLabel;
@property (nonatomic, strong) UIImageView* titleImageView;
@property (nonatomic, strong) UIView* imageContentView;

@end

@implementation GHWalkThroughPageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self applyDefaults];
        [self buildUI];
    }
    return self;
}

#pragma mark setters

- (void) setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = self.title;
    [self setNeedsLayout];
}

- (void) setTitleImage:(UIImage *)titleImage
{
    _titleImage = titleImage;
    self.titleImageView.image = self.titleImage;
	self.titleImageView.contentMode = UIViewContentModeRedraw;
    [self setNeedsLayout];
}

- (void) setDesc:(NSString *)desc
{
    _desc = desc;
    self.descLabel.text = self.desc;
    [self setNeedsLayout];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect1 = self.imageContentView.frame;
    rect1.origin.x = ((self.contentView.frame.size.width - rect1.size.width)/2)+20;
    if ([NRValidation isiPhone6]) {
        rect1.origin.y = 69;
    }
    else {
        rect1.origin.y = 39;
    }
    //self.frame.size.height - self.titlePositionY - self.imgPositionY - rect1.size.height-1;
    self.imageContentView.frame = rect1;
    //self.titleImageView.frame = rect1;

    [self layoutTitleLabel];
    
    CGRect descLabelFrame = CGRectMake(20, self.frame.size.height - self.descPositionY + 10, self.contentView.frame.size.width - 40, 500);
    self.descLabel.frame = descLabelFrame;
    
}

- (void) layoutTitleLabel
{
    CGFloat titleHeight;
    
    if ([self.title respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.title attributes:@{ NSFontAttributeName: self.titleFont }];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){self.contentView.frame.size.width - 20, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        titleHeight = ceilf(rect.size.height);
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        titleHeight = [self.title sizeWithFont:self.titleFont constrainedToSize:CGSizeMake(self.contentView.frame.size.width - 20, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
#pragma clang diagnostic pop
    }
    
    CGRect titleLabelFrame = CGRectMake(10, self.frame.size.height - self.titlePositionY, self.contentView.frame.size.width - 20, titleHeight);

    self.titleLabel.frame = titleLabelFrame;
}

- (void) applyDefaults
{
    self.title = @"Title";
    self.desc = @"Default Description";
    
    self.imgPositionY    = 20.0f;
    self.titlePositionY  = 180.0f;
    self.descPositionY   = 160.0f;
//    self.titleFont = FONT_OpenSans_Semibold_WITH_SIZE(23);//[UIFont fontWithName:FONT_ProximaNova_SemiBold size:20.0];
    self.titleColor = Rgb2UIColor(48, 48, 48);//[UIColor whiteColor];
//    self.descFont = FONT_OpenSans_Regular_WITH_SIZE(13);//(23);//[UIFont fontWithName:FONT_ProximaNova_SemiBold size:15.0];
    self.descColor = Rgb2UIColorWithAlpha(48, 48, 48, 0.65);//[UIColor colorWithRed:137.0/255.0 green:146.0/255.0 blue:166.0/255.0 alpha:1];
}

- (void) buildUI {
    
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    UIView *pageView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    
    if (self.titleImageView == nil) {
        
        UIImageView *titleImageView = self.titleImage != nil ? [[UIImageView alloc] initWithImage:self.titleImage] : [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 235.5, 396.5)];
        UIView *tempImageContentView = nil;
        if ([NRValidation isiPhone6]) {
            tempImageContentView = self.imageContentView != nil ? self.imageContentView : [[UIView alloc] initWithFrame:CGRectMake(0, 0, 235.5, ScreenHeight-315)];
        }
        else {
            tempImageContentView = self.imageContentView != nil ? self.imageContentView : [[UIView alloc] initWithFrame:CGRectMake(0, 0, 235.5, ScreenHeight-285)];
        }
        
//        UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
//        titleImageView.image = self.titleImage;
        self.imageContentView = tempImageContentView;
        self.titleImageView = titleImageView;
    }
    
    [self.imageContentView addSubview:self.titleImageView];
    self.imageContentView.clipsToBounds = YES;
    [pageView addSubview:self.imageContentView];
    
    if(self.titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.text = self.title;
        titleLabel.font = self.titleFont;
        titleLabel.textColor = self.titleColor;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [pageView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    
    if(self.descLabel == nil) {
        UITextView *descLabel = [[UITextView alloc] initWithFrame:CGRectZero];
        descLabel.text = self.desc;
        descLabel.scrollEnabled = NO;
        descLabel.font = self.descFont;
        descLabel.textColor = self.descColor;
        descLabel.backgroundColor = [UIColor clearColor];
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.userInteractionEnabled = NO;
        [pageView addSubview:descLabel];
        self.descLabel = descLabel;
    }

    [self.contentView addSubview:pageView];
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
