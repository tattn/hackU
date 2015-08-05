
#import "FriendTableViewCell.h"
#import "FriendProfileViewController.h"

@implementation FriendTableViewCell

- (void)awakeFromNib {
    
    //UIImageViewを円形にして表示する
    _friendImage.layer.cornerRadius = self.friendImage.frame.size.width / 2.f;
    _friendImage.layer.masksToBounds = YES;
    _friendImage.layer.borderColor = [UIColor colorWithRed:0.22 green:0.80 blue:0.49 alpha:1.0].CGColor;
    _friendImage.layer.borderWidth = 2;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
