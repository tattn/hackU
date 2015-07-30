//
//  AlertHelper.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/30.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "AlertHelper.h"
#import <RMUniversalAlert.h>

@implementation AlertHelper

+ (void)showYesNo:(UIViewController*)parent title:(NSString*)title msg:(NSString*)msg yesTitle:(NSString*)yesTitle noTitle:(NSString*)noTitle yes:(void (^)())yes no:(void (^)())no {

    [RMUniversalAlert showAlertInViewController:parent
                                      withTitle:title
                                        message:msg
                              cancelButtonTitle:noTitle
                         destructiveButtonTitle:yesTitle
                              otherButtonTitles:@[]
                                       tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
                                           if (buttonIndex == alert.cancelButtonIndex) {
                                               no();
                                           } else if (buttonIndex == alert.destructiveButtonIndex) {
                                               yes();
                                           }
                                       }];
}

@end
