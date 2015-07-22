
#import "BookShelfCollectionViewController.h"
#import "BookShelfCell.h"
#import "Backend.h"
#import "LoginViewController.h"

@interface BookShelfCollectionViewController ()

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
    
    // WebAPI サンプル　要らなくなったら消して下さい
//    Backend *backend = [Backend shared];
//    [backend getBook:1 option:@{} callback:^(id json, NSError *error) {
////    [backend addBook:@"はろー" option:@{} callback:^(id json, NSError *error) {
////    [backend updateBook:20 option:@{@"title":@"ほげ"} callback:^(id json, NSError *error) {
////    [backend searchBook:@{@"title":@"ワンピース"} callback:^(id json, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        }
//        else {
//            NSLog(@"JSON: %@", json);
//            
////            searchBookで最初に見つかった本のタイトルを取得する方法
////            NSLog(@"JSON: %@", json[@"books"][0][@"title"]);
//        }
//    }];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    
    LoginViewController *loginVC = [LoginViewController new];
    [loginVC setModalPresentationStyle:UIModalPresentationFullScreen];
//    loginVC.delegate = self;
    
    [self presentViewController:loginVC animated:YES completion:nil];
    
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
    
    NSString *identifier = @"BookShelfCell";
    static BOOL nibCellLoaded = NO;
    
    if(!nibCellLoaded){
        UINib *nib = [UINib nibWithNibName:@"BookShelfCell" bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
        nibCellLoaded = YES;
    }
    
    BookShelfCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    return cell;
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
