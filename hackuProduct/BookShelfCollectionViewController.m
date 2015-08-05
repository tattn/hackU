
#import "BookShelfCollectionViewController.h"
#import "BookShelfCell.h"
#import "Backend.h"
#import "LoginViewController.h"
#import "User.h"
#import "UIImageViewHelper.h"
#import "SearchViewController.h"
#import "BookDetailViewController.h"
#import <REMenu/REMenu.h>
#import "Book.h"


@interface BookShelfCollectionViewController ()

@property NSMutableArray* bookshelves;
@property int userId;

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

@end

@implementation BookShelfCollectionViewController

static NSString * const reuseIdentifier = @"BookShelfCell";

- (id)init {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    NSUInteger space = 15;
    CGSize listCellSize = CGSizeMake((screenSize.size.width - space * 4) / 3,
                                     ((screenSize.size.width - space * 4) / 3) * 1.5f);
    [flowLayout setItemSize:listCellSize];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    return [super initWithCollectionViewLayout: flowLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *backColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1.0];
    self.collectionView.backgroundColor = backColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"IconAddButton"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(didTapAddBook:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[[UIImage imageNamed:@"SortIcon"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(didTapSort:)];
    
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
    
    
//https://github.com/romaonthego/REMenu/blob/master/REMenuExample/REMenuExample/Classes/Controllers/NavigationViewController.m
    self.menu = [[REMenu alloc] initWithItems:@[sortTitleAsc, sortDateDesc, sortDateAsc, sortAddDesc, sortAddAsc]];
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
    
    UINib *nib = [UINib nibWithNibName:@"BookShelfCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
    
    _sortType = kSortTypeTitleAsc;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//TODO: 再表示するたびにデータベースに問い合わせをするのは良くないかも、重かったら必要なときだけ更新するように変える
//    if (_userId != User.shared.userId) {
        _userId = My.shared.user->userId;
        [self getBookshelf];
//    }
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
    [self.collectionView reloadData];
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
    [Backend.shared getBookshelf:_userId option:@{} callback:^(NSDictionary* res, NSError *error) {
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


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.bookshelves.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BookShelfCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (_bookshelves.count <= 0) return cell; // 非同期処理バグの一時的な対処
    Bookshelf* bookshelf = _bookshelves[indexPath.row];
    NSString* coverImageUrl = bookshelf->book->coverImageUrl;
    [cell.bookImage my_setImageWithURL:coverImageUrl];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (_bookshelves.count <= 0) return; // 非同期処理バグの一時的な対処
    Bookshelf* bookshelf = _bookshelves[indexPath.row];
    [BookDetailViewController showForRemovingBookFromBookshelf:self book:bookshelf->book];
}
/*
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    NSUInteger space = 15;
    NSUInteger bar = 64;
    CGSize listCellSize = CGSizeMake((screenSize.size.width - space * 4) / 3,
                                     (screenSize.size.height - bar - space * 4) / 3);
    return listCellSize;
}
 */

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(20, 15, 20, 15);
}
/*
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 30.0;
}
*/
@end
