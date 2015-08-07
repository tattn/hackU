
#import <UIKit/UIKit.h>
#import <REMenu/REMenu.h>
#import "User.h"

@interface BookShelfController : UICollectionViewController

@property NSMutableArray* bookshelves;

@property User* user;


@property (strong, readwrite, nonatomic) REMenu *menu;

typedef NS_ENUM (int, BookshelfSortType) {
    kBookshelfSortTypeTitleAsc,
    kBookshelfSortTypeTitleDesc,
    kBookshelfSortTypeDateDesc,
    kBookshelfSortTypeDateAsc,
    kBookshelfSortTypeAddDesc,
    kBookshelfSortTypeAddAsc,
};

@property BookshelfSortType sortType;


@end
