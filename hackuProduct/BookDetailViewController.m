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

@end

@implementation BookDetailViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"本の詳細";
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
//TODO: 追加後に本棚のreloadDataをするようにする
    }];
}

- (void)removeBookFromBookshelf {
    NSNumber* bookId = _book[@"bookId"];
    [Backend.shared deleteBookInBookshelf:User.shared.userId bookId: bookId.intValue option:@{} callback:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error - deleteBookInBookshelf: %@", error);
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
//            BookShelfCollectionViewController* vc = (BookShelfCollectionViewController*)[self.navigationController popViewControllerAnimated:YES];
//            [vc.collectionView reloadData];
        }
    }];
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

@end
