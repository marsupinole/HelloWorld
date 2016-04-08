//
//  ViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 3/14/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "MELExpandingTextCell.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, MELExpandingTextCellDelegate>
@property (nonatomic, strong) UILabel     *label;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect labelFrame = [[self label] frame];
    labelFrame.origin.y = 20.0f;
    labelFrame.size.height = 60.0f;
    labelFrame.size.width = CGRectGetWidth([[self view] frame]);
    [[self label] setFrame:labelFrame];
    
    CGRect tableFrame = [[self tableView] frame];
    tableFrame.origin.y = CGRectGetMaxY(labelFrame);
    tableFrame.size.height = CGRectGetHeight([[self view] frame]) - tableFrame.origin.y;
    tableFrame.size.width = CGRectGetWidth([[self view] frame]);
    [[self tableView] setFrame:tableFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UILabel *)label{
    if (!_label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setText:@"Dynamic"];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [[self view] addSubview:_label];
        return _label;
    }
    return _label;
}

- (UITableView *)tableView{
    if (!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setAllowsSelectionDuringEditing:YES];
        [_tableView setEditing:YES];
        [[self view] addSubview:_tableView];
    }
    return _tableView;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 3){
        MELExpandingTextCell *cell = [MELExpandingTextCell new];
        [cell setDelegate:self];
        [[cell textView] setText:@"lorem ipsum"];
        [[cell placeholder] setText:@"hi mike"];
        [[cell placeholder] setHidden:YES];
        [cell setEditing:YES];
        return cell;
    }
    
    return [UITableViewCell new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 100.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3){
        return 150.0f;
    }
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //MELExpandingTextCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //[[cell textView] becomeFirstResponder];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

#pragma mark - MELExpandingTextCellDelegate

- (void)setUpheightForTextViewWithHeight:(CGFloat)height{
    
}
- (CGFloat)getTextViewHeight{
    return 100.0f;
}
- (void)adjustScrollViewWithHeight:(CGFloat)height{
    
}
- (void)didUpdateText:(NSString *)text{
    
}
- (void)adjustDynamicCellIsFirstResponder:(BOOL)isFirstResponder{
    
}

@end
