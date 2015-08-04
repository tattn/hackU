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
@property (weak, nonatomic) IBOutlet UILabel *publishDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *amazonUrlButton;
- (IBAction)amazonUrlButton:(UIButton *)sender;

@property NSArray* buttons;

@property NSDictionary* book;
@property NSDictionary* bookshelf;
@property int userId;
@property NSDictionary* user;

typedef NS_ENUM (NSUInteger, Mode) {
    kModeAddingBookToBookshelf,
    kModeRemovingBookFromBookshelf,
    kModeRequestingBook,
    kModeAcceptingBook,
};

@property Mode mode;

@end

@implementation BookDetailViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if (_mode == kModeRequestingBook) {
        _book = _bookshelf[@"book"];
        //FIXME: ユーザーデータをローカルに保存したほうがいいかも、ただし更新タイミングを考慮する必要がある
        [Backend.shared getUser:_userId option:@{} callback:^(id res, NSError *error) {
            _user = res[@"user"];
            self.title = [NSString stringWithFormat:@"%@の本の詳細", _user[@"fullname"]];
        }];
    }
    else if (_mode == kModeAcceptingBook) {
        self.title = [NSString stringWithFormat:@"%@からのリクエスト", _user[@"fullname"]];
    }
    else {
        self.title = @"本の詳細";
    }
    
    self.navigationController.navigationBarHidden = NO;
    
    _amazonUrlButton.layer.cornerRadius = 8;
    _amazonUrlButton.clipsToBounds = YES;
    UIColor *amazonButtonColor = [UIColor colorWithRed:253/255.0 green:196/255.0 blue:79/255.0 alpha:1.0];
    _amazonUrlButton.backgroundColor = amazonButtonColor;
    
    if (_book[@"title"] == (id)[NSNull null] || [_book[@"author"]  isEqual: @""]) {
        _titleLabel.text = @"No infomation";
    }else{_titleLabel.text = _book[@"title"];}
    
    if (_book[@"author"] == (id)[NSNull null] || [_book[@"author"]  isEqual: @""]) {
        _authorLabel.text = @"No infomation";
    }else{_authorLabel.text = _book[@"author"];}
    
    if (_book[@"manufacturer"] == (id)[NSNull null] || [_book[@"author"]  isEqual: @""]) {
        _publisherLabel.text = @"No infomation";
    }else{_publisherLabel.text = _book[@"manufacturer"];}
    
    if (_book[@"publicationDate"] == (id)[NSNull null] || [_book[@"author"]  isEqual: @""]) {
        _publishDateLabel.text = @"No infomation";
    }else{_publishDateLabel.text = _book[@"publicationDate"];}
    
    if ([_book[@"amazonUrl"]  isEqual: @""]) {
        [_amazonUrlButton setTitle:@"No infomation" forState:UIControlStateNormal];
        _amazonUrlButton.backgroundColor = [UIColor whiteColor];
        _amazonUrlButton.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:13.0f];
        [_amazonUrlButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{_amazonUrlButton.titleLabel.text = @"Amazonで買う";}
    
    [_bookImage my_setImageWithURL: _book[@"coverImageUrl"]];
    
    const float ButtonHeight = 45;
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
    NSNumber* bookId = _book[@"bookId"];
    [Backend.shared addRequest:_userId bookId:bookId.intValue option:@{} callback:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error - requestBook: %@", error);
        }
        else {
            [self checkRequest:_buttons[0]]; //FIXME: dirty hack
        }
    }];
}

- (void)replyRequest:(BOOL)accepted {
    int bookId = ((NSNumber*)_book[@"bookId"]).intValue;
    [Backend.shared replyRequest:User.shared.userId bookId:bookId accepted:accepted option:@{} callback:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error - requestBook: %@", error);
        }
        else {
            [APP_DELEGATE switchTabBarController:0];
        }
    }];
    
    if (accepted == YES) {
        int borrowerId = ((NSNumber*)_user[@"userId"]).intValue;
        [Backend.shared addLending:bookId borrowerId:borrowerId option:@{} callback:^(id responseObject, NSError *error) {
            if (error) {
                NSLog(@"Error - addLending: %@", error);
            }
        }];
//        [Backend.shared updateBookInBookshelf:User.shared.userId bookId:bookId option:@{@"borrower_id":borrowerId} callback:^(id responseObject, NSError *error) {
//        }];
    }
}


#pragma mark - check database

- (void) checkRequest:(UIButton*)btn {
    //FIXME: 自分以外の誰かがリクエストしている時もボタンが押せなくなる.現在はそれが仕様.
    [Backend.shared getRequest:_userId option:@{} callback:^(id responseObject, NSError *error) {
        NSArray* reqs = responseObject[@"requests"];
        [reqs enumerateObjectsUsingBlock:^(NSDictionary* req, NSUInteger idx, BOOL *stop) {
            NSDictionary* book = req[@"book"];
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
                  yesTitle:@"追加" yes:^() {
                      [self addBookToBookshelf];
    }];
}

- (void)tapRemovingBookFromBookshelf:(id)sender {
    [AlertHelper showYesNo:self title:@"本棚から削除" msg:@"この本を本棚から削除します。よろしいですか？"
                  yesTitle:@"削除" yes:^() {
                      [self removeBookFromBookshelf];
    }];
}

- (void)tapRequestingBook:(id)sender {
    [AlertHelper showYesNo:self title:@"本のリクエスト" msg:@"この本をリクエストを送ります。よろしいですか？"
                  yesTitle:@"はい" yes:^() {
                      [self requestBook];
    }];
}

- (void)tapAcceptingRequest:(id)sender {
    [AlertHelper showYesNo:self title:@"リクエストの許可" msg:@"この本のリクエストを許可します。よろしいですか？"
                  yesTitle:@"はい" yes:^() {
                      [self replyRequest:YES];
    }];
}

- (void)tapRejectingRequest:(id)sender {
    [AlertHelper showYesNo:self title:@"リクエストの拒否" msg:@"この本のリクエストを拒否します。よろしいですか？"
                  yesTitle:@"はい" yes:^() {
                      [self replyRequest:NO];
    }];
}

#pragma mark - create UI

- (UIButton*)createButton:(NSString*)title color:(UIColor*)titleColor bgColor:(UIColor*)bgColor borderColor:(UIColor*)borderColor action:(SEL)action{
    UIButton* btn = [UIButton new];
    btn.backgroundColor = bgColor;
    btn.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:18.0f];
    btn.layer.cornerRadius = 8;
    btn.clipsToBounds = YES;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    if (borderColor) {
        [btn.layer setBorderColor:borderColor.CGColor];
        [btn.layer setBorderWidth:1.0];
    }
    return btn;
}

#pragma mark - show methods

+ (void)showForAddingBookToBookshelf:(UIViewController*)parent book:(NSDictionary*)book {
    BookDetailViewController *vc = [BookDetailViewController new];
    vc.mode = kModeAddingBookToBookshelf;
    vc.book = book;
    UIButton* btn = [vc createButton:@"本棚に追加"
                               color:[UIColor whiteColor]
                             bgColor: [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0]
                         borderColor:nil
                              action:@selector(tapAddingBookToBookshelf:)];
    vc.buttons = @[btn];
    [parent.navigationController pushViewController:vc animated: true];
}

+ (void)showForRemovingBookFromBookshelf:(UIViewController*)parent book:(NSDictionary*)book {
    BookDetailViewController *vc = [BookDetailViewController new];
    vc.mode = kModeRemovingBookFromBookshelf;
    vc.book = book;
    UIButton* btn = [vc createButton:@"本棚から削除"
                               color:[UIColor whiteColor]
                             bgColor: [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0]
                         borderColor:nil
                              action:@selector(tapRemovingBookFromBookshelf:)];
    vc.buttons = @[btn];
    [parent.navigationController pushViewController:vc animated: true];
}

+ (void)showForRequestingBook:(UIViewController*)parent bookshelf:(NSDictionary*)bookshelf {
    BookDetailViewController *vc = [BookDetailViewController new];
    vc.mode = kModeRequestingBook;
    vc.bookshelf = bookshelf;
    vc.userId = ((NSNumber*)bookshelf[@"userId"]).intValue;
    UIButton* btn = [vc createButton:@"借りたい"
                               color:[UIColor whiteColor]
                             bgColor: [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0]
                         borderColor:nil
                              action:@selector(tapRequestingBook:)];
    [vc checkRequest:btn];
    [vc checkLending:btn];
    vc.buttons = @[btn];
    [parent.navigationController pushViewController:vc animated: true];
}

+ (void)showForAcceptingBook:(UIViewController*)parent book:(NSDictionary*)book sender:(NSDictionary*)sender {
    BookDetailViewController *vc = [BookDetailViewController new];
    vc.mode = kModeAcceptingBook;
    vc.book = book;
    vc.user = sender;
    UIButton* btn1 = [vc createButton:@"貸す"
                               color:[UIColor whiteColor]
                             bgColor: [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0]
                         borderColor:nil
                              action:@selector(tapAcceptingRequest:)];
    UIButton* btn2 = [vc createButton:@"貸さない"
                               color:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]
                             bgColor:[UIColor whiteColor]
                         borderColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]
                              action:@selector(tapRejectingRequest:)];
    vc.buttons = @[btn1, btn2];
    [parent.navigationController pushViewController:vc animated: true];
}

- (IBAction)amazonUrlButton:(UIButton *)sender {
    NSString *amazonUrl = _book[@"amazonUrl"];
    NSURL *url = [NSURL URLWithString:amazonUrl];
    [[UIApplication sharedApplication] openURL:url];
}
@end
