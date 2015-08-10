
#import "AccountEditViewController.h"
#import "Backend.h"
#import "User.h"
#import <RMUniversalAlert/RMUniversalAlert.h>

@interface AccountEditViewController ()

@end

@implementation AccountEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"キャンセル"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(dismissAccountEditView)];
    self.navigationItem.leftBarButtonItems = @[cancelButton];
    
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"保存"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(saveAccountEditView)];
    self.navigationItem.rightBarButtonItems = @[saveButton];
    
    self.emailEdit.text = My.shared.user->email;
}

- (void)dismissAccountEditView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveAccountEditView {
    //FIXME: 正確なバリデーションを行う
    if (_editPassword.text != _editPasswordConfirm.text) {
        [RMUniversalAlert showAlertInViewController:self
                                          withTitle:@"エラー"
                                            message:@"パスワードと確認用パスワードが異なります"
                                  cancelButtonTitle:nil
                             destructiveButtonTitle:@"OK"
                                  otherButtonTitles:@[]
                                           tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
                                           }];
        return;
    }
    
    //TODO: パスワードの更新を行う
    [Backend.shared updateUser:My.shared.user->userId option:@{
        @"email": _emailEdit.text,
    } callback:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error - updateUser: %@", error);
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
