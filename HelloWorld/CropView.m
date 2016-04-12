//
//  CropView.m
//  HelloWorld
//
//  Created by Mike Leveton on 4/12/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "CropView.h"

@implementation CropView

- (id)init{
    self = [super init];
    if (self){
        [self setBackgroundColor:[UIColor clearColor]];
        [self setContentMode:UIViewContentModeRedraw];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    UIColor *color = [UIColor blueColor];
    [color setFill];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return NO;
}

@end
