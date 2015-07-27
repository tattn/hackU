
#import "ImprovedViewController.h"

@interface SearchViewController : ImprovedViewController<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *barcodeButton;
- (IBAction)keywordButton:(UIButton *)sender;
- (IBAction)barcodeButton:(UIButton *)sender;

@end
