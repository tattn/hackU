//
//  BookDetailViewController.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/30.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface BookDetailViewController : UIViewController

+ (void)showForAddingBookToBookshelf:(UIViewController*)parent book:(Book*)book;

+ (void)showForRemovingBookFromBookshelf:(UIViewController*)parent book:(Book*)book;

+ (void)showForRequestingBook:(UIViewController*)parent bookshelf:(NSDictionary*)bookshelf;

+ (void)showForAcceptingBook:(UIViewController*)parent book:(Book*)book sender:(NSDictionary*)sender;

@end
