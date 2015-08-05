//
//  BookShelfListViewController.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/08/05.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "BookShelfListViewController.h"
#import "BookShelfListCell.h"
#import "Backend.h"
#import "User.h"
#import "Bookshelf.h"
#import "UIImageViewHelper.h"
#import "SearchViewController.h"
#import "BookDetailViewController.h"
#import <REMenu/REMenu.h>

@interface BookShelfListViewController ()

@property NSMutableArray* bookshelves;
@property User* user;

@property (strong, readwrite, nonatomic) REMenu *menu;

typedef NS_ENUM (int, SortType) {
    kSortTypeTitleAsc,
    kSortTypeTitleDesc,
    kSortTypeDateDesc,
    kSortTypeDateAsc,
    kSortTypeAddDesc,
    kSortTypeAddAsc,
};

@property SortType sortType;

typedef NS_ENUM (int, ListType) {
    kListTypeMyBookshelf,
    kListTypeFriendBookshelf,
};

@property ListType listType;

@end

@implementation BookShelfListViewController

static NSString * const reuseIdentifier = @"BookShelfListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new]; // 余分なCellのセパレータを表示しないための処理
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"IconAddButton"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(didTapAddBook:)];
    
    UINib *nib = [UINib nibWithNibName:reuseIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:reuseIdentifier];
    
    //戻るボタンの表示変更
    UIBarButtonItem* btn = [[UIBarButtonItem alloc] initWithTitle:@""
                                                            style:UIBarButtonItemStylePlain
                                                           target:nil
                                                           action:nil];
    self.navigationItem.backBarButtonItem = btn;
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc]
                                              initWithImage:[[UIImage imageNamed:@"SortIcon"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(didTapSort:)];
    
    if (_listType == kListTypeMyBookshelf) {
        self.navigationItem.leftBarButtonItem = item;
    }
    else {
        self.navigationItem.rightBarButtonItem = item;
    }
    
    
    REMenuItem *sortTitleAsc = [[REMenuItem alloc] initWithTitle:@"タイトル順"
                                                      image:nil
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {
                                                         [self sort:kSortTypeTitleAsc];
                                                     }];
    
//    REMenuItem *sortTitleDesc = [[REMenuItem alloc] initWithTitle:@"タイトルで降順に並び替え"
//                                                      image:nil
//                                           highlightedImage:nil
//                                                     action:^(REMenuItem *item) {
//                                                         [self sort:kSortTypeTitleDesc];
//                                                     }];
    
    REMenuItem *sortDateDesc = [[REMenuItem alloc] initWithTitle:@"発売日の新しい順"
                                                      image:nil
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {
                                                         [self sort:kSortTypeDateDesc];
                                                     }];
    
    REMenuItem *sortDateAsc = [[REMenuItem alloc] initWithTitle:@"発売日の古い順"
                                                      image:nil
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {
                                                         [self sort:kSortTypeDateAsc];
                                                     }];
    
    REMenuItem *sortAddDesc = [[REMenuItem alloc] initWithTitle:@"登録の新しい順"
                                                      image:nil
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {
                                                         [self sort:kSortTypeAddDesc];
                                                     }];
    
    REMenuItem *sortAddAsc = [[REMenuItem alloc] initWithTitle:@"登録の古い順"
                                                      image:nil
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {
                                                         [self sort:kSortTypeAddAsc];
                                                     }];
    
    REMenuItem *showTile = [[REMenuItem alloc] initWithTitle:@"タイル表示"
                                                      image:nil
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {
                                                         [self.navigationController popViewControllerAnimated:YES];
                                                     }];
    
//https://github.com/romaonthego/REMenu/blob/master/REMenuExample/REMenuExample/Classes/Controllers/NavigationViewController.m
    self.menu = [[REMenu alloc] initWithItems:@[sortTitleAsc, sortDateDesc, sortDateAsc, sortAddDesc, sortAddAsc, showTile]];
    self.menu.cornerRadius = 4;
    self.menu.shadowRadius = 4;
    self.menu.shadowColor = [UIColor blackColor];
    self.menu.shadowOffset = CGSizeMake(0, 1);
    self.menu.shadowOpacity = 1;
    self.menu.separatorOffset = CGSizeMake(15.0, 0.0);
    self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15.0f];
    self.menu.textColor = [UIColor whiteColor];
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
    
    _sortType = kSortTypeTitleAsc;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getBookshelf];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self.menu isOpen]) [self.menu close];
}

- (void)didTapAddBook:(id)selector {
    [SearchViewController showForAddingBookToBookshelf:self.navigationController];
}

- (void)didTapSort:(id)selector {
    if ([self.menu isOpen]) [self.menu close];
    [self.menu showFromNavigationController:self.navigationController];
}

- (void)sort:(SortType)sortType {
    _sortType = sortType;
    switch (sortType) {
        case kSortTypeTitleAsc:  [self sortByTitleAsc]; break;
        case kSortTypeTitleDesc: [self sortByTitleDesc]; break;
        case kSortTypeDateDesc: [self sortByDateDesc]; break;
        case kSortTypeDateAsc: [self sortByDateAsc]; break;
        case kSortTypeAddDesc: [self sortByCreatedAtDesc]; break;
        case kSortTypeAddAsc: [self sortByCreatedAtAsc]; break;
    }
    [self.tableView reloadData];
}

- (void)sortByTitleAsc {
    NSArray* bookshelves = [_bookshelves sortedArrayUsingSelector:@selector(compareTitle:)];
    _bookshelves = [bookshelves mutableCopy];
}

- (void)sortByTitleDesc {
    NSArray* bookshelves = [_bookshelves sortedArrayUsingSelector:@selector(compareTitleInv:)];
    _bookshelves = [bookshelves mutableCopy];
}

- (void)sortByDateDesc {
    NSArray* bookshelves = [_bookshelves sortedArrayUsingSelector:@selector(comparePublicationDateInv:)];
    _bookshelves = [bookshelves mutableCopy];
}

- (void)sortByDateAsc {
    NSArray* bookshelves = [_bookshelves sortedArrayUsingSelector:@selector(comparePublicationDate:)];
    _bookshelves = [bookshelves mutableCopy];
}

- (void)sortByCreatedAtDesc {
    NSArray* bookshelves = [_bookshelves sortedArrayUsingSelector:@selector(compareCreatedAtInv:)];
    _bookshelves = [bookshelves mutableCopy];
}

- (void)sortByCreatedAtAsc {
    NSArray* bookshelves = [_bookshelves sortedArrayUsingSelector:@selector(compareCreatedAt:)];
    _bookshelves = [bookshelves mutableCopy];
}

- (void)getBookshelf {
    _bookshelves = [NSMutableArray array];
    [Backend.shared getBookshelf:_user->userId option:@{} callback:^(NSDictionary* res, NSError *error) {
        if (error) {
            NSLog(@"Error - getBookshelf: %@", error);
        }
        else {
            NSArray* bookshelves = res[@"bookshelves"];
            [bookshelves enumerateObjectsUsingBlock:^(NSDictionary* bookshelf, NSUInteger idx, BOOL *stop) {
                [_bookshelves addObject:[Bookshelf initWithDic:bookshelf]];
            }];
            
            [self sort:_sortType];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _bookshelves.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BookShelfListCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (_bookshelves.count <= 0) return cell; // 非同期処理バグの一時的な対処

    Bookshelf* bookshelf = _bookshelves[indexPath.row];
    Book* book = bookshelf->book;
    cell.titleLabel.text = book->title;
    [cell.bookImage my_setImageWithURL:book->coverImageUrl];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_bookshelves.count <= 0) return; // 非同期処理バグの一時的な対処
    
    Bookshelf* bookshelf = _bookshelves[indexPath.row];
    if (_listType == kListTypeMyBookshelf) {
        [BookDetailViewController showForRemovingBookFromBookshelf:self book:bookshelf->book];
    }
    else {
        [BookDetailViewController showForRequestingBook:self bookshelf:bookshelf];
    }
    
}

#pragma mark - Showing

+ (void)showForMyBookshelf:(UIViewController*)parent {
    BookShelfListViewController* vc = [BookShelfListViewController new];
    vc.listType = kListTypeMyBookshelf;
    vc.user = My.shared.user;
    vc.title = @"本棚";
    [parent.navigationController pushViewController:vc animated:YES];
}

+ (void)showForFriendBookshelf:(UIViewController*)parent user:(User*)user {
    BookShelfListViewController* vc = [BookShelfListViewController new];
    vc.listType = kListTypeFriendBookshelf;
    vc.user = user;
    vc.title = [NSString stringWithFormat:@"%@ の本棚", user->fullname];
    [parent.navigationController pushViewController:vc animated:YES];
}

@end
