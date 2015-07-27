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
    
    _singleTapForKeyboard = [[UITapGestureRecognizer alloc] init];
    _singleTapForKeyboard.delegate = self;
    _singleTapForKeyboard.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_singleTapForKeyboard];
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer != _singleTapForKeyboard) {
        return YES;
    }
    
    UIView *touchedView = touch.view;
    UIView *firstResponderView = [self.view findFirstResponder];
    
    if (firstResponderView && firstResponderView != touchedView) {
        [self.view endEditing:YES];
    }
    
    return NO;
}

@end
