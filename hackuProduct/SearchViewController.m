
#import "SearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BarcodeViewController.h"
#import "SearchResultViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "BookDetailViewController.h"
#import "Backend.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationController.navigationBarHidden = YES;
    
    self.searchBar.placeholder = @"タイトル, 著者, ISBN...";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.delegate = self;
    [self.searchBar becomeFirstResponder];
    
    UISegmentedControl *segmentControl = self.searchSegmentControl;
    [segmentControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.navigationItem setTitleView:segmentControl];
}

- (void)segmentedControlAction:(UISegmentedControl*)seg {
    
    if(seg.selectedSegmentIndex == 0) {
        
        [self showSearchResult:self.searchBar.text];
        NSLog(@"keyword");
        
    }else {
        
        BarcodeViewController *barcodeVC = [BarcodeViewController new];
        barcodeVC.hidesBottomBarWhenPushed = YES;
        barcodeVC.delegate = self;
        [self.navigationController pushViewController:barcodeVC animated:YES];
        NSLog(@"barcode");
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
    [SearchResultViewController show:self query:query];
}

+ (void)showForAddingBookToBookshelf:(UINavigationController*)nc {
    SearchViewController* vc = [SearchViewController new];
    vc.title = @"追加する本の検索";
    vc.mode = kModeAddingBookToBookshelf;
    [nc pushViewController:vc animated: true];
}

@end
