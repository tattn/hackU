
#import "AccountEditViewController.h"

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
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [userDefaults objectForKey:@"LoginEmail"];
    self.emailEdit.text = email;
    
}

- (void)dismissAccountEditView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveAccountEditView {
    //変更情報保存未実装
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
