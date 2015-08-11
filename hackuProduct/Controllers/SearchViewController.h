
#import "ImprovedViewController.h"

@interface SearchViewController : ImprovedViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchSegmentControl;

typedef NS_ENUM (NSUInteger, SearchMode) {
    kSearchModeRequest,
    kSearchModeAddingBookToBookshelf,
};

@property SearchMode mode;

+ (void)showForAddingBookToBookshelf:(UINavigationController*)nc;

@end


@interface SearchResultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bookImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addBookLabel;
@end
