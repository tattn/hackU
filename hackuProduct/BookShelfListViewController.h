//
//  BookShelfListViewController.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/08/05.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface BookShelfListViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

+ (void)showForMyBookshelf:(UIViewController*)parent;
+ (void)showForFriendBookshelf:(UIViewController*)parent user:(User*)user;

@end

