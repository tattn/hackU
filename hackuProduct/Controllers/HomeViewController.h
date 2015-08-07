
#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@end

@interface NotificationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

@end
