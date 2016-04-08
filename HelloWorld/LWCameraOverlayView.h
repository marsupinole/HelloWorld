//
//  LWCameraOverlayView.h
//  Encounter
//
//  Created by Mike Leveton on 11/6/15.
//  Copyright © 2015 LifeWallet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWCameraOverlayView : UIView

@property (nonatomic, assign) CGSize  viewSize;
@property (nonatomic, assign) CGSize  cardSize;
@property (nonatomic, assign) CGFloat cardXOffset;
@property (nonatomic, assign) CGFloat cardYOffset;

-(id)initWithViewSize:(CGSize)viewSize cardSize:(CGSize)cardSize andColor:(UIColor *)color;

@end
