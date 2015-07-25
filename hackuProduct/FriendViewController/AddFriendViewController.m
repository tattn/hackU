//
//  AddFriendViewController.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/25.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "AddFriendViewController.h"
#import "Backend.h"

@interface AddFriendViewController ()

@property (weak, nonatomic) IBOutlet UITextField *invitationCode;

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"フレンド申請";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)touchUpRequest:(id)sender {
    NSString* code = _invitationCode.text;
    
    Backend* backend = Backend.shared;
    [backend addFriend:code.intValue option:@{} callback:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"addFriend error: %@\n", error);
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

@end
