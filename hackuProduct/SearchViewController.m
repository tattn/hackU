
#import "SearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BookDetailViewController.h"
#import "UIImageViewHelper.h"
#import "Backend.h"
#import "BarcodeView.h"
#import "UIView+Toast.h"

@implementation SearchResultCell
@end

@interface SearchViewController ()

@property UITableView* tableView;
@property BarcodeView* barcodeView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UISwitch *searchSwitch;

@property NSMutableArray* books;
@property NSMutableArray* bookshelves;

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
        [_mainView makeToast:@"本のバーコードにかざして下さい。"];
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

- (void)searchBook:(NSString*)query {
    self.searchBar.text = query;
    
    if ([[query stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
        return; // 空文字や空白文字だけの時は検索しない
    }
    
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
    
    NSDictionary* book;
    if (_mode == kModeRequest) {
        book = ((NSDictionary*)_bookshelves[indexPath.row])[@"book"];
    }
    else {
        book = _books[indexPath.row];
    }
    
    cell.titleLabel.text = book[@"title"];
    [cell.bookImage my_setImageWithURL:book[@"coverImageUrl"]];
    
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

- (IBAction)changeMode:(UISwitch*)sender {
    if (sender.on) {
        _mode = kModeRequest;
    }
    else {
        _mode = kModeAddingBookToBookshelf;
    }
}


#pragma mark - for showing

+ (void)showForAddingBookToBookshelf:(UINavigationController*)nc {
    SearchViewController* vc = (SearchViewController*)[APP_DELEGATE switchTabBarController:3];
    vc.searchSwitch.on = YES;
    vc.mode = kModeAddingBookToBookshelf;
}

@end
