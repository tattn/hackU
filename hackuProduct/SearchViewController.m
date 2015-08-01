
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

@property int searchStart;
@property BOOL searchEnd;

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
    _searchStart = 0;
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
    _searchStart = -1;
    _searchEnd = NO;
    _books = [NSMutableArray array];
    _bookshelves = [NSMutableArray array];
    [self resumeSearchBook];
}

- (void)resumeSearchBook {
    if (_searchEnd) return;
    if (![self checkSearchQuery]) return; // 空文字や空白文字だけの時は検索しない
    
    _searchStart++; // 次の検索結果へ
    _searchEnd = YES;
    
    if (_mode == kModeAddingBookToBookshelf) {
        NSNumber* start = [NSNumber numberWithInt:_searchStart];
        [Backend.shared searchBook:@{@"title":_searchBar.text, @"amazon":@"", @"start":start} callback:^(id res, NSError *error) {
            if (error) {
                NSLog(@"Error - searchBook: %@", error);
            }
            else {
                NSArray* books = res[@"books"];
                if (books.count > 0) {
                    [_books addObjectsFromArray:books];
                    [_tableView reloadData];
                    _searchEnd = NO;
                }
            }
        }];
    }
    else if (_mode == kModeRequest) {
        [Backend.shared getFriend:@{} callback:^(id res, NSError *error) {
            NSArray* friends = res[@"users"];
            [friends enumerateObjectsUsingBlock:^(id friend, NSUInteger idx, BOOL *stop) {
                int friendId = ((NSNumber*)friend[@"userId"]).intValue;
                [Backend.shared searchBookInBookshelf:friendId option:@{@"title":_searchBar.text} callback:^(id res2, NSError *error) {
                    NSArray* bookshelves = res2[@"bookshelves"];
                    if (bookshelves.count > 0) {
                        [_bookshelves addObjectsFromArray:bookshelves];
                        if (idx == friends.count - 1) {
                            [_tableView reloadData];
                            _searchEnd = NO;
                        }
                    }
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //一番下までスクロールしたかどうか
    if (_tableView.contentOffset.y >= (_tableView.contentSize.height - _tableView.bounds.size.height)) {
        if (!_searchEnd) {
            [self resumeSearchBook];
        }
    }
}


- (IBAction)changeMode:(UISwitch*)sender {
    if (sender.on) {
        _mode = kModeRequest;
    }
    else {
        _mode = kModeAddingBookToBookshelf;
    }
    [self searchBook:self.searchBar.text];
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
}


#pragma mark - for showing

+ (void)showForAddingBookToBookshelf:(UINavigationController*)nc {
    [APP_DELEGATE switchTabBarController:3];
}

@end
