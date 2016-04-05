//
//  ViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "SSSearchBar.h"
#import "Car.h"

@interface ViewController ()<SSSearchBarDelegate>
@property (nonatomic, strong) UILabel *label;
@property (strong, nonatomic) SSSearchBar *searchBar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *addressEntity  = [NSEntityDescription entityForName:@"Car" inManagedObjectContext:context];
    Car *car0   = [[Car alloc] initWithEntity:addressEntity insertIntoManagedObjectContext:context];
    [car0 setDriver:@"mike"];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"save error: %@", error);
    }else{
        NSLog(@"save 0 ok");
    }
    
//    self.searchBar.cancelButtonHidden = NO;
//    self.searchBar.placeholder = NSLocalizedString(@"Search text here!", nil);
//    self.searchBar.delegate = self;
//    [self.searchBar becomeFirstResponder];
//    
//    self.data = @[ @"Hey there!", @"This is a custom UISearchBar.", @"And it's really easy to use...", @"Sweet!" ];
//    self.searchData = self.data;
    
    [[self searchBar] becomeFirstResponder];
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect labelFrame = [[self label] frame];
    labelFrame.origin.y = 20.0f;
    labelFrame.size.height = 60.0f;
    labelFrame.size.width = CGRectGetWidth([[self view] frame]);
    [[self label] setFrame:labelFrame];
    
    CGRect searchFrame = [[self searchBar] frame];
    searchFrame.size.height = 32.0f;
    searchFrame.size.width = 300.0f;
    searchFrame.origin.y = 90.0f;
    searchFrame.origin.x = [self horizontallyCenteredFrameForChildFrame:searchFrame].origin.x;
    [[self searchBar] setFrame:searchFrame];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UILabel *)label{
    if (!_label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setText:@"Present View Controller"];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [[self view] addSubview:_label];
        return _label;
    }
    return _label;
}

- (SSSearchBar *)searchBar{
    if (!_searchBar){
        _searchBar = [[SSSearchBar alloc] initWithFrame:CGRectZero];
        [_searchBar setDelegate:self];
        [_searchBar setPlaceholder:@"mike"];
        [_searchBar setBackgroundColor:[UIColor blueColor]];
        [[self view] addSubview:_searchBar];
        return _searchBar;
    }
    return _searchBar;
}

- (CGRect)horizontallyCenteredFrameForChildFrame:(CGRect)childRect{
    CGRect viewBounds = [[self view] bounds];
    CGFloat listMinX = CGRectGetMidX(viewBounds) - (CGRectGetWidth(childRect)/2);
    CGRect newChildFrame = CGRectMake(listMinX,
                                      CGRectGetMinY(childRect),
                                      CGRectGetWidth(childRect),
                                      CGRectGetHeight(childRect));
    return CGRectIntegral(newChildFrame);
}

@end
