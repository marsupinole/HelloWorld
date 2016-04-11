//
//  ViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "ViewController.h"

#define kImageWidth (320.0f)

@interface ViewController ()
@property (nonatomic, strong) UILabel  *label;
@property (nonatomic, strong) UIButton *button;
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
    
    CGRect buttonFrame   = [[self button] frame];
    buttonFrame.size     = CGSizeMake(kImageWidth, kImageWidth);
    buttonFrame.origin.y = CGRectGetMaxY(labelFrame);
    buttonFrame.origin.x = (CGRectGetWidth([[self view] frame]) - buttonFrame.size.width)/2;
    [[self button] setFrame:buttonFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UILabel *)label{
    if (!_label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setText:@"Research Kit"];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [[self view] addSubview:_label];
        return _label;
    }
    return _label;
}

- (UIButton *)button{
    if (!_button){
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
        [_button setTitle:@"launch RK" forState:UIControlStateNormal];
        [[_button titleLabel] setTextAlignment:NSTextAlignmentCenter];
        [[self view] addSubview:_button];
        return _button;
    }
    return _button;
}

#pragma mark - selectors

- (void)didTapButton:(id)sender{
    
}

@end
