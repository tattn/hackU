//
//  BookDetailViewController.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/30.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "BookDetailViewController.h"
#import "UIImageViewHelper.h"
#import <RMUniversalAlert.h>
#import "Backend.h"
#import "User.h"
#import "AlertHelper.h"
#import "BookShelfCollectionViewController.h"

@interface BookDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisherLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bookImage;
@property (weak, nonatomic) IBOutlet UIView *actionView;

@property NSArray* buttons;

@property NSDictionary* book;
@property NSDictionary* bookshelf;
@property int userId;

@end

@implementation BookDetailViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if (_bookshelf) _book = _bookshelf[@"book"];
    
    self.title = @"本の詳細";
    self.navigationController.navigationBarHidden = NO;
    
    _titleLabel.text = _book[@"title"];
    _publisherLabel.text = _book[@"manufacturer"];
    _authorLabel.text = _book[@"author"];
    [_bookImage my_setImageWithURL: _book[@"coverImageUrl"]];
    
    const float ButtonHeight = 40;
    const float SectionHeight = _actionView.frame.size.height / _buttons.count;
    [_buttons enumerateObjectsUsingBlock:^(UIButton* btn, NSUInteger idx, BOOL *stop) {
        float y = (SectionHeight - ButtonHeight) / 2 + SectionHeight * idx;
        btn.frame = CGRectMake(0, y, _actionView.frame.size.width, ButtonHeight);
        [_actionView addSubview:btn];
    }];
    
}

- (void)addBookToBookshelf {
    NSNumber* bookId = _book[@"bookId"];
    [Backend.shared addBookToBookshelf:User.shared.userId bookId:bookId.intValue option:@{} callback:^(id responseObject, NSError *error) {
        [APP_DELEGATE switchTabBarController:2];
    }];
}

- (void)removeBookFromBookshelf {
    NSNumber* bookId = _book[@"bookId"];
    [Backend.shared deleteBookInBookshelf:User.shared.userId bookId: bookId.intValue option:@{} callback:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error - deleteBookInBookshelf: %@", error);
        }
        else {
            [APP_DELEGATE switchTabBarController:2];
        }
    }];
}

- (void)requestBook {
    NSNumber* bookId = _bookshelf[@"book"][@"bookId"];
    [Backend.shared addRequest:_userId bookId:bookId.intValue option:@{} callback:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error - requestBook: %@", error);
        }
        else {
            [self checkRequest:_buttons[0]]; //FIXME: dirty hack
        }
    }];
}

#pragma mark - check database

- (void) checkRequest:(UIButton*)btn {
    //FIXME: 自分以外の誰かがリクエストしている時もボタンが押せなくなる.現在はそれが仕様.
    [Backend.shared getRequest:_userId option:@{} callback:^(id responseObject, NSError *error) {
        NSArray* books = responseObject[@"books"];
        [books enumerateObjectsUsingBlock:^(NSDictionary* book, NSUInteger idx, BOOL *stop) {
            NSNumber* bookId = book[@"bookId"];
            if ([bookId isEqualToNumber: _bookshelf[@"book"][@"bookId"]]) {
                [btn setTitle:@"リクエスト中" forState:UIControlStateNormal];
                btn.enabled = NO;
            }
        }];
    }];
}

- (void) checkLending:(UIButton*)btn {
    NSNumber* borrowerId = _bookshelf[@"borrowerId"];
    if (![borrowerId isEqualToNumber:@0]) {
        [btn setTitle:@"貸出中" forState:UIControlStateNormal];
        btn.enabled = NO;
    }
}

#pragma mark - button events

- (void)tapAddingBookToBookshelf:(id)sender {
    [AlertHelper showYesNo:self title:@"本棚に追加" msg:@"この本を本棚に追加します。よろしいですか？"
                  yesTitle:@"追加" noTitle:@"キャンセル" yes:^() {
                      [self addBookToBookshelf];
    } no:^() {
    }];
}

- (void)tapRemovingBookFromBookshelf:(id)sender {
    [AlertHelper showYesNo:self title:@"本棚から削除" msg:@"この本を本棚から削除します。よろしいですか？"
                  yesTitle:@"削除" noTitle:@"キャンセル" yes:^() {
                      [self removeBookFromBookshelf];
    } no:^() {
    }];
}

- (void)tapRequestingBook:(id)sender {
    [AlertHelper showYesNo:self title:@"本のリクエスト" msg:@"この本をリクエストを送ります。よろしいですか？"
                  yesTitle:@"はい" noTitle:@"キャンセル" yes:^() {
                      [self requestBook];
    } no:^() {
    }];
}

#pragma mark - create UI

- (UIButton*)createButton:(NSString*)title color:(UIColor*)titleColor bgColor:(UIColor*)bgColor action:(SEL)action{
    UIButton* btn = [UIButton new];
    btn.backgroundColor = bgColor;
    btn.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15.0f];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

#pragma mark - show methods

+ (void)showForAddingBookToBookshelf:(UIViewController*)parent book:(NSDictionary*)book {
    BookDetailViewController *vc = [BookDetailViewController new];
    vc.book = book;
    UIButton* btn = [vc createButton:@"本棚に追加"
                               color:[UIColor whiteColor]
                             bgColor: [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0]
                              action:@selector(tapAddingBookToBookshelf:)];
    vc.buttons = @[btn];
    [parent.navigationController pushViewController:vc animated: true];
}

+ (void)showForRemovingBookFromBookshelf:(UIViewController*)parent book:(NSDictionary*)book {
    BookDetailViewController *vc = [BookDetailViewController new];
    vc.book = book;
    UIButton* btn = [vc createButton:@"本棚から削除"
                               color:[UIColor whiteColor]
                             bgColor: [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0]
                              action:@selector(tapRemovingBookFromBookshelf:)];
    vc.buttons = @[btn];
    [parent.navigationController pushViewController:vc animated: true];
}

+ (void)showForRequestingBook:(UIViewController*)parent bookshelf:(NSDictionary*)bookshelf userId:(int)userId {
    BookDetailViewController *vc = [BookDetailViewController new];
    vc.bookshelf = bookshelf;
    vc.userId = userId;
    UIButton* btn = [vc createButton:@"借りたい"
                               color:[UIColor whiteColor]
                             bgColor: [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0]
                              action:@selector(tapRequestingBook:)];
    [vc checkRequest:btn];
    [vc checkLending:btn];
    vc.buttons = @[btn];
    [parent.navigationController pushViewController:vc animated: true];
}

@end
