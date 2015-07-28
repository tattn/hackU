
#ifndef hackuProduct_LoginViewController_h
#define hackuProduct_LoginViewController_h

#import "ImprovedViewController.h"

@interface LoginViewController : ImprovedViewController<UITextFieldDelegate>

+ (void)showLoginIfNotLoggedIn:(UIViewController*)vc;

@end

#endif
