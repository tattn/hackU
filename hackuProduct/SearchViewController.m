
#import "SearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BookDetailViewController.h"
#import "UIImageViewHelper.h"
#import "User.h"
#import "Backend.h"
#import "BarcodeView.h"
#import "Toast.h"

@implementation SearchResultCell
@end

@interface SearchViewController ()

@property UITableView* tableView;
@property BarcodeView* barcodeView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UISwitch *searchSwitch;

@property NSMutableArray* books;
@property NSMutableArray* bookshelves;

@property (nonatomic, strong) MNMBottomPullToRefreshManager* refreshManager;

@end

@implementation SearchViewController

static NSString* SearchResultCellId = @"SearchResultCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.placeholder = @"タイトル, 著者, ISBN...";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.delegate = self;
    [self.searchBar becomeFirstResponder];
    
    UINib *nib = [UINib nibWithNibName:SearchResultCellId bundle:nil];
    _tableView = [UITableView new];
    [_tableView registerNib:nib forCellReuseIdentifier:SearchResultCellId];
    [_mainView addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.frame = CGRectMake(0, 0, _mainView.frame.size.width, _mainView.frame.size.height);
    
    _barcodeView = [BarcodeView new];
    _barcodeView.frame = CGRectMake(0, 0, _mainView.frame.size.width, _mainView.frame.size.height);
    _barcodeView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _barcodeView.delegate = self;
    [_barcodeView setupCamera];
    
    [_searchSegmentControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    
    _mode = kModeAddingBookToBookshelf;
    
    self.refreshManager = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:_tableView withClient:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)segmentedControlAction:(UISegmentedControl*)seg {
    [self changeMainView:seg.selectedSegmentIndex];
}

- (void)changeMainView:(long)mode { //FIXME: must use enum
    if(mode == 0) {
        [_barcodeView removeFromSuperview];
        [_mainView addSubview:_tableView];
        [_barcodeView stop];
    }else {
        [_tableView removeFromSuperview];
        [_mainView addSubview:_barcodeView];
        [_barcodeView start];
        [Toast show:_mainView message:@"本のバーコードにかざして下さい。"];
    }
    _searchSegmentControl.selectedSegmentIndex = mode;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    [self searchBook:self.searchBar.text];
}

- (void)detectedBarcode:(NSString *)code {
    [self changeMainView:0];
    [self searchBook:code];
}

- (BOOL)checkSearchQuery {
    return ![[self.searchBar.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""];
}

- (void)searchBook:(NSString*)query {
    self.searchBar.text = query;
    
    if (![self checkSearchQuery]) return; // 空文字や空白文字だけの時は検索しない
    
    if (_mode == kModeAddingBookToBookshelf) {
        [Backend.shared searchBook:@{@"title":query, @"amazon":@""} callback:^(id res, NSError *error) {
            if (error) {
                NSLog(@"Error - searchBook: %@", error);
            }
            else {
                _books = res[@"books"];
                [_tableView reloadData];
            }
        }];
    }
    else if (_mode == kModeRequest) {
        _bookshelves = [NSMutableArray array];
        [Backend.shared getFriend:@{} callback:^(id res, NSError *error) {
            NSArray* friends = res[@"users"];
            [friends enumerateObjectsUsingBlock:^(id friend, NSUInteger idx, BOOL *stop) {
                int friendId = ((NSNumber*)friend[@"userId"]).intValue;
                [Backend.shared searchBookInBookshelf:friendId option:@{@"title":query} callback:^(id res2, NSError *error) {
                    [_bookshelves addObjectsFromArray:res2[@"bookshelves"]];
                    if (idx == friends.count - 1) [_tableView reloadData];
                }];
            }];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_mode == kModeAddingBookToBookshelf) {
        return _books.count;
    }
    else {
        return _bookshelves.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell* cell = [tableView dequeueReusableCellWithIdentifier:SearchResultCellId];
    
    cell.addBookLabel.layer.cornerRadius = 13;
    cell.addBookLabel.clipsToBounds = YES;
    
    NSDictionary* book;
    if (_mode == kModeRequest) {
        book = ((NSDictionary*)_bookshelves[indexPath.row])[@"book"];
    }
    else {
        book = _books[indexPath.row];
    }
    NSString *title = book[@"title"];
    NSString *author = book[@"author"];
    NSString *bookInfo = [NSString stringWithFormat:@"%@\n\n%@", title, author];
    cell.titleLabel.text = bookInfo;
    [cell.bookImage my_setImageWithURL:book[@"coverImageUrl"]];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAddLabel:)];
    [cell.addBookLabel addGestureRecognizer:tapGesture];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 127;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (_mode) {
        case kModeRequest:
            [BookDetailViewController showForRequestingBook:self bookshelf:_bookshelves[indexPath.row]];
            break;
            
        case kModeAddingBookToBookshelf:
            [BookDetailViewController showForAddingBookToBookshelf:self book:_books[indexPath.row]];
            break;
            
        default:
            break;
    }
}

# pragma mark - MNMBottomPullToRefreshManager

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshManager tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshManager tableViewReleased];
}

- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {

    [self performSelector:@selector(refresh) withObject:nil afterDelay:0.3f];
}

- (void)refresh {
    // データ更新
    if ([self checkSearchQuery]) {
        
    }

    [self.refreshManager tableViewReloadFinished];
}


- (IBAction)changeMode:(UISwitch*)sender {
    if (sender.on) {
        _mode = kModeRequest;
    }
    else {
        _mode = kModeAddingBookToBookshelf;
    }
}

#pragma mark - tap AddLabel

- (void)tapAddLabel:(UIGestureRecognizer*)sender {
    CGPoint p = [sender locationInView:self.tableView];
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:p];
    NSDictionary *book = _books[path.row];
    NSNumber *bookId = book[@"bookId"];
    [Backend.shared addBookToBookshelf:User.shared.userId bookId:bookId.intValue option:@{} callback:^(id responseObject, NSError *error){
        [Toast show:_mainView message:@"本棚に登録しました"];
    }];
    NSLog(@"tapped");
}


#pragma mark - for showing

+ (void)showForAddingBookToBookshelf:(UINavigationController*)nc {
    [APP_DELEGATE switchTabBarController:3];
}

@end
