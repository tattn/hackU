
#import "ImprovedViewController.h"

@interface ProfileEditViewController : ImprovedViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UITextField *firstname;
@property (weak, nonatomic) IBOutlet UITextField *lastname;
@property (weak, nonatomic) IBOutlet UITextField *word;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *myBooksNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *myLendNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *myBorrowNumLabel;
@end
