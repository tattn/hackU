
#import <UIKit/UIKit.h>

@interface ProfileEditViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *word;
- (IBAction)profileImage:(UIButton *)sender;

@end
