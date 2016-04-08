#import <UIKit/UIKit.h>
typedef enum {
    LWImageResizeStrech,
    LWImageResizeAspectSmallest,
    LWImageResizeAspectLargest
} LWImageResizeOptions;

@interface UIImage (Additions)
// preserves aspect ratio by default
- (UIImage *)imageWithSize:(CGSize)size;
- (UIImage *)imageWithSize:(CGSize)size preserveAspectRatio:(BOOL)preserveAspectRatio;
- (UIImage *)imageWithSize:(CGSize)size options:(LWImageResizeOptions)options;
- (UIImage *)imageWithMaxBounds:(CGSize)maxBounds;

// Makes an image from another image, reusing existing pixels to prevent copying memory
- (UIImage *)imageWithCropRect:(CGRect)cropRect;

- (UIImage *)imageWithTint:(UIColor *)tint;
- (UIImage *)imageMaskWithColor:(UIColor *)color;
- (UIImage *)imageWithComposite:(UIImage *)composite blendMode:(CGBlendMode)blendMode;
- (UIImage *)imageWithComposite:(UIImage *)composite blendMode:(CGBlendMode)blendMode dstRect:(CGRect)dstRect;
- (UIImage *)imageByRemovingPath:(UIBezierPath *)path;
- (UIImage *)croppedImageFromImage:(UIImage *)image withSize:(CGSize)size;
- (UIImage *)croppedImageFromImage:(UIImage *)image withFrame:(CGRect)frame andScale:(CGFloat)scale;

// Rotates the image to be the correct orientation
- (UIImage *)normalizedImage;

- (NSUInteger)colorAtPixelX:(NSUInteger)x y:(NSUInteger)y;

- (void)debugShowInKeyWindow;

+ (UIImage *)uncachedImageNamed:(NSString *)imageName;
+ (UIImage *)makeDottedLineImageinRect:(CGRect)rect;
+ (UIImage *)image:(UIImage*)image inRect:(CGRect)rect withBacking:(UIColor*)color;
+ (UIImage *)imageWithSolidColor:(UIColor *)color atSize:(CGSize)size;

// Will create an image from NSData with proper scale factor for current device
+ (UIImage *)scaledImageWithData:(NSData *)data;

// Like scaledImageWithData: but with an image
+ (UIImage *)scaledImageWithImage:(UIImage *)image;

+ (UIImage *)colorSliceImageWithColor:(UIColor *)color height:(CGFloat)height;
+ (UIImage *)roundedCornerRectangleWithColor:(UIColor *) color;
+ (UIImage *)roundedCornerRectangleWithColorNoTemplate:(UIColor *) color;
- (UIImage *)makeRoundedImage:(UIImage *)image radius:(float)radius;
- (UIImage *)scaleProportionalToSize:(CGSize)size;
@end
