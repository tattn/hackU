
#import "ImprovedViewController.h"

<<<<<<< HEAD
@interface ProfileEditViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>
=======
@interface ProfileEditViewController : ImprovedViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
>>>>>>> e4bcbd0070bc947aec39e5f965c74a2e199fa67c


@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *word;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@end
