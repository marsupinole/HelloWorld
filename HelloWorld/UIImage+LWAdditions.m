//
//  UIImage+LWAdditions.m
//  LifeWalletMobile
//
//  Created by LifeWallet on 3/3/15.
//  Copyright (c) 2015 LifeWallet. All rights reserved.
//

#import "UIImage+LWAdditions.h"


@implementation UIImage (LWAdditions)
- (UIImage *)imageWithSize:(CGSize)size
{
    return [self imageWithSize:size options:LWImageResizeAspectSmallest];
}

- (UIImage *)imageWithSize:(CGSize)size preserveAspectRatio:(BOOL)preserveAspectRatio
{
    return [self imageWithSize:size options:(preserveAspectRatio ? LWImageResizeAspectSmallest : LWImageResizeStrech)];
}

- (UIImage *)imageWithSize:(CGSize)size options:(LWImageResizeOptions)options
{
    if (options != LWImageResizeStrech)
    {
        CGFloat hscale = size.width / self.size.width;
        CGFloat vscale = size.height / self.size.height;
        CGFloat sizeScale = 1.0f;
        
        switch (options) {
            case LWImageResizeAspectLargest:
                sizeScale = MAX(hscale, vscale);
                break;
                
            case LWImageResizeAspectSmallest:
                sizeScale = MIN(hscale, vscale);
                break;
                
            default:
                break;
        }
        size.width = self.size.width * sizeScale;
        size.height = self.size.height * sizeScale;
    }
    
    CGRect resizedRect = CGRectIntegral(CGRectMake(0, 0, size.width, size.height));
    CGImageRef imageRef = self.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, 0, size.height);
    CGContextScaleCTM(bitmap, 1, -1);
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
    CGContextDrawImage(bitmap, resizedRect, imageRef);
    
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    UIGraphicsEndImageContext();
    CGImageRelease(newImageRef);
    return newImage;
}

- (UIImage *)imageWithMaxBounds:(CGSize)maxBounds
{
    return [self imageWithSize:maxBounds options:LWImageResizeAspectSmallest];
}

- (UIImage *)imageWithCropRect:(CGRect)cropRect
{
    UIImage *croppedImage = nil;
    if (cropRect.size.width != 0 && cropRect.size.height != 0) {
        CGFloat	scale = self.scale;
        if (scale != 1)
        {
            cropRect.origin.x *= scale;
            cropRect.origin.y *= scale;
            cropRect.size.width *= scale;
            cropRect.size.height *= scale;
        }
        
        CGImageRef cropped = CGImageCreateWithImageInRect([self CGImage], cropRect);
        croppedImage = [UIImage imageWithCGImage:cropped scale:scale orientation:self.imageOrientation];
        CGImageRelease(cropped);
    }
    
    return croppedImage;
}



/**
 * Multiplies base image with tint and returns resulting image.
 **/
- (UIImage *)imageWithTint:(UIColor *)tint
{
    CGRect wholeImageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    // Fill the whole rect with tint color.
    [tint set];
    UIRectFill(wholeImageRect);
    
    // C = D * Sa. So left with the tint color multiplied with image alpha.
    [self drawInRect:wholeImageRect blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    // Now blend the existing tint color with the color from the image.
    [self drawInRect:wholeImageRect blendMode:kCGBlendModeMultiply alpha:1.0];
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 * Creates an image with color that uses this image's alpha mask.
 **/
- (UIImage *)imageMaskWithColor:(UIColor *)color
{
    CGRect wholeImageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // Flip context because CG has upside-down coord system... o_O
    CGContextScaleCTM(contextRef, 1, -1);
    CGContextTranslateCTM(contextRef, 0, -self.size.height);
    
    // Draw the color with image mask.
    CGContextSaveGState(contextRef);
    CGContextClipToMask(contextRef, wholeImageRect, self.CGImage);
    CGContextSetBlendMode(contextRef, kCGBlendModeMultiply);
    CGContextSetFillColorWithColor(contextRef, color.CGColor);
    CGContextFillRect(contextRef, wholeImageRect);
    
    CGContextRestoreGState(contextRef);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(UIImage*)image:(UIImage*)image inRect:(CGRect)rect withBacking:(UIColor*)color
{
    CGRect wholeImageRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // Flip context because CG has upside-down coord system... o_O
    CGContextScaleCTM(contextRef, 1, -1);
    CGContextTranslateCTM(contextRef, 0, -rect.size.height);
    
    CGContextSaveGState(contextRef);
    CGContextSetFillColorWithColor(contextRef, color.CGColor);
    CGContextFillRect(contextRef, wholeImageRect);
    
    CGRect imageRect;
    imageRect.origin.x = round(CGRectGetMidX(rect)-image.size.width/2);
    imageRect.origin.y = round(CGRectGetMidY(rect)-image.size.height/2);
    imageRect.size = image.size;
    CGContextDrawImage(contextRef, imageRect, image.CGImage);
    
    CGContextRestoreGState(contextRef);
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageWithSolidColor:(UIColor *)color atSize:(CGSize)size
{
    NSParameterAssert(color);
    NSParameterAssert(size.width > 0 && size.height > 0);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextRef, color.CGColor);
    CGContextFillRect(contextRef, rect);
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
/**
 * Composites baseImage with overlayImage and given blend mode.
 **/
- (UIImage *)imageWithComposite:(UIImage *)composite blendMode:(CGBlendMode)blendMode
{
    return [self imageWithComposite:composite blendMode:blendMode dstRect:CGRectMake(0, 0, self.size.width, self.size.height)];
}

- (UIImage *)getImageFromSize:(CGSize)size{
    CGFloat newHeight = size.height;
    CGFloat newWidth = size.width;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [[UIScreen mainScreen] scale]);
    //[self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

/**
 * Composites baseImage with overlayImage and given blend mode.
 * Composite drawn at given dstRect.
 **/
- (UIImage *)imageWithComposite:(UIImage *)composite blendMode:(CGBlendMode)blendMode dstRect:(CGRect)dstRect
{
    CGRect wholeImageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // Flip context and dstRect because CG has upside-down coord system... o_O
    CGContextScaleCTM(contextRef, 1, -1);
    CGContextTranslateCTM(contextRef, 0, -self.size.height);
    dstRect.origin.y = CGRectGetHeight(wholeImageRect) - CGRectGetMaxY(dstRect);
    
    CGContextSaveGState(contextRef);
    
    // Start with base image.
    CGContextSetBlendMode(contextRef, kCGBlendModeNormal);
    CGContextDrawImage(contextRef, wholeImageRect, self.CGImage);
    
    // Draw the composite image on top.
    CGContextSetBlendMode(contextRef, blendMode);
    CGContextDrawImage(contextRef, dstRect, composite.CGImage);
    
    CGContextRestoreGState(contextRef);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)imageByRemovingPath:(UIBezierPath *)path
{
    UIImage *image = nil;
    
    CGImageRef masterImage = [self CGImage];
    CGFloat imageWidth = CGImageGetWidth(masterImage);
    CGFloat imageHeight = CGImageGetHeight(masterImage);
    
    size_t bitsPerComponent = 8;
    size_t bitmapBytesPerRow = (imageWidth * 4);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, imageWidth, imageHeight, bitsPerComponent, bitmapBytesPerRow, colorspace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    
    if (context != NULL)
    {
        CGContextSaveGState(context);
        
        CGRect imageFrame = CGRectMake(0.0f, 0.0f, imageWidth, imageHeight);
        
        CGContextDrawImage(context, imageFrame, masterImage);
        
        CGFloat scale = [self scale];
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, 0.0f, -imageHeight);
        
        [path applyTransform:CGAffineTransformMakeScale(scale, scale)];
        CGContextAddPath(context, [path CGPath]);
        CGContextSetBlendMode(context, kCGBlendModeClear);
        CGContextFillPath(context);
        
        CGContextRestoreGState(context);
        masterImage = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        
        image = [[UIImage alloc] initWithCGImage:masterImage scale:scale orientation:[self imageOrientation]];
        CGImageRelease(masterImage);
    }
    CGColorSpaceRelease(colorspace);
    
    return image;
}


/**
 * Pixel color at (x, y) ARGB 1-byte each.
 **/
- (NSUInteger)colorAtPixelX:(NSUInteger)x y:(NSUInteger)y
{
    NSParameterAssert(x < self.size.width && y < self.size.height);
    
    CGFloat scale = self.scale;
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, CGRectMake(x * scale, y * scale, 1, 1));
    NSUInteger pixelHex = NSUIntegerMax;
    NSParameterAssert(imageRef);
    if (imageRef)
    {
        uint8_t pixelData[4];
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(pixelData, 1, 1, 8, 4, colorSpaceRef, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
        CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), imageRef);
        CGColorSpaceRelease(colorSpaceRef);
        CGContextRelease(context);
        CGImageRelease(imageRef);
        
        pixelHex = ((uint32_t)pixelData[0] << 24) + ((uint32_t)pixelData[1] << 16) + ((uint32_t)pixelData[2] << 8) + ((uint32_t)pixelData[3]);
    }
    return pixelHex;
}

- (void)debugShowInKeyWindow
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    imageView.center = keyWindow.center;
    [keyWindow addSubview:imageView];
}


+ (UIImage *)uncachedImageNamed:(NSString *)imageName
{
    NSString *base = [imageName stringByDeletingPathExtension];
    NSString *extension = [imageName pathExtension];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:base ofType:[extension length] ? extension : @"png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
    
    return image;
}

+ (UIImage*)makeDottedLineImageinRect:(CGRect)rect
{
    UIImage* imageout = nil;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate (NULL,
                                                  (int)rect.size.width, (int)rect.size.height,
                                                  8,
                                                  0,
                                                  colorSpace,
                                                  (kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst));
    CGColorSpaceRelease(colorSpace);
    
    if (context != NULL)
    {
        UIGraphicsPushContext(context);
        CGContextSaveGState(context);
        
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
        CGFloat dashArray[] = {1,2};
        CGContextSetLineDash(context, 1, dashArray, 2);
        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
        CGContextStrokePath(context);
        
        CGContextRestoreGState(context);
        UIGraphicsPopContext();
        
        CGImageRef theCGImage = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        
        CGImageRef other = CGImageCreateWithImageInRect(theCGImage,rect);
        CGImageRelease(theCGImage);
        imageout = [UIImage imageWithCGImage:other];
        CGImageRelease(other);
    }
    return imageout;
}

+ (UIImage *)scaledImageWithData:(NSData *)data
{
    UIImage *image = [UIImage imageWithData:data];
    
    UIScreen *screen = [UIScreen mainScreen];
    if ([screen respondsToSelector:@selector(scale)])
    {
        CGFloat scale = screen.scale;
        
        if (scale > 1)
        {
            image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
        }
    }
    
    return image;
}

+ (UIImage *)scaledImageWithImage:(UIImage *)image{

    UIScreen *screen = [UIScreen mainScreen];
    if ([screen respondsToSelector:@selector(scale)])
    {
        CGFloat scale = screen.scale;
        
        if (scale > 1)
        {
            image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
        }
    }
    
    return image;
}

+ (UIImage *)colorSliceImageWithColor:(UIColor *)color height:(CGFloat)height {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0, height), NO, [[UIScreen mainScreen] scale]);
    
    [color setFill];
    UIRectFillUsingBlendMode((CGRect){0, 0, 1.0, height}, kCGBlendModeNormal);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


#define CONTINUOUS_CURVES_SIZE_FACTOR (1.528665)

+ (UIImage *)roundedCornerRectangleWithColor:(UIColor *) color
{
    CGFloat cornerRadius = 3.0;
    
    CGFloat capSize = ceilf(cornerRadius * CONTINUOUS_CURVES_SIZE_FACTOR);
    CGFloat rectSize = 2.0 * capSize + 1.0;
    CGRect rect = CGRectMake(0.0, 0.0, rectSize, rectSize);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    [color set];
    CGRect pathRect = rect;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:cornerRadius];
    [path fill];
    
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(capSize, capSize, capSize, capSize)];
    backgroundImage = [backgroundImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    return backgroundImage;
}

+ (UIImage *)roundedCornerRectangleWithColorNoTemplate:(UIColor *) color
{
    CGFloat cornerRadius = 3.0;
    
    CGFloat capSize = ceilf(cornerRadius * CONTINUOUS_CURVES_SIZE_FACTOR);
    CGFloat rectSize = 2.0 * capSize + 1.0;
    CGRect rect = CGRectMake(0.0, 0.0, rectSize, rectSize);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    [color set];
    CGRect pathRect = rect;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:cornerRadius];
    [path fill];
    
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(capSize, capSize, capSize, capSize)];
    return backgroundImage;
}

- (UIImage *)makeRoundedImage:(UIImage *) image radius: (float) radius {
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    imageLayer.contents = (id) image.CGImage;
    
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = radius;
    
    UIGraphicsBeginImageContext(image.size);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

- (UIImage *)scaleToSize:(CGSize)size
{
    // Scalling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    if(self.imageOrientation == UIImageOrientationRight){
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), self.CGImage);
    }else{
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
    }
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage:scaledImage];
    
    CGImageRelease(scaledImage);
    
    return image;
}

- (UIImage *)scaleProportionalToSize:(CGSize)size
{
    if(self.size.width > self.size.height){
        size = CGSizeMake((self.size.width/self.size.height) * size.height,size.height);
    }
    else{
        size = CGSizeMake(size.width,(self.size.height/self.size.width) * size.width);
    }
    
    return [self scaleToSize:size];
}

- (UIImage *)croppedImageFromImage:(UIImage *)image withSize:(CGSize)size{
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGFloat xOffset = ((width - size.width)/2);
    CGFloat yOffset = ((height - size.height)/2);
    
    CGRect cropRect = CGRectMake(xOffset, yOffset, size.width, size.height);
    
    CGFloat	scale = self.scale;
    
    /* this will usually be 2 because most of our devices are retina displays */
    if (scale != 1)
    {
        cropRect.origin.x *= scale;
        cropRect.origin.y *= scale;
        cropRect.size.width *= scale;
        cropRect.size.height *= scale;
    }
    
    CGImageRef cropped = CGImageCreateWithImageInRect([self CGImage], cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:cropped scale:scale orientation:self.imageOrientation];
    CGImageRelease(cropped);
    return croppedImage;
    
}

- (UIImage *)croppedImageFromImage:(UIImage *)image withFrame:(CGRect)frame andScale:(CGFloat)scale{
    

    CGImageRef cropped = CGImageCreateWithImageInRect([self CGImage], frame);
    UIImage *croppedImage = [UIImage imageWithCGImage:cropped scale:scale orientation:self.imageOrientation];
    CGImageRelease(cropped);
    return croppedImage;
}

- (UIImage *)croppedImageWithImage:(UIImage *)image XOffset:(CGFloat)XOffset YOffset:(CGFloat)YOffset size:(CGSize)size{
    
    CGRect cropRect = CGRectMake(XOffset, YOffset, size.width, size.height);

    CGFloat	scale = self.scale;
    
    /* this will usually be 2 because most of our devices are retina displays */
    if (scale != 1)
    {
        cropRect.origin.x *= scale;
        cropRect.origin.y *= scale;
        cropRect.size.width *= scale;
        cropRect.size.height *= scale;
    }
    
    CGImageRef cropped = CGImageCreateWithImageInRect([self CGImage], cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:cropped scale:scale orientation:self.imageOrientation];
    CGImageRelease(cropped);
    return croppedImage;
    
}

- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp){
        
        return self;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end
