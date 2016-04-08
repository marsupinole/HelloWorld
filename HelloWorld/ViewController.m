//
//  ViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"
#import "UIImage+Additions.h"

#define kInsuranceCardButtonWidth                        (320.0f)
#define kImageRadius                (8.0f)

@interface ViewController ()<CameraViewControllerDelegate>
@property (nonatomic, strong) UILabel     *label;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect labelFrame = [[self label] frame];
    labelFrame.origin.y    = 20.0f;
    labelFrame.size.height = 60.0f;
    labelFrame.size.width  = CGRectGetWidth([[self view] frame]);
    [[self label] setFrame:labelFrame];
    
    CGRect imageFrame = [[self imageView] frame];
    imageFrame.size     = CGSizeMake(kInsuranceCardButtonWidth, kInsuranceCardButtonWidth);
    imageFrame.origin.y = CGRectGetMaxY(labelFrame);
    imageFrame.origin.x = (CGRectGetWidth([[self view] frame]) - imageFrame.size.width)/2;
    [[self imageView] setFrame:imageFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (void)didTap:(id)sender{
    
    [self presentCamera];
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
    [camera setCardSize:CGSizeMake(kInsuranceCardButtonWidth*2, kInsuranceCardButtonWidth*2)];
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
        anImage = [anImage croppedImageFromImage:anImage withSize:CGSizeMake(kInsuranceCardButtonWidth*1.5, kInsuranceCardButtonWidth*1.5)];
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
