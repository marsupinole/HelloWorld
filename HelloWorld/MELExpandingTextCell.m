//
//  MELExpandingTextCell.m
//  HelloWorld
//
//  Created by Mike Leveton on 4/8/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

#import "MELExpandingTextCell.h"

@interface MELExpandingTextCell()<UITextViewDelegate>
@property (nonatomic, strong) NSDictionary                  *notesViewAttribs;
@property (nonatomic, assign) CGFloat                       lineHeightForTextView;
@property (nonatomic, assign) CGFloat                       textHeightForTextView;
@property (nonatomic, assign) NSInteger                     numberOfLinesForTextView;
@property (nonatomic, assign) NSInteger                     maxNumberOfLinesForTextView;

@property (nonatomic, strong) UIButton                     *button;
@end

@implementation MELExpandingTextCell

- (id)init{
    self = [super init];
    
    if (self){
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        UIFont *font = [UIFont fontWithName:@"ArialMT" size:15.0f];
        _notesViewAttribs = [NSDictionary dictionaryWithObjectsAndKeys:
                             font, NSFontAttributeName,
                             nil];
        
        /*allow approx 100kb per note message */
        _maxNumberOfLinesForTextView = 3000;
        
        
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(0, 0, 100, 100);
        [_button.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_button setBackgroundColor:[UIColor blueColor]];
        [_button addTarget:self action:@selector(toggleFilter:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    
    CGRect textViewFrame          = [[self textView] frame];
    textViewFrame.origin.x        = kDynamicCellTextPadding;
    textViewFrame.origin.y        = kDynamicCellTextPadding;
    
    if ([[self delegate] respondsToSelector:@selector(getTextViewHeight)]){
        CGFloat currentTextHeight = [[self delegate] getTextViewHeight] + kDynamicCellTextPadding;
        CGFloat minimumTextHeight = 70.0f - (kDynamicCellTextPadding * 2);
        textViewFrame.size.height = (currentTextHeight > minimumTextHeight) ? currentTextHeight : minimumTextHeight;
    }
    
    textViewFrame.size.width      = [UIScreen mainScreen].bounds.size.width - (kDynamicCellTextPadding * 2);
    [[self textView] setFrame:textViewFrame];
    
    CGRect placeholderTextFrame = [[self placeholder] frame];
    placeholderTextFrame.origin.x    = textViewFrame.origin.x;
    placeholderTextFrame.origin.y    = textViewFrame.origin.y;
    placeholderTextFrame.size.width  = textViewFrame.size.width;
    placeholderTextFrame.size.height = _lineHeightForTextView ? _lineHeightForTextView : 22.0f;
    [[self placeholder] setFrame:placeholderTextFrame];
    
    NSLog(@"editing: %ld", (long)self.isEditing);
    NSLog(@"enabled: %ld", (long)self.userInteractionEnabled);
    NSLog(@"enabled is: %ld", (long)self.isUserInteractionEnabled);
    
    //[self addSubview:_button];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - getters

- (UITextView *)textView{
    if (!_textView){
        _textView = [[UITextView alloc]initWithFrame:CGRectZero];
        [_textView setDelegate:self];
        UIFont *font = [UIFont fontWithName:@"ArialMT" size:15.0f];
        [_textView setFont:font];
        [_textView setTextColor:[UIColor darkGrayColor]];
        [_textView setBackgroundColor:[UIColor redColor]];
        [self addSubview:_textView];
    }
    
    return _textView;
}

-(UILabel *)placeholder{
    if (!_placeholder) {
        _placeholder = [[UILabel alloc] initWithFrame:CGRectZero];
        UIFont *font = [UIFont fontWithName:@"ArialMT" size:15.0f];
        [_placeholder setFont:font];
        [_placeholder setTextColor:[UIColor darkGrayColor]];
        [_placeholder.layer setZPosition:2.0f];
        //[_placeholder setBackgroundColor:[UIColor redColor] ];
        [self addSubview:_placeholder];
    }
    return _placeholder;
}

-(void)setPlaceholderText:(NSString *)placeholder{
    [[self placeholder] setText:placeholder];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    if ([self isEditing]){
        if ([[self delegate] respondsToSelector:@selector(adjustDynamicCellIsFirstResponder:)]){
            [[self delegate] adjustDynamicCellIsFirstResponder:YES];
        }
        [[self placeholder] setHidden:YES];
        return YES;
    }
    
    return NO;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    if ([[self delegate] respondsToSelector:@selector(adjustDynamicCellIsFirstResponder:)]){
        [[self delegate] adjustDynamicCellIsFirstResponder:NO];
    }
    [[self placeholder] setHidden:[textView hasText]];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ((_numberOfLinesForTextView > _maxNumberOfLinesForTextView) && ![text isEqualToString:@""]){
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    
    [[self placeholder] setHidden:[textView hasText]];
    
    if ([[self delegate] respondsToSelector:@selector(didUpdateText:)]){
        [[self delegate] didUpdateText:textView.text];
    }
    
    NSString *text = textView.text;
    
    CGFloat textHeight = [text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.textView.frame), CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:_notesViewAttribs context:nil].size.height;
    
    /**
     
     _lineHeightForTextView is the constant height for each line of text
     _textHeightForTextView is the height of the text area based on boundingRectWithSize
     _maxNumberOfLinesForTextView is the maximum allowed number of lines that the user can create
     
     **/
    
    /* if line height not set */
    if (_lineHeightForTextView < 1){
        _lineHeightForTextView = textHeight;
        _textHeightForTextView = textHeight;
        _numberOfLinesForTextView++;
    }
    
    /* if there's a new line */
    if (textHeight > _textHeightForTextView){
        _textHeightForTextView = textHeight;
        _numberOfLinesForTextView++;
        if ([[self delegate] respondsToSelector:@selector(setUpheightForTextViewWithHeight:)]){
            [[self delegate] setUpheightForTextViewWithHeight:_textHeightForTextView];
        }
        if ([[self delegate] respondsToSelector:@selector(adjustScrollViewWithHeight:)]){
            [[self delegate] adjustScrollViewWithHeight:_lineHeightForTextView];
        }
    }
    
    /* this is for the back button/ delete button */
    if (textHeight < _textHeightForTextView){
        _textHeightForTextView = textHeight;
        _numberOfLinesForTextView--;
        if ([[self delegate] respondsToSelector:@selector(setUpheightForTextViewWithHeight:)]){
            [[self delegate] setUpheightForTextViewWithHeight:_textHeightForTextView];
        }
        if ([[self delegate] respondsToSelector:@selector(adjustScrollViewWithHeight:)]){
            [[self delegate] adjustScrollViewWithHeight:-_lineHeightForTextView];
        }
    }
    
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    /* if text is blank, text text field to receive and empty string */
    if ([text isEqualToString:@""]){
        [[self textView] setText:@""];
    }
}



-(void)toggleFilter:(id)sender{
    NSLog(@"klsadjfa");
}

@end
