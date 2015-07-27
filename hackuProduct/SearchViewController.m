
#import "SearchViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UISearchBar *searchBar = [[UISearchBar alloc] init];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)keywordButton:(UIButton *)sender {
}

- (IBAction)barcodeButton:(UIButton *)sender {
}
@end
