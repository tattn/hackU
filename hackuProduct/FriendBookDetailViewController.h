
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FriendBookDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *friendBookImage;
@property (weak, nonatomic) IBOutlet UILabel *bookTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisherLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIButton *rentRequestButton;

@end
