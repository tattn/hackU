
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
    
    self.profileImageButton.layer.cornerRadius = self.profileImage.frame.size.width / 2.f;
    self.profileImageButton.layer.masksToBounds = YES;
    self.profileImageButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImageButton.layer.borderWidth = 5;
    
    self.name.text = @"my name"; //（未実装）自分の名前をあらかじめ設置
    self.word.text = @"進撃の巨人読みたい"; //（未実装）一言の情報をあらかじめ設置
    
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

- (void)dismissProfileEditView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveProfileEditView {
    //更新情報の保存は未実装
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)imageChange:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

- (void)imagePickerController :(UIImagePickerController *)picker
        didFinishPickingImage :(UIImage *)image editingInfo :(NSDictionary *)editingInfo {
    NSLog(@"selected");
    [self.profileImage setImage:image];
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
