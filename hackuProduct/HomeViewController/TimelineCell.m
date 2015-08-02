//
//  TimelineCell.m
//  hackuProduct
//
//  Created by Kazusa Sakamoto on 2015/08/02.
//  Copyright (c) 2015年 Kazusa Sakamoto. All rights reserved.
//

#import "TimelineCell.h"

@implementation TimelineCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.friendImage.layer.cornerRadius = self.friendImage.frame.size.width / 2.f;
    self.friendImage.layer.masksToBounds = YES;
    self.friendImage.layer.borderColor = [UIColor colorWithRed:0.22 green:0.80 blue:0.49 alpha:1.0].CGColor;
    self.friendImage.layer.borderWidth = 2;
}

@end
