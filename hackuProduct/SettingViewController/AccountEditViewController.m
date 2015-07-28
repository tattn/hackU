
#import "AccountEditViewController.h"
#import "Backend.h"
#import "User.h"
#import <RMUniversalAlert.h>

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
    
    self.emailEdit.text = User.shared.email;
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
    [Backend.shared updateUser:User.shared.userId option:@{
        @"email": _emailEdit.text,
    } callback:^(id responseObject, NSError *error) {
        if (error) {
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
