//
//  TimelineCell.h
//  hackuProduct
//
//  Created by Kazusa Sakamoto on 2015/08/02.
//  Copyright (c) 2015年 Kazusa Sakamoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *friendImage;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *friendBookImage;
@property (weak, nonatomic) IBOutlet UILabel *addBookInfoLabel;

@end
