
#import "BookShelfCollectionViewController.h"
#import "BookShelfCell.h"
#import "Backend.h"
#import "LoginViewController.h"
#import "MyBookDetailViewController.h"
#import "User.h"
#import "UIImageViewHelper.h"

@interface BookShelfCollectionViewController ()

@property NSMutableArray* books;
@property int userId;

@end

@implementation BookShelfCollectionViewController

static NSString * const reuseIdentifier = @"BookShelfCell";

- (id)init {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 150)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    return [super initWithCollectionViewLayout: flowLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_userId != User.shared.userId) {
        _userId = User.shared.userId;
        [self getBookshelf];
    }
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
    
    NSString *identifier = @"BookShelfCell";
    static BOOL nibCellLoaded = NO;
    
    if(!nibCellLoaded){
        UINib *nib = [UINib nibWithNibName:@"BookShelfCell" bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
        nibCellLoaded = YES;
    }
    
    BookShelfCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSString* coverImageUrl = self.books[indexPath.row][@"coverImageUrl"];
    [cell.bookImage my_setImageWithURL:coverImageUrl];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    MyBookDetailViewController *myBookDetailVC = [[MyBookDetailViewController alloc] init];
    myBookDetailVC.book = _books[indexPath.row];
    [self.navigationController pushViewController:myBookDetailVC animated:YES];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(20, 15, 20, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 30.0;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
