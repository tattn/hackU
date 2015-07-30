
#import "SearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchResultViewController.h"
#import "BookDetailViewController.h"
#import "UIImageViewHelper.h"
#import "Backend.h"
#import "BarcodeView.h"
#import "UIView+Toast.h"

@interface SearchViewController ()

@property UITableView* tableView;
@property BarcodeView* barcodeView;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@property NSMutableArray* books;

@end

@implementation SearchViewController

static NSString* SearchResultCellId = @"SearchResultCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
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
    
    UISegmentedControl *segmentControl = self.searchSegmentControl;
    [segmentControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)segmentedControlAction:(UISegmentedControl*)seg {
    [self changeMode:seg.selectedSegmentIndex];
}

- (void)changeMode:(long)mode { //FIXME: must use enum
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
    [self showSearchResult:self.searchBar.text];
}

- (void)detectedBarcode:(NSString *)code {
    [self changeMode:0];
    [self showSearchResult:code];
}

- (void)showSearchResult:(NSString*)query {
    self.searchBar.text = query;
    [self searchBook:query];
}

- (void)searchBook:(NSString*)query {
    if ([[query stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
        return; // 空文字や空白文字だけの時は検索しない
    }
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _books.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell* cell = [tableView dequeueReusableCellWithIdentifier:SearchResultCellId];
    
    NSDictionary* book = _books[indexPath.row];
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
        case kModeNormal:
            break;
            
        case kModeAddingBookToBookshelf:
            [BookDetailViewController showForAddingBookToBookshelf:self book:_books[indexPath.row]];
            break;
            
        default:
            break;
    }
}

#pragma mark - for showing

+ (void)showForAddingBookToBookshelf:(UINavigationController*)nc {
    [APP_DELEGATE switchTabBarController:3];
//    SearchViewController* vc = [SearchViewController new];
//    vc.title = @"追加する本の検索";
//    vc.mode = kModeAddingBookToBookshelf;
//    [nc pushViewController:vc animated: true];
}

@end
