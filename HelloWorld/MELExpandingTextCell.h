//
//  MELExpandingTextCell.h
//  HelloWorld
//
//  Created by Mike Leveton on 4/8/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kReviewPropertyNotesCellHeight          (250.0f)
#define kDynamicCellTextPadding                 (12.0f)

@protocol MELExpandingTextCellDelegate;

@interface MELExpandingTextCell : UITableViewCell
@property (nonatomic, weak) id <MELExpandingTextCellDelegate>    delegate;
@property (nonatomic, strong) UITextView                         *textView;
@property (nonatomic, strong) UILabel                            *placeholder;
@end

@protocol MELExpandingTextCellDelegate <NSObject>

@optional

- (void)setUpheightForTextViewWithHeight:(CGFloat)height;
- (CGFloat)getTextViewHeight;
- (void)adjustScrollViewWithHeight:(CGFloat)height;
- (void)didUpdateText:(NSString *)text;
- (void)adjustDynamicCellIsFirstResponder:(BOOL)isFirstResponder;

@end


