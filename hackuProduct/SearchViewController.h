
#import "ImprovedViewController.h"
#import "BarcodeViewController.h"

@interface SearchViewController : ImprovedViewController<UISearchBarDelegate, BarcodeDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchSegmentControl;

typedef NS_ENUM (NSUInteger, Mode) {
    kModeNormal,
    kModeAddingBookToBookshelf,
};

@property Mode mode;

+ (void)showForAddingBookToBookshelf:(UINavigationController*)nc;

@end
