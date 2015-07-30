
#import "SearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BarcodeViewController.h"
#import "SearchResultViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.placeholder = @"タイトル, 著者, ISBN...";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.delegate = self;
    [self.searchBar becomeFirstResponder];
    
    //ボタンの角を丸くする
    self.searchButton.layer.cornerRadius = 10;
    self.searchButton.clipsToBounds = YES;
    self.barcodeButton.layer.cornerRadius = 10;
    self.barcodeButton.clipsToBounds = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)keywordButton:(UIButton *)sender {
    [self showSearchResult:self.searchBar.text];
}

- (IBAction)barcodeButton:(UIButton *)sender {
    BarcodeViewController *barcodeVC = [BarcodeViewController new];
    barcodeVC.hidesBottomBarWhenPushed = YES;
    barcodeVC.delegate = self;
    [self.navigationController pushViewController:barcodeVC animated:YES];
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
    [SearchResultViewController show:self query:query];
}

+ (void)showForAddingBookToBookshelf:(UINavigationController*)nc {
    SearchViewController* vc = [SearchViewController new];
    vc.title = @"追加する本の検索";
    vc.mode = kModeAddingBookToBookshelf;
    [nc pushViewController:vc animated: true];
}

@end
