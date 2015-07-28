
#import "ImprovedViewController.h"

@interface AccountEditViewController : ImprovedViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailEdit;
@property (weak, nonatomic) IBOutlet UITextField *editPassword;
@property (weak, nonatomic) IBOutlet UITextField *editPasswordConfirm;

@end
