//
//  PhotoCropView.m
//  HealthBook
//
//  Created by Mike Leveton on 12/6/15.
//  Copyright © 2015 LifeWallet. All rights reserved.
//

#import "PhotoCropView.h"
#import "UIImage+PhotoCrop.h"


@interface PhotoCropView () <UIGestureRecognizerDelegate>

@property (nonatomic) UIImageView               *imageView;
@property (nonatomic) UIPanGestureRecognizer    *pan;
@property (nonatomic) UIPinchGestureRecognizer  *pinch;
@property (nonatomic) UIView                    *zoomingView;
@property (nonatomic) CGRect                    insetRect;
@property (nonatomic) CGFloat                   minimumImageXOffset;
@property (nonatomic) CGFloat                   minimumImageYOffset;
@property (nonatomic) CGFloat                   trackerScale;
@property (nonatomic) CGFloat                   currentImageScale;
@property (nonatomic) CGFloat                   calculatedImageWidth;
@property (nonatomic) CGFloat                   calculatedImageHeight;

@end

@implementation PhotoCropView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

#pragma mark - getters

- (UIImageView *)imageView{
    if (!_imageView){
        _imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [_imageView.layer setZPosition:3.0f];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_imageView setClipsToBounds:YES];
        [[self zoomingView] addSubview:_imageView];
        return _imageView;
    }
    return _imageView;
}

- (UIView *)zoomingView{
    if (!_zoomingView){
        _zoomingView = [[UIView alloc]initWithFrame:CGRectZero];
        [_zoomingView setBackgroundColor:[UIColor clearColor]];
        [_zoomingView setUserInteractionEnabled:YES];
        [_zoomingView addGestureRecognizer:[self pinch]];
        [_zoomingView addGestureRecognizer:[self pan]];
        [self addSubview:_zoomingView];
        return _zoomingView;
    }
    
    return _zoomingView;
}


- (CGFloat)cropAspectRatio
{
    CGRect cropRect = _imageView.frame;
    CGFloat width = CGRectGetWidth(cropRect);
    CGFloat height = CGRectGetHeight(cropRect);
    return width / height;
}

- (UIImage *)croppedImage
{
    return [_image rotatedImageWithtransform:self.rotation croppedToRect:[self zoomedCropRect]];;
}

- (CGAffineTransform)rotation
{
    return _imageView.transform;
}

- (UIPanGestureRecognizer *)pan{
    if (!_pan){
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleImagePan:)];
        [_pan setMinimumNumberOfTouches:1];
    }
    return _pan;
}

- (UIPinchGestureRecognizer *)pinch{
    if (!_pinch){
        _pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    }
    return _pinch;
}


#pragma mark - setters

- (void)setImage:(UIImage *)image
{
    _image = image;
    //_defaultImageLength = image.size.width;
    //todo: make this defaultimagelength calulated so that it's either it's real width, or, if it's width is too big, 75% of the viewFinder's width.
    
    if (_image.size.width > _image.size.height){
        if (_image.size.width > _defaultImageLength){
            _calculatedImageWidth  = _defaultImageLength * (_image.size.width/_image.size.height);
            _calculatedImageHeight = _defaultImageLength;
        }else{
            _calculatedImageWidth  = _defaultImageLength * (_image.size.width/_image.size.height);
            _calculatedImageHeight = _defaultImageLength;
        }
    }else{
        if (_image.size.height > _defaultImageLength){
            _calculatedImageHeight  = _defaultImageLength * (_image.size.height/_image.size.width);
            _calculatedImageWidth   = _defaultImageLength;
        }else{
            _calculatedImageHeight  = _defaultImageLength * (_image.size.height/_image.size.width);
            _calculatedImageWidth   = _defaultImageLength;
        }
    }
    /* don't use layoutsubviews, it gets called everytime you pinch */
    CGRect imageFrame = [[self imageView] frame];
    imageFrame.origin.x     = 0.0f;
    imageFrame.origin.y     = 0.0f;
    imageFrame.size.width   = _calculatedImageWidth;
    imageFrame.size.height  = _calculatedImageHeight;
    [[self imageView] setFrame:imageFrame];
    
    _image = [self resizeImage:_image imageSize:CGSizeMake(_calculatedImageWidth, _calculatedImageHeight)];
    //NSLog(@"image width: %f", _image.size.width);
    //NSLog(@"image height: %f", _image.size.height);
    [[self imageView] setImage:_image];
    
    
    [self setUpCroppingAndInsetRect];
    
//    NSLog(@"super view: %@", self.superview);
//    NSLog(@"super view x: %f", self.superview.bounds.origin.x);
//    NSLog(@"super view y: %f", self.superview.bounds.origin.y);
//    NSLog(@"super view width: %f", self.superview.bounds.size.width);
//    NSLog(@"super view height: %f", self.superview.bounds.size.height);
    
}

- (void)setOverlaySize:(CGSize)overlaySize{
    _overlaySize = overlaySize;
    [self setUpCroppingAndInsetRect];
}

- (void)setOverlayXOffset:(CGFloat)overlayXOffset{
    _overlayXOffset = overlayXOffset;
    [self setUpCroppingAndInsetRect];
}

- (void)setOverlayYOffset:(CGFloat)overlayYOffset{
    _overlayYOffset = overlayYOffset;
    [self setUpCroppingAndInsetRect];
}

- (void)setDefaultImageLength:(CGFloat)defaultImageLength{
    _defaultImageLength = defaultImageLength;
    /* should be set after overlay offsets are set */
    [self setUpCroppingAndInsetRect];
}

- (void)setUpCroppingAndInsetRect{
    CGRect rect = CGRectZero;
    CGFloat XOffset  = _overlayXOffset -  (_calculatedImageWidth - _overlaySize.width)/2;
    CGFloat YOffset  = _overlayYOffset -  (_calculatedImageHeight - _overlaySize.height)/2;
    rect.origin.x    = XOffset;
    rect.origin.y    = YOffset;
    rect.size.width  = _calculatedImageWidth;
    rect.size.height = _calculatedImageHeight;
    [[self zoomingView] setFrame:rect];
    _insetRect       = rect;
    _minimumImageXOffset = (_overlayXOffset + _overlaySize.width) - _calculatedImageWidth;
    _minimumImageYOffset = (_overlayYOffset + _overlaySize.height) - _calculatedImageHeight;
}

#pragma mark - actions

- (UIImage *)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

- (void)handleImagePan:(UIPanGestureRecognizer *)pan{
    
    if (pan.state == UIGestureRecognizerStateChanged){
        CGRect imageFrame = [[pan view] frame];
        
        CGPoint translation = [pan translationInView:pan.view.superview];
        pan.view.center = CGPointMake(pan.view.center.x + translation.x,
                                      pan.view.center.y + translation.y);
        
        CGFloat originX = pan.view.frame.origin.x;
        CGFloat originY = pan.view.frame.origin.y;
        //NSLog(@"pan x: %f", originX);
        //NSLog(@"pan y: %f", originY);
        
        if (originX < _overlayXOffset && originY < _overlayYOffset && originX > _minimumImageXOffset && originY > _minimumImageYOffset){
            [pan setTranslation:CGPointMake(0, 0) inView:pan.view.superview];
        }else{
            [[pan view] setFrame:imageFrame];
            [pan setTranslation:CGPointMake(0, 0) inView:pan.view.superview];
        }
    }
    
    if (pan.state == UIGestureRecognizerStateEnded){
        _minimumImageXOffset = (_overlayXOffset + _overlaySize.width) - pan.view.frame.size.width;
        _minimumImageYOffset = (_overlayYOffset + _overlaySize.height) - pan.view.frame.size.height;
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch {
    
    if([pinch state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        _trackerScale = [pinch scale];
        
        //NSLog(@"pinch width: %f", [pinch view].frame.size.width);
        //NSLog(@"pinch height: %f", [pinch view].frame.size.height);
    }
    
    if ([pinch state] == UIGestureRecognizerStateBegan ||
        [pinch state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[[pinch view].layer valueForKeyPath:@"transform.scale"] floatValue];
        _currentImageScale = currentScale;
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 2.2;
        const CGFloat kMinScale = 0.64;
        
        CGFloat newScale = 1 -  (_trackerScale - [pinch scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[pinch view] transform], newScale, newScale);
        [pinch view].transform = transform;
        
        [pinch setScale:1.0];
        
        _trackerScale = [pinch scale];  // Store the previous scale factor for the next pinch gesture call
        
        //NSLog(@"pinch width: %f", [pinch view].frame.size.width);
        //NSLog(@"pinch height: %f", [pinch view].frame.size.height);
    }
}

#pragma mark - frames

- (CGRect)cropRect
{
    return _imageView.frame;
}

- (CGRect)overlayFrame{
    
    CGRect frame = CGRectZero;
    frame.origin.x = _overlayXOffset;
    frame.origin.y = _overlayYOffset;
    frame.size.width = _overlaySize.width;
    frame.size.height = _overlaySize.height;
    
    return frame;
}

- (CGRect)zoomedCropRect
{
    
    CGRect cropRect = [self convertRect:[self overlayFrame] toView:_zoomingView];
    
    CGSize size = _image.size;
    
    CGFloat ratio = 1.0f;
    
    ratio = CGRectGetWidth(AVMakeRectWithAspectRatioInsideRect(_image.size, _insetRect)) / size.width;
    
    CGRect zoomedCropRect = CGRectMake(cropRect.origin.x / ratio,
                                       cropRect.origin.y / ratio,
                                       cropRect.size.width / ratio,
                                       cropRect.size.height / ratio);
    
    return zoomedCropRect;
}

@end
