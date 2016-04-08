//
//  CameraOverlayView.h
//  HelloWorld
//
//  Created by Mike Leveton on 11/6/15.
//  Copyright © 2015 Mike Leveton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraOverlayView : UIView

@property (nonatomic, assign) CGSize  viewSize;
@property (nonatomic, assign) CGSize  cardSize;
@property (nonatomic, assign) CGFloat cardXOffset;
@property (nonatomic, assign) CGFloat cardYOffset;

-(id)initWithViewSize:(CGSize)viewSize cardSize:(CGSize)cardSize andColor:(UIColor *)color;

@end
