//
//  UIImage+Utilities.m
//  Suvi
//
//  Created by Gagan Mishra on 2/19/13.
//
//

#import "UIImage+Utilities.h"

@implementation UIImage (Utilities)

+ (UIImage *)imageNamed:(NSString *)imageName bundleName:(NSString *)bundleName {
	if (!bundleName) {
		return [UIImage imageNamed:imageName];
	}
	
	NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
	NSString *bundlePath = [resourcePath stringByAppendingPathComponent:bundleName];
	NSString *imagePath = [bundlePath stringByAppendingPathComponent:imageName];
	return [UIImage imageWithContentsOfFile:imagePath];
}


- (UIImage *)imageCroppedToRect:(CGRect)rect
{
	// CGImageCreateWithImageInRect's `rect` parameter is in pixels of the image's coordinates system. Convert from points.
	CGFloat scale = self.scale;
	rect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
	
	CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
	UIImage *cropped = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	return cropped;
}


- (UIImage *)squareImage
{
	CGSize imageSize = self.size;
	CGFloat shortestSide = fminf(imageSize.width, imageSize.height);
	return [self imageCroppedToRect:CGRectMake(0.0f, 0.0f, shortestSide, shortestSide)];
}


- (NSInteger)rightCapWidth
{
	return (NSInteger)self.size.width - (self.leftCapWidth + 1);
}


- (NSInteger)bottomCapHeight {
	return (NSInteger)self.size.height - (self.topCapHeight + 1);
}

-(UIImage*)cropToSize:(CGSize)newSize usingMode:(UIViewContentMode )cropMode
{
	const CGSize size = self.size;
	CGFloat x, y;
	switch (cropMode)
	{
		case UIViewContentModeLeft:
			x = y = 0.0f;
			break;
		case UIViewContentModeCenter:
			x = (size.width - newSize.width) * 0.5f;
			y = 0.0f;
			break;
		case UIViewContentModeTopRight:
			x = size.width - newSize.width;
			y = 0.0f;
			break;
		case UIViewContentModeBottomLeft:
			x = 0.0f;
			y = size.height - newSize.height;
			break;
            //		case UIViewContentModeCenter:
            //			x = newSize.width * 0.5f;
            //			y = size.height - newSize.height;
            //			break;
		case UIViewContentModeBottomRight:
			x = size.width - newSize.width;
			y = size.height - newSize.height;
			break;
            //		case NYXCropModeLeftCenter:
            //			x = 0.0f;
            //			y = (size.height - newSize.height) * 0.5f;
            //			break;
            //		case NYXCropModeRightCenter:
            //			x = size.width - newSize.width;
            //			y = (size.height - newSize.height) * 0.5f;
            //			break;
            //		case NYXCropModeCenter:
            //			x = (size.width - newSize.width) * 0.5f;
            //			y = (size.height - newSize.height) * 0.5f;
            //			break;
		default: // Default to top left
			x = y = 0.0f;
			break;
	}
    
    CGRect cropRect = CGRectMake(x * self.scale, y * self.scale, newSize.width * self.scale, newSize.height * self.scale);
    
	/// Create the cropped image
	CGImageRef croppedImageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
	UIImage* cropped = [UIImage imageWithCGImage:croppedImageRef scale:self.scale orientation:self.imageOrientation];
    
	/// Cleanup
	CGImageRelease(croppedImageRef);
    
	return cropped;
}
-(UIImage*)resizedImageToSize:(CGSize)dstSize
{
	CGImageRef imgRef = self.CGImage;
	// the below values are regardless of orientation : for UIImages from Camera, width>height (landscape)
	CGSize  srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which is dependant on the imageOrientation)!
	
	CGFloat scaleRatio = dstSize.width / srcSize.width;
	UIImageOrientation orient = self.imageOrientation;
	CGAffineTransform transform = CGAffineTransformIdentity;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	/////////////////////////////////////////////////////////////////////////////
	// The actual resize: draw the image on a new context, applying a transform matrix
	UIGraphicsBeginImageContext(dstSize);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -srcSize.height, 0);
	} else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -srcSize.height);
	}
	
	CGContextConcatCTM(context, transform);
	
	// we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, srcSize.width, srcSize.height), imgRef);
	UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return resizedImage;
}



/////////////////////////////////////////////////////////////////////////////



-(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale
{
	// get the image size (independant of imageOrientation)
	CGImageRef imgRef = self.CGImage;
	CGSize srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which depends on the imageOrientation)!
	
	// adjust boundingSize to make it independant on imageOrientation too for farther computations
	UIImageOrientation orient = self.imageOrientation;
	switch (orient) {
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			boundingSize = CGSizeMake(boundingSize.height, boundingSize.width);
			break;
        default:
            // NOP
            break;
	}
    
	// Compute the target CGRect in order to keep aspect-ratio
	CGSize dstSize;
	
	if( !scale && (srcSize.width < boundingSize.width) && (srcSize.height < boundingSize.height) ) {
		dstSize = srcSize; 
	}
    else
    {
		CGFloat wRatio = boundingSize.width / srcSize.width;
		CGFloat hRatio = boundingSize.height / srcSize.height;
		
		if (wRatio < hRatio) {
			dstSize = CGSizeMake(boundingSize.width, srcSize.height * wRatio);
		} else {
			dstSize = CGSizeMake(srcSize.width * hRatio, boundingSize.height);
		}
	}
    
	return [self resizedImageToSize:dstSize];
}

-(UIImage *)cropCenterToSize:(CGSize)newSize
{
    float widthratio=self.size.width/newSize.width;
    float heightratio=self.size.height/newSize.height;
    float finalratio=MIN(widthratio, heightratio);
    UIImage* cropped = [UIImage imageWithCGImage:self.CGImage scale:finalratio orientation:self.imageOrientation];
    
    CGRect rectimgView = CGRectMake(0,0,newSize.width,newSize.height);
    UIImageView *imgView=[[UIImageView alloc]initWithFrame:rectimgView];
    imgView.image=cropped;
    imgView.contentMode=UIViewContentModeCenter;
    imgView.clipsToBounds=YES;
    
    UIGraphicsBeginImageContext(rectimgView.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [imgView.layer renderInContext:context];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

-(UIImage *)optimizeImage
{
    if (self.size.width<=640 || self.size.height<=960)
    {
        return self;
    }
    else
    {
        float thewidth=640.0;
        float theheight=self.size.height*640.0/self.size.width;
        
        CGRect rectimgView = CGRectMake(0,0,thewidth,theheight);
        UIImageView *imgView=[[UIImageView alloc]initWithFrame:rectimgView];
        imgView.clipsToBounds=YES;
        imgView.image=self;
        UIGraphicsBeginImageContext(rectimgView.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [imgView.layer renderInContext:context];
        UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultingImage;
    }
}
-(UIImage *)addWaterMarkImage:(UIImage *)wmarkImage
{
    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0,0,self.size.width,self.size.height)];
    [wmarkImage drawInRect:CGRectMake(self.size.width*0.9f,self.size.height-self.size.width*0.1f,self.size.width*0.1f,self.size.width*0.1f)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultingImage;
}
- (UIImage *)orientationChange
{
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
