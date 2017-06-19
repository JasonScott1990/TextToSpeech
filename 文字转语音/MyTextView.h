//
//  MyTextView.h
//  文字转语音
//
//  Created by HuangXunhui on 2017/6/19.
//  Copyright © 2017年 HuangXunhui. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ChangeValueBlock)(NSString *selectedText);
@interface MyTextView : UITextView
@property (nonatomic,copy) ChangeValueBlock block;
@end
