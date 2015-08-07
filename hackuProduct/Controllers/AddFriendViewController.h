
#import "ImprovedViewController.h"
#import "BarcodeView.h"

@interface AddFriendViewController : ImprovedViewController <BarcodeDelegate>
@property (weak, nonatomic) IBOutlet UIButton *friendApplyButton;

@end
