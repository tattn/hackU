
#import "SearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BarcodeViewController.h"
#import "SearchResultViewController.h"
#import "BookDetailViewController.h"
#import "UIImageViewHelper.h"
#import "Backend.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
//    UISegmentedControl *segmentControl = self.searchSegmentControl;
//    [segmentControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
//    [self.navigationItem setTitleView:segmentControl];
    
    UINib *nib = [UINib nibWithNibName:SearchResultCellId bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:SearchResultCellId];
}

- (void)segmentedControlAction:(UISegmentedControl*)seg {
    
    if(seg.selectedSegmentIndex == 0) {
        [self showSearchResult:self.searchBar.text];
    }else {
        BarcodeViewController *barcodeVC = [BarcodeViewController new];
        barcodeVC.hidesBottomBarWhenPushed = YES;
        barcodeVC.delegate = self;
        [self.navigationController pushViewController:barcodeVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    [self showSearchResult:self.searchBar.text];
}

- (void)detectedBarcode:(NSString *)code {
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
    SearchViewController* vc = [SearchViewController new];
    vc.title = @"追加する本の検索";
    vc.mode = kModeAddingBookToBookshelf;
    [nc pushViewController:vc animated: true];
}

@end
