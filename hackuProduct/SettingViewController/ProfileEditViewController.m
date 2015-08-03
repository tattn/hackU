
#import "ProfileEditViewController.h"
#import "User.h"
#import "Backend.h"
#import "Toast.h"
#import "UIImageViewHelper.h"

@interface ProfileEditViewController ()

@end

@implementation ProfileEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //UIImageViewを円形にして表示する
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2.f;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderColor = [UIColor colorWithRed:0.22 green:0.80 blue:0.49 alpha:1.0].CGColor;
    self.profileImage.layer.borderWidth = 5;
    
    self.profileImageButton.layer.cornerRadius = self.profileImage.frame.size.width / 2.f;
    self.profileImageButton.layer.masksToBounds = YES;
    self.profileImageButton.layer.borderColor = [UIColor colorWithRed:0.22 green:0.80 blue:0.49 alpha:1.0].CGColor;
    self.profileImageButton.layer.borderWidth = 5;
    
    [self.profileImage my_setImageWithURL:PROFILE_IMAGE_URL(User.shared.userId) defaultImage:[UIImage imageNamed:@"ProfileImageDefault"]];
    
    self.firstname.text = User.shared.firstname;
    self.lastname.text = User.shared.lastname;
    self.word.text = User.shared.comment;
    
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
    [Backend.shared updateUser:User.shared.userId option:@{
        @"firstname": _firstname.text,
        @"lastname": _lastname.text,
        @"comment": _word.text,
    } callback:^(id responseObject, NSError *error) {
        [Backend.shared uploadProfileImage:User.shared.userId image:self.profileImage.image option:@{} callback:^(id responseObject, NSError *error) {
            if (error) {
                NSLog(@"Upload error: %@", error);
                [Toast show:self.view message:@"画像のアップロードに失敗しました"];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
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
}

@end
