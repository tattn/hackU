//
//  Toast.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/31.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "Toast.h"

@interface Toast ()

@property UILabel* msgLabel;

@end

@implementation Toast

+ (id)initWithMessage:(NSString*)msg parent:(CGRect)rect {
    Toast* toast = [Toast new];
    toast.backgroundColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0];
    toast.layer.cornerRadius = 8;
    toast.clipsToBounds = YES;
    
    toast.msgLabel = [UILabel new];
    toast.msgLabel.text = msg;
    toast.msgLabel.textColor = [UIColor whiteColor];
    toast.msgLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15.0f];
    [toast.msgLabel sizeToFit];
    [toast addSubview: toast.msgLabel];
    
    CGSize size = CGSizeMake(toast.msgLabel.frame.size.width + 30, toast.msgLabel.frame.size.height + 30);
    toast.frame = CGRectMake(0, 0, size.width, size.height);
    toast.center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    
    toast.msgLabel.center = CGPointMake(size.width / 2, size.height / 2);
    
    return toast;
}

- (void)fadeInOut {
    self.alpha = 0;
    [UIView animateWithDuration:1.0
                     animations:^{self.alpha = 1.0;}
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:1.0
                                               delay:1.3
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{self.alpha = 0.0;}
                                          completion:^(BOOL finished) {
                                              [self removeFromSuperview];
                                          }];  }];
}

+(void)show:(UIView*)parent message:(NSString*)msg {
    // 表示中のToastがあれば、削除
    for (UIView *view in [parent subviews]) {
        if ([view isKindOfClass:[Toast class]]) {
            [view removeFromSuperview];
        }
    }
    
    Toast* toast = [Toast initWithMessage:msg parent:parent.bounds];
    
    [parent addSubview:toast];
    [parent bringSubviewToFront:toast];
    [toast fadeInOut];
}

@end
