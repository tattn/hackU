
#import "FriendBookShelfController.h"
#import "BookShelfCell.h"
#import "Backend.h"
#import "UIImageView+WebImage.h"
#import "BookDetailViewController.h"
#import "BookShelfListViewController.h"
#import <REMenu/REMenu.h>
#import "Bookshelf.h"


@interface FriendBookShelfController ()
@end

@implementation FriendBookShelfController

static NSString * const reuseIdentifier = @"BookShelfCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem = nil;
    
    //戻るボタンの表示変更
    UIBarButtonItem* btn = [[UIBarButtonItem alloc] initWithTitle:@""
                                                            style:UIBarButtonItemStylePlain
                                                           target:nil
                                                           action:nil];
    self.navigationItem.backBarButtonItem = btn;
    
}

#pragma mark <UICollectionViewDataSource>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (self.bookshelves.count <= 0) return; // 非同期処理バグの一時的な対処
    [BookDetailViewController showForRequestingBook:self bookshelf:self.bookshelves[indexPath.row]];
}

@end
