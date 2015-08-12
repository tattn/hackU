
#import "ProfileEditViewController.h"
#import "User.h"
#import "Backend.h"
#import "UIImageView+WebImage.h"
#import <CLImageEditor/CLImageEditor.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <TTToast/TTToast-Swift.h>

@interface ProfileEditViewController () <CLImageEditorDelegate>

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
    
    [self.profileImage my_setImageWithURL:PROFILE_IMAGE_URL(My.shared.user->userId) defaultImage:[UIImage imageNamed:@"ProfileImageDefault"]];
    
    self.firstname.text = My.shared.user->firstname;
    self.lastname.text = My.shared.user->lastname;
    self.word.text = My.shared.user->comment;
    
    [Backend.shared getUser:My.shared.user->userId option:@{} callback:^(id responseObject, NSError *error) {
        NSDictionary* user = responseObject[@"user"];
        self.myBooksNumLabel.text = ((NSNumber*)user[@"bookNum"]).stringValue;
        self.myLendNumLabel.text = ((NSNumber*)user[@"lendNum"]).stringValue;
        self.myBorrowNumLabel.text = ((NSNumber*)user[@"borrowNum"]).stringValue;
    }];
    
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
    [Backend.shared updateUser:My.shared.user->userId option:@{
        @"firstname": _firstname.text,
        @"lastname": _lastname.text,
        @"comment": _word.text,
    } callback:^(id responseObject, NSError *error) {
        [Backend.shared uploadProfileImage:My.shared.user->userId image:self.profileImage.image option:@{} callback:^(id responseObject, NSError *error) {
            [SVProgressHUD dismiss];
            if (error) {
                NSLog(@"Upload error: %@", error);
                [TTToast show:@"画像のサイズが大きすぎます"];
                return;
            }
            else {
                //FIXME: ちょうどいいキャッシュ削除のタイミングを考える
                SDImageCache *imageCache = [SDImageCache sharedImageCache];
                [imageCache clearMemory];
                [imageCache clearDisk];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:image];
    editor.delegate = self;
    
    [picker pushViewController:editor animated:YES];
}

- (void)imageEditor:(CLImageEditor *)editor didFinishEdittingWithImage:(UIImage *)image
{
    [self.profileImage setImage:image];
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController :(UIImagePickerController *)picker
        didFinishPickingImage :(UIImage *)image editingInfo :(NSDictionary *)editingInfo {
    [self.profileImage setImage:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end