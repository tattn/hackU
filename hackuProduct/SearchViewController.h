
#import "ImprovedViewController.h"
#import "BarcodeViewController.h"

@interface SearchViewController : ImprovedViewController<UISearchBarDelegate, BarcodeDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *barcodeButton;
- (IBAction)keywordButton:(UIButton *)sender;
- (IBAction)barcodeButton:(UIButton *)sender;

typedef NS_ENUM (NSUInteger, Mode) {
    kModeNormal,
    kModeAddingBookToBookshelf,
};

@property Mode mode;

+ (void)showForAddingBookToBookshelf:(UINavigationController*)nc;

@end
