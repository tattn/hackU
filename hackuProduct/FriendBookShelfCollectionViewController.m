
#import "FriendBookShelfCollectionViewController.h"
#import "FriendBookShelfCell.h"
#import "Backend.h"
#import "FriendBookDetailViewController.h"

@interface FriendBookShelfCollectionViewController ()

@end

@implementation FriendBookShelfCollectionViewController

static NSString * const reuseIdentifier = @"FriendBookShelfCell";

- (id)init {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 150)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    return [super initWithCollectionViewLayout: flowLayout];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    //戻るボタンの文字をなくす
    UIBarButtonItem* btn = [[UIBarButtonItem alloc] initWithTitle:@""
                                                            style:UIBarButtonItemStylePlain
                                                           target:nil
                                                           action:nil];
    self.navigationItem.backBarButtonItem = btn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FriendBookShelfCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    FriendBookDetailViewController *friendBookDetailViewController = [[FriendBookDetailViewController alloc] init];
    
    [self.navigationController pushViewController:friendBookDetailViewController animated:YES];
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

@end
