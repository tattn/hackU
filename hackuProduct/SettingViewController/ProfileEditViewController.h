
#import "ImprovedViewController.h"

@interface ProfileEditViewController : ImprovedViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *word;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@end
