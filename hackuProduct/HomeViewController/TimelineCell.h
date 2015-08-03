
#import <UIKit/UIKit.h>

@interface TimelineCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *friendImage;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *friendBookImage;
@property (weak, nonatomic) IBOutlet UILabel *addBookInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *addDateTimeLabel;

@end
