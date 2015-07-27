
#import "ProfileEditViewController.h"

@interface ProfileEditViewController ()

@end

@implementation ProfileEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //UIImageViewを円形にして表示する
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2.f;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImage.layer.borderWidth = 5;
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc]
                              initWithTitle:@"キャンセル"
                              style:UIBarButtonItemStylePlain
                              target:self
                              action:@selector(dismissProfileEditView)];
    self.navigationItem.leftBarButtonItems = @[cancelButton];
    
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc]
                              initWithTitle:@"保存"
                              style:UIBarButtonItemStylePlain
                              target:self
                              action:@selector(saveProfileEditView)];
    self.navigationItem.rightBarButtonItems = @[saveButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissProfileEditView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveProfileEditView {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)profileImage:(UIButton *)sender {
}
@end
