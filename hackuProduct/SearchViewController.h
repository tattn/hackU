
#import "ImprovedViewController.h"
#import "BarcodeView.h"

@interface SearchViewController : ImprovedViewController<UISearchBarDelegate, BarcodeDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchSegmentControl;

typedef NS_ENUM (NSUInteger, Mode) {
    kModeRequest,
    kModeAddingBookToBookshelf,
};

@property Mode mode;

+ (void)showForAddingBookToBookshelf:(UINavigationController*)nc;

@end


@interface SearchResultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bookImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end
