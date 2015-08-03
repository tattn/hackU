
#import "BookShelfCollectionViewController.h"
#import "BookShelfCell.h"
#import "Backend.h"
#import "LoginViewController.h"
#import "User.h"
#import "UIImageViewHelper.h"
#import "SearchViewController.h"
#import "BookDetailViewController.h"

@interface BookShelfCollectionViewController ()

@property NSMutableArray* books;
@property int userId;

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
    
    UINib *nib = [UINib nibWithNibName:@"BookShelfCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//TODO: 再表示するたびにデータベースに問い合わせをするのは良くないかも、重かったら必要なときだけ更新するように変える
//    if (_userId != User.shared.userId) {
        _userId = User.shared.userId;
        [self getBookshelf];
//    }
}

- (void)didTapAddBook:(id)selector {
    [SearchViewController showForAddingBookToBookshelf:self.navigationController];
}

- (void)getBookshelf {
    _books = [NSMutableArray array];
    [Backend.shared getBookshelf:_userId option:@{} callback:^(NSDictionary* res, NSError *error) {
        if (error) {
            NSLog(@"Error - getBookshelf: %@", error);
        }
        else {
            NSArray* bookshelves = res[@"bookshelves"];
            [bookshelves enumerateObjectsUsingBlock:^(NSDictionary* bookshelf, NSUInteger idx, BOOL *stop) {
                NSDictionary* book = bookshelf[@"book"];
                [_books addObject:book];
            }];
            
            [self.collectionView reloadData];
        }
    }];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.books.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BookShelfCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (_books.count <= 0) return cell; // 非同期処理バグの一時的な対処
    NSString* coverImageUrl = self.books[indexPath.row][@"coverImageUrl"];
    [cell.bookImage my_setImageWithURL:coverImageUrl];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [BookDetailViewController showForRemovingBookFromBookshelf:self book:_books[indexPath.row]];
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
