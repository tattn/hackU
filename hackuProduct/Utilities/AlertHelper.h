//
//  AlertHelper.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/30.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#ifndef hackuProduct_AlertHelper_h
#define hackuProduct_AlertHelper_h
#import <UIKit/UIKit.h>

@interface AlertHelper: NSObject

+ (void)showYesNo:(UIViewController*)parent title:(NSString*)title msg:(NSString*)msg yesTitle:(NSString*)yesTitle yes:(void (^)())yes;

+ (void)showYesNo:(UIViewController*)parent title:(NSString*)title msg:(NSString*)msg yesTitle:(NSString*)yesTitle noTitle:(NSString*)noTitle yes:(void (^)())yes;

+ (void)showYesNo:(UIViewController*)parent title:(NSString*)title msg:(NSString*)msg yesTitle:(NSString*)yesTitle noTitle:(NSString*)noTitle yes:(void (^)())yes no:(void (^)())no;

@end

#endif
