//
//  ImprovedViewController.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/28.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "ImprovedViewController.h"

@implementation UIView (UIUtil)
- (UIView *)findFirstResponder {
    if ([self isFirstResponder]) {
        return self;
    }
    
    for (UIView *subView in [self subviews]) {
        if ([subView isFirstResponder]) {
            return subView;
        }
        if ([subView findFirstResponder]) {
            return [subView findFirstResponder];
        }
    }
    return nil;
}
@end


@implementation ImprovedViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    
    _tapGestureForKeyboard = [[UITapGestureRecognizer alloc] init];
    _tapGestureForKeyboard.delegate = self;
    _tapGestureForKeyboard.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tapGestureForKeyboard];
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer != _tapGestureForKeyboard) {
        return YES;
    }
    
    UIView *firstResponderView = [self.view findFirstResponder];
    
    if (firstResponderView && firstResponderView != touch.view) {
        [self.view endEditing:YES];
    }
    
    return NO;
}

@end
