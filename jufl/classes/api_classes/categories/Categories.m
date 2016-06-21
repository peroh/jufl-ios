//
//  Categories.m
//  MellToo
//
//  Created by Naveen Rana on 09/04/14.
//  Copyright (c) 2014 Naveen Rana. All rights reserved.
//

#import "Categories.h"


@implementation UILabel (Category)

/*  Set Font  */

-(void)TitlewithCustomFontLite:(CGFloat)sizeA{
    self.font = [UIFont fontWithName:FONT_LIGHT size:sizeA];
}
-(void)TitlewithCustomFontRegular:(CGFloat)sizeA{
    self.font = [UIFont fontWithName:FONT_REGULAR size:sizeA];
}
-(void)TitlewithCustomFontLiteSemibold:(CGFloat)sizeA{
    self.font = [UIFont fontWithName:FONT_SEMIBOLD size:sizeA];
}
-(void)TitlewithHelveticaFontThin:(CGFloat)sizeA{
    self.font = [UIFont fontWithName:FONT_HELVETICA_THIN size:sizeA];
}
- (void) boldRange: (NSRange) range {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    NSDictionary *attributes=@{NSFontAttributeName: [UIFont boldSystemFontOfSize:self.font.pointSize],NSForegroundColorAttributeName:AppGreenThemeColor};
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attributedText setAttributes:attributes range:range];
    
    self.attributedText = attributedText;
    attributedText=nil;
}

- (void) boldSubstring: (NSString*) substring {
    NSRange range = [self.text rangeOfString:substring];
    if(range.location!=NSNotFound)
    {
        [self boldRange:range];

    }
}
@end
@implementation UILabel (VerticalAlign)
- (void)alignTop
{
   // CGSize fontSize = [self.text sizeWithFont:self.font];
    CGSize fontSize = [self.text boundingRectWithSize:self.frame.size
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:@{NSFontAttributeName:self.font}
                                                                context:nil].size;

    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    
    
//    CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    CGSize theStringSize = [self.text boundingRectWithSize:CGSizeMake(finalWidth, finalHeight)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:self.font}
                                              context:nil].size;
    
    
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    
    for(int i=0; i<= newLinesToPad; i++)
    {
        self.text = [self.text stringByAppendingString:@" \n"];
    }
}

- (void)alignBottom
{
   // CGSize fontSize = [self.text sizeWithFont:self.font];
    CGSize fontSize = [self.text boundingRectWithSize:self.frame.size
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:self.font}
                                              context:nil].size;
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    
    
    //CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    
    CGSize theStringSize = [self.text boundingRectWithSize:CGSizeMake(finalWidth, finalHeight)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:self.font}
                                                   context:nil].size;
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    
    for(int i=0; i< newLinesToPad; i++)
    {
        self.text = [NSString stringWithFormat:@" \n%@",self.text];
    }
}
@end


@implementation NSString (containsCategory)

- (BOOL)containsString: (NSString*) substring
{
    NSRange range = [self rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}

- (NSString *)removeSpaces
{
   NSString *resultStr = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    resultStr = [resultStr stringByReplacingOccurrencesOfString:@" " withString:@""];

    return resultStr;

}
@end

@implementation UIColor (Helper)

+ (UIColor *)colorWithRGBA:(NSUInteger)color
{
    return [UIColor colorWithRed:((color >> 24) & 0xFF) / 255.0f
                           green:((color >> 16) & 0xFF) / 255.0f
                            blue:((color >> 8) & 0xFF) / 255.0f
                           alpha:((color) & 0xFF) / 255.0f];
}

@end


@implementation UIButton (Category)

/*  Set Font  */

-(void)TitlewithCustomFontLite:(CGFloat)sizeA{
    self.titleLabel.font = [UIFont fontWithName:FONT_LIGHT size:sizeA];
}
-(void)TitlewithCustomFontRegular:(CGFloat)sizeA{
    self.titleLabel.font = [UIFont fontWithName:FONT_REGULAR size:sizeA];
}
-(void)TitlewithCustomFontLiteSemibold:(CGFloat)sizeA{
    self.titleLabel.font = [UIFont fontWithName:FONT_SEMIBOLD size:sizeA];
}
-(void)TitlewithHelveticaFontThin:(CGFloat)sizeA{
    self.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_THIN size:sizeA];
}

@end

@implementation NSDictionary (DictExpanded)
- (id)objectStringNonNullForKey:(id)aKey
{
    id obj = [self objectForKey:aKey];
    if (obj == [NSNull null]  || obj == nil)
    {
        return @"";
    }
    return obj;
}

- (id)objectNumberNonNullForKey:(id)aKey
{
    id obj = [self objectForKey:aKey];
    if (obj == [NSNull null]  || obj == nil)
    {
        return [NSNumber numberWithInt:0];
    }
    return obj;
}

- (id)objectNonNullForKey:(id)aKey
{
    id obj = [self objectForKey:aKey];
    if (obj == [NSNull null] || obj == nil)
        return nil;
    return obj;
}

-(NSString*) jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}



@end

//========================  NSMutableDictionary Category ====================
@implementation NSMutableDictionary (Expanded)

- (id)objectNonNullForKey:(id)aKey
{
    id obj = [self objectForKey:aKey];
    if (obj == [NSNull null] || obj == nil)
        return nil;
    return obj;
}

- (id)objectStringNonNullForKey:(id)aKey
{
    id obj = [self objectForKey:aKey];
    if (obj == [NSNull null]  || obj == nil)
    {
        return @"";
    }
    return obj;
}

- (id)objectNumberNonNullForKey:(id)aKey
{
    id obj = [self objectForKey:aKey];
    if (obj == [NSNull null]  || obj == nil)
    {
        return [NSNumber numberWithInt:0];
    }
    return obj;
}

@end


#pragma mark NSMutableArray Category
// This category enhances NSMutableArray by providing
// methods to randomly shuffle the elements.
@interface NSMutableArray (Shuffling)
- (void)shuffle;
@end


//  NSMutableArray_Shuffling.m


@implementation NSMutableArray (Shuffling)

- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end



@implementation UITextField (UITextField_Additions)

- (void)addImageInLeft:(UIImage *)leftImage andImageInRight:(UIImage *)rightImage {
    
    if (leftImage)
    {
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 0, 30, self.frame.size.height)];
        
        [image setImage:leftImage];
        
        [image setContentMode:UIViewContentModeCenter];
        [self setLeftView:image];
        
        self.leftViewMode = UITextFieldViewModeAlways;

    }
    
    if (rightImage)
    {
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 50, 0, 50, self.frame.size.height)];
        
        [image setImage:rightImage];
        
        [image setContentMode:UIViewContentModeCenter];
        [self setRightView:image];
        self.rightViewMode = UITextFieldViewModeAlways;
    }
    
}

- (void)addViewInLeft:(UIView *)leftView andViewInRight:(UIView *)rightView
{
    if (leftView)
    {
        [leftView setFrame:CGRectMake(0, 0, 50, self.frame.size.height)];
        [self setLeftView:leftView];
        self.leftViewMode = UITextFieldViewModeAlways;
    }
    
    if (rightView)
    {
        [rightView setFrame:CGRectMake(self.frame.size.width - 50, 0, 50, self.frame.size.height)];
       [self setRightView:rightView];
        self.rightViewMode = UITextFieldViewModeAlways;
    }
}


//// set placeholder textcolor
- (UITextField *)placeholderColorTextField : (UITextField *) textField :(UIColor *)color
{
    [textField setValue:color forKeyPath:@"_placeholderLabel.textColor"];
    return textField;
}

//// set placeholder textcolor

- (void) textFieldLeftView : (UITextField *) textField : (UIImage *) image : (int) paddingWidth
{
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, paddingWidth, 20)];
    //UIImageView *imageView=[[UIImageView alloc] initWithImage:image];
    
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    textField.leftViewMode=UITextFieldViewModeAlways;
    imageView.image=image;
    textField.leftView=imageView;
    imageView=nil;
}

// return left padding of textfield
- (UITextField *) paddingTextField : (UITextField *) textField :(int) paddingWidth{
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingWidth, 20)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    return textField;
}

@end


@implementation Categories

@end
