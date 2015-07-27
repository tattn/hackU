
#import "FriendTableViewCell.h"
#import "FriendProfileViewController.h"

@implementation FriendTableViewCell

- (void)awakeFromNib {
    
    //UIImageViewを円形にして表示する
    self.friendImage.layer.cornerRadius = self.friendImage.frame.size.width / 2.f;
    self.friendImage.layer.masksToBounds = YES;
    self.friendImage.layer.borderColor = [UIColor blackColor].CGColor;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
