//
//  SearchResultViewController.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/28.
//  Copyright © 2015年 Tatsuya Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
@property NSString* searchQuery;

@end


@interface SearchResultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bookImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

