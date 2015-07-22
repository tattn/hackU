//
//  LoginViewController.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/22.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginViewController.h"
#import "Backend.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *passLabel;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 前回のアカウントでログインする.ここで実行すると一瞬Viewが見えてしまうので、別の場所に移した方がいい
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"LoginEmail"];
    NSString *email = [userDefaults objectForKey:@"LoginEmail"];
    NSString *pass = [userDefaults objectForKey:@"LoginPass"];
    if (email && pass) {
        [self tryLogin:email password:pass];
    }
}

- (IBAction)login:(id)sender {
    NSString *email = _emailLabel.text;
    NSString *pass = _passLabel.text;
    
    //FIXME: バリデーションを正しく行う
    if ([email isEqual: @""] || [pass isEqual: @""]) {
        return;
    }
    
    [self tryLogin:email password:pass];
}

- (void)tryLogin:(NSString*)email password:(NSString*)pass {
    Backend *backend = Backend.shared;
    [backend login:email password:pass option:@{} callback:^(id responseObject, NSError *error) {
        if (error) {
            //TODO: ログインに失敗したことをユーザーに通知する、テキストフィールドを赤枠にする
            NSLog(@"Login error");
        }
        else {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:email forKey:@"LoginEmail"];
            [userDefaults setObject:pass forKey:@"LoginPass"];
            [userDefaults synchronize];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

@end
