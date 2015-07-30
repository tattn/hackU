//
//  BookDetailViewController.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/30.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookDetailViewController : UIViewController

+ (void)showForAddingBookToBookshelf:(UIViewController*)parent book:(NSDictionary*)book;

+ (void)showForRemovingBookFromBookshelf:(UIViewController*)parent book:(NSDictionary*)book;

@end
