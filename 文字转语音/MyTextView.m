//
//  MyTextView.m
//  文字转语音
//
//  Created by HuangXunhui on 2017/6/19.
//  Copyright © 2017年 HuangXunhui. All rights reserved.
//

#import "MyTextView.h"

@implementation MyTextView {
    UIMenuController *_menuController;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIMenuItem *menuItem = [[UIMenuItem alloc]initWithTitle:@"朗读" action:@selector(selfMenu:)];
        _menuController = [UIMenuController sharedMenuController];
        [_menuController setMenuItems:[NSArray arrayWithObject:menuItem]];
        self.selectable = YES;
        self.editable = NO;
        self.font = [UIFont systemFontOfSize:17];
        [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedWordWithRecognizer:)]];
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return action == @selector(selfMenu:);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)selfMenu:(id)sender {
    UITextRange *wr = [self selectedTextRange];
    NSString *selectedText = [self textInRange:wr];
    if (_block) {
        _block(selectedText);
    }
    [self endEditing:YES];
}

- (void)longPressedWordWithRecognizer:(UIGestureRecognizer *)recognizer {
    [self becomeFirstResponder];
    [_menuController setMenuVisible:YES];
}

@end
