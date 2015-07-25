//
//  FriendTableViewCell.m
//  hackuProduct
//
//  Created by Kazusa Sakamoto on 2015/07/17.
//  Copyright (c) 2015年 Kazusa Sakamoto. All rights reserved.
//

#import "FriendTableViewCell.h"

@implementation FriendTableViewCell

- (void)awakeFromNib {
    
    //UIImageViewを円形枠線付きに表示
    self.friendImage.layer.cornerRadius = self.friendImage.frame.size.width / 2.f;
    self.friendImage.layer.masksToBounds = YES;
    self.friendImage.layer.borderColor = [UIColor blackColor].CGColor;
    //self.friendImage.layer.borderWidth = 1.f;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
