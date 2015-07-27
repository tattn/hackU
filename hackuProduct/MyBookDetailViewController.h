//
//  MyBookDetailViewController.h
//  hackuProduct
//
//  Created by Kazusa Sakamoto on 2015/07/27.
//  Copyright (c) 2015年 Kazusa Sakamoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyBookDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *bookImage;
@property (weak, nonatomic) IBOutlet UILabel *bokTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisherLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookDeleteButton;

@end
