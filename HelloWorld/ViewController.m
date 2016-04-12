//
//  ViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//


/*Cropper - Only check out of bounds on cropper if it's at the stop event and then pop back*/


#import "ViewController.h"
#import "CameraViewController.h"
#import "UIImage+Additions.h"
#import "CropView.h"

#define imageWidth                                       (320.0f)
#define imageToCropWidth                                 (340.0f)
#define kImageRadius                                     (8.0f)

@interface ViewController ()<CameraViewControllerDelegate>
@property (nonatomic, strong) UILabel     *label;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *cropImageView;

@property (nonatomic, strong) CropView      *cropView;
@property (nonatomic, strong) UIImageView *imageToCrop;
@property (nonatomic, assign) CGFloat     trackerScale;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect imageToCropFrame = [[self imageToCrop] frame];
    imageToCropFrame.size      = CGSizeMake(imageToCropWidth, imageToCropWidth);
    imageToCropFrame.origin.y  = (CGRectGetHeight([[self view] frame]) - imageToCropFrame.size.height)/2;
    imageToCropFrame.origin.x  = (CGRectGetWidth([[self view] frame]) - imageToCropFrame.size.width)/2;
    [[self imageToCrop] setFrame:imageToCropFrame];
    
    CGRect cropFrame = [[self cropView] frame];
    cropFrame.size      = CGSizeMake(imageWidth, imageWidth);
    cropFrame.origin.y  = (CGRectGetHeight([[self view] frame]) - cropFrame.size.height)/2;
    cropFrame.origin.x  = (CGRectGetWidth([[self view] frame]) - cropFrame.size.width)/2;
    [[self cropView] setFrame:cropFrame];
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    NSLog(@"layout called");
    CGRect labelFrame = [[self label] frame];
    labelFrame.origin.y    = 20.0f;
    labelFrame.size.height = 60.0f;
    labelFrame.size.width  = CGRectGetWidth([[self view] frame]);
    [[self label] setFrame:labelFrame];
    
    CGRect imageFrame = [[self imageView] frame];
    imageFrame.size     = CGSizeMake(imageWidth, imageWidth);
    //imageFrame.origin.y = CGRectGetMaxY(labelFrame);
    //imageFrame.origin.x = (CGRectGetWidth([[self view] frame]) - imageFrame.size.width)/2;
    [[self imageView] setFrame:imageFrame];
    
    CGRect cropImageFrame = [[self cropImageView] frame];
    cropImageFrame.size     = CGSizeMake(imageWidth, imageWidth);
    //cropImageFrame.origin.y = CGRectGetMaxY(labelFrame);
    cropImageFrame.origin.x = CGRectGetWidth([[self view] frame]) - cropImageFrame.size.width;
    [[self cropImageView] setFrame:cropImageFrame];
    
//    CGRect imageToCropFrame = [[self imageToCrop] frame];
//    imageToCropFrame.size      = CGSizeMake(imageToCropWidth, imageToCropWidth);
//    imageToCropFrame.origin.y  = (CGRectGetHeight([[self view] frame]) - imageToCropFrame.size.height)/2;
//    imageToCropFrame.origin.x  = (CGRectGetWidth([[self view] frame]) - imageToCropFrame.size.width)/2;
//    [[self imageToCrop] setFrame:imageToCropFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - views

- (UILabel *)label{
    if (!_label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setText:@"Crop"];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [[self view] addSubview:_label];
        return _label;
    }
    return _label;
}

- (UIImageView *)imageView{
    if (!_imageView){
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [[_imageView layer] setBorderColor:[UIColor blackColor].CGColor];
        [[_imageView layer] setBorderWidth:1.0f];
        [_imageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap:)];
        [_imageView addGestureRecognizer:tap];
        [[self view] addSubview:_imageView];
    }
    return _imageView;
}

- (UIImageView *)cropImageView{
    if (!_cropImageView){
        _cropImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [[_cropImageView layer] setBorderColor:[UIColor blackColor].CGColor];
        [[_cropImageView layer] setBorderWidth:1.0f];
        [_cropImageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapCrop:)];
        [_cropImageView addGestureRecognizer:tap];
        [[self view] addSubview:_cropImageView];
    }
    return _cropImageView;
}

- (UIImageView *)imageToCrop{
    if (!_imageToCrop){
        _imageToCrop = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_imageToCrop setImage:[UIImage imageNamed:@"imageToCrop"]];
        //[[_imageToCrop layer] setBorderColor:[UIColor redColor].CGColor];
        //[[_imageToCrop layer] setBorderWidth:1.0f];
        [_imageToCrop setUserInteractionEnabled:YES];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPan:)];
        //[_imageToCrop addGestureRecognizer:pan];
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(didPinch:)];
        [_imageToCrop addGestureRecognizer:pinch];
        [[self view] addSubview:_imageToCrop];
    }
    return _imageToCrop;
}

- (CropView *)cropView{
    if (!_cropView){
        _cropView = [[CropView alloc] initWithFrame:CGRectZero];
        //[_cropView setBackgroundColor:[UIColor blueColor]];
        //[[_cropView layer] setOpacity:0.0f];
        //[_cropView setAlpha:0.5];
        [[_cropView layer] setZPosition:1.0f];
        //[[_cropView layer] setBorderWidth:1.0f];
        [_cropView setUserInteractionEnabled:YES];
        //[[_cropView layer] setBorderColor:[UIColor blackColor].CGColor];
        [[self view] addSubview:_cropView];
        return _cropView;
    }
    return _cropView;
}

#pragma mark - selectors

- (void)didTap:(id)sender{
    
    [self presentCamera];
}

- (void)didTapCrop:(id)sender{
    
   
}

- (void)didPan:(UIPanGestureRecognizer *)pan{
    
//    if (pan.state == UIGestureRecognizerStateChanged){
//        
//        CGPoint translation = [pan translationInView:pan.view.superview];
//        pan.view.center = CGPointMake(pan.view.center.x + translation.x,
//                                      pan.view.center.y + translation.y);
//        
//
//        
//        [pan setTranslation:CGPointMake(0, 0) inView:pan.view.superview];
//    }
    
    [[pan view] setCenter:[pan locationInView:[[pan view] superview]]];
    
}

- (void)didPinch:(UIPinchGestureRecognizer *)recognizer{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    
//    pinch.view.transform = CGAffineTransformScale(pinch.view.transform, pinch.scale, pinch.scale);
//    pinch.scale = 1;
    
//    if([pinch state] == UIGestureRecognizerStateBegan) {
//        // Reset the last scale, necessary if there are multiple objects with different scales
//        _trackerScale = [pinch scale];
//        
//        //NSLog(@"pinch width: %f", [pinch view].frame.size.width);
//        //NSLog(@"pinch height: %f", [pinch view].frame.size.height);
//    }
//    
//    if ([pinch state] == UIGestureRecognizerStateBegan ||
//        [pinch state] == UIGestureRecognizerStateChanged) {
//        
//        CGFloat currentScale = [[[pinch view].layer valueForKeyPath:@"transform.scale"] floatValue];
//        //_currentImageScale = currentScale;
//        // Constants to adjust the max/min values of zoom
//        const CGFloat kMaxScale = 2.2;
//        const CGFloat kMinScale = 0.64;
//        
//        CGFloat newScale = 1 -  (_trackerScale - [pinch scale]);
//        newScale = MIN(newScale, kMaxScale / currentScale);
//        newScale = MAX(newScale, kMinScale / currentScale);
//        CGAffineTransform transform = CGAffineTransformScale([[pinch view] transform], newScale, newScale);
//        [pinch view].transform = transform;
//        
//        //[pinch setScale:1.0];
//        
//        _trackerScale = [pinch scale];  // Store the previous scale factor for the next pinch gesture call
//        
//        //NSLog(@"pinch width: %f", [pinch view].frame.size.width);
//        //NSLog(@"pinch height: %f", [pinch view].frame.size.height);
//    }
}


#pragma mark - camera

- (void)presentCamera{
    
    CameraViewController *camera = [[CameraViewController alloc]init];
    [camera setCameraShouldDefaultToFront:NO];
    [camera setViewFinderHasOverlay:YES];
    [camera setAllowsFlipCamera:YES];
    [camera setAllowsFlash:YES];
    [camera setAllowsPhotoRoll:YES];
    [camera setDelegate:self];
    [camera setShouldResizeToViewFinder:NO];
    [camera setCardSize:CGSizeMake(imageWidth*2, imageWidth*2)];
    [self presentViewController:camera animated:YES completion:^{
        
        [[camera view] setNeedsLayout];
    }];
}

- (void)CameraViewController:(CameraViewController *)camera didFinishWithImage:(UIImage *)image{
    
    CGFloat cameraWidth  = camera.viewFinderSize.width;
    CGFloat cameraHeight = camera.viewFinderSize.height;
    __block UIImage *anImage = image;
    
    [camera dismissViewControllerAnimated:YES completion:^{
        
        anImage = [anImage scaleProportionalToSize:CGSizeMake(cameraWidth, cameraHeight)];
        //todo: figure out why 1.5 works. it's a hack.
        anImage = [anImage croppedImageFromImage:anImage withSize:CGSizeMake(imageWidth*1.5, imageWidth*1.5)];
        anImage = [anImage makeRoundedImage:anImage radius:kImageRadius];
        
        [[self imageView] setImage:anImage];
        
    }];
    
}

- (void)CameraViewController:(CameraViewController *)controller didFinishCroppingImage:(UIImage *)image transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect{
    
    __block UIImage *anImage = image;
    [controller dismissViewControllerAnimated:YES completion:^{
        
        anImage = [anImage makeRoundedImage:anImage radius:kImageRadius];
        
        if (anImage){
            [[self imageView] setImage:anImage];
        }else{
            NSLog(@"reached no animage");
        }
        
    }];
}

@end
