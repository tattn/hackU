//
//  BlocklistViewController.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/27.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlocklistViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@end

@interface BlocklistCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@end
