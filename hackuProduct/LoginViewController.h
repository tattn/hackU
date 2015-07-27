//
//  LoginViewController.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/22.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#ifndef hackuProduct_LoginViewController_h
#define hackuProduct_LoginViewController_h

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>

+ (void)showLoginIfNotLoggedIn:(UIViewController*)vc;

@end

#endif
