
#import <UIKit/UIKit.h>

@interface FriendProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *friendImage;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *registerNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *rentNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *borrowNumberLabel;
- (IBAction)bookShelfButton:(UIButton *)sender;
- (IBAction)blockButton:(UIButton *)sender;

@end