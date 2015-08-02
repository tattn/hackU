//
//  AlertHelper.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/30.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "AlertHelper.h"
#import <RMUniversalAlert.h>
#import <SIAlertView/SIAlertView.h>

@implementation AlertHelper

+ (void)showYesNo:(UIViewController*)parent title:(NSString*)title msg:(NSString*)msg yesTitle:(NSString*)yesTitle yes:(void (^)())yes {
    [AlertHelper showYesNo:parent title:title msg:msg yesTitle:yesTitle noTitle:@"キャンセル" yes:yes no:^(){}];
}

+ (void)showYesNo:(UIViewController*)parent title:(NSString*)title msg:(NSString*)msg yesTitle:(NSString*)yesTitle noTitle:(NSString*)noTitle yes:(void (^)())yes {
    [AlertHelper showYesNo:parent title:title msg:msg yesTitle:yesTitle noTitle:noTitle yes:yes no:^(){}];
}

+ (void)showYesNo:(UIViewController*)parent title:(NSString*)title msg:(NSString*)msg yesTitle:(NSString*)yesTitle noTitle:(NSString*)noTitle yes:(void (^)())yes no:(void (^)())no {

//    [RMUniversalAlert showAlertInViewController:parent
//                                      withTitle:title
//                                        message:msg
//                              cancelButtonTitle:noTitle
//                         destructiveButtonTitle:yesTitle
//                              otherButtonTitles:@[]
//                                       tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
//                                           if (buttonIndex == alert.cancelButtonIndex) {
//                                               no();
//                                           } else if (buttonIndex == alert.destructiveButtonIndex) {
//                                               yes();
//                                           }
//                                       }];
    
    [[SIAlertView appearance] setMessageFont:[UIFont fontWithName:@"HiraKakuProN-W6" size:11.0f]];
    [[SIAlertView appearance] setTitleFont:[UIFont fontWithName:@"HiraKakuProN-W6" size:18.0f]];
    [[SIAlertView appearance] setButtonFont:[UIFont fontWithName:@"HiraKakuProN-W6" size:11.0f]];
    
    [[SIAlertView appearance] setTitleColor:[UIColor whiteColor]];
    [[SIAlertView appearance] setMessageColor:[UIColor whiteColor]];
    [[SIAlertView appearance] setViewBackgroundColor:[UIColor colorWithRed:0.22 green:0.80 blue:0.49 alpha:1.0]];
    [[SIAlertView appearance] setButtonColor:[UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0]];
    [[SIAlertView appearance] setCornerRadius:12];
//    [[SIAlertView appearance] setShadowRadius:0];
//    [[SIAlertView appearance] setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
//    [[SIAlertView appearance] setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:msg];
    
    // SIAlertViewButtonTypeDestructive
    [alertView addButtonWithTitle:yesTitle
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              yes();
                          }];
    [alertView addButtonWithTitle:noTitle
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              no();
                          }];
    
    alertView.willShowHandler = ^(SIAlertView *alertView) {
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
    };
    
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [alertView show];
}

@end
