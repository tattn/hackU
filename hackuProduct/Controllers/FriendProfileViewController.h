#import "User.h"

@interface FriendProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *friendImage;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *registerNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *rentNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *borrowNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookShelfButton;
@property (weak, nonatomic) IBOutlet UIButton *blockButton;
- (IBAction)bookShelfButton:(UIButton *)sender;
- (IBAction)blockButton:(UIButton *)sender;

+ (void)show:(UIViewController*)parent user:(User*)user;

@end
