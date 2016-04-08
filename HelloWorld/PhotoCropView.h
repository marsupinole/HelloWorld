//
//  PhotoCropView.h
//  HelloWorld
//
//  Created by Mike Leveton on 12/6/15.
//  Copyright © 2015 Mike Leveton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface PhotoCropView : UIView

@property (nonatomic) UIImage *image;
@property (nonatomic, readonly) UIImage *croppedImage;
@property (nonatomic, readonly) CGAffineTransform rotation;
@property (nonatomic, readonly) CGRect zoomedCropRect;
@property (nonatomic, readonly) CGSize overlaySize;
@property (nonatomic, readonly) CGFloat overlayXOffset;
@property (nonatomic, readonly) CGFloat overlayYOffset;
@property (nonatomic, readonly) CGFloat defaultImageLength;


- (void)setOverlaySize:(CGSize)overlaySize;
- (void)setOverlayXOffset:(CGFloat)overlayXOffset;
- (void)setOverlayYOffset:(CGFloat)overlayYOffset;
- (void)setDefaultImageLength:(CGFloat)defaultImageLength;

@end
