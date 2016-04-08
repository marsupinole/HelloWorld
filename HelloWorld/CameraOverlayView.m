//
//  CameraOverlayView.m
//  HelloWorld
//
//  Created by Mike Leveton on 11/6/15.
//  Copyright © 2015 Mike Leveton. All rights reserved.
//

#import "CameraOverlayView.h"

@interface CameraOverlayView()
@property (nonatomic, strong) UIColor *color;
@end

@implementation CameraOverlayView

-(id)initWithViewSize:(CGSize)viewSize cardSize:(CGSize)cardSize andColor:(UIColor *)color{
    self = [super init];
    
    if (self){
        _viewSize = viewSize;
        _cardSize = cardSize;
        _cardXOffset = (_viewSize.width - _cardSize.width)/2;
        _cardYOffset = (_viewSize.height - _cardSize.height)/2;
        _color = color;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setContentMode:UIViewContentModeRedraw];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(_cardXOffset + _cardSize.width, _cardYOffset)];
    [bezierPath addLineToPoint: CGPointMake(_cardXOffset, _cardYOffset)];
    [bezierPath addLineToPoint: CGPointMake(_cardXOffset, _viewSize.height - _cardYOffset)];
    [bezierPath addLineToPoint: CGPointMake(_cardXOffset + _cardSize.width, _viewSize.height - _cardYOffset)];
    [bezierPath addLineToPoint: CGPointMake(_cardXOffset + _cardSize.width, _cardYOffset)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(_viewSize.width, 0)];
    [bezierPath addCurveToPoint: CGPointMake(_viewSize.width, _viewSize.height) controlPoint1: CGPointMake(_viewSize.width, 0) controlPoint2: CGPointMake(_viewSize.width, _viewSize.height)];
    [bezierPath addLineToPoint: CGPointMake(0, _viewSize.height)];
    [bezierPath addLineToPoint: CGPointMake(0, 0)];
    [bezierPath addLineToPoint: CGPointMake(_viewSize.width, 0)];
    [bezierPath addLineToPoint: CGPointMake(_viewSize.width, 0)];
    [bezierPath closePath];
    [_color setFill];
    [bezierPath fill];
}


@end
