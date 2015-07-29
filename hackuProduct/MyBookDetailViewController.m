
#import "MyBookDetailViewController.h"
#import "BookShelfCollectionViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import <RMUniversalAlert.h>
#import "Backend.h"
#import "User.h"

@interface MyBookDetailViewController ()

@end

@implementation MyBookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString* coverImageUrl = _book[@"coverImageUrl"];
    if (coverImageUrl != (id)[NSNull null]) { //TODO: null または空文字の時は仮画像を設定するといいかも
        NSURL *url = [NSURL URLWithString:coverImageUrl];
        [_bookImage sd_setImageWithURL:url
                        placeholderImage:[UIImage imageNamed:url.absoluteString]];
    }
    
    _bookTitleLabel.text = _book[@"title"];
    _publisherLabel.text = _book[@"manufacturer"];
    _authorLabel.text = _book[@"author"];
}

- (IBAction)tapDeleteBook:(id)sender {
    [RMUniversalAlert showAlertInViewController:self
                                      withTitle:@"本棚から削除"
                                        message:@"この本を本棚から削除します。本当によろしいですか？"
                              cancelButtonTitle:@"キャンセル"
                         destructiveButtonTitle:@"削除"
                              otherButtonTitles:@[]
                                       tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
                                           if (buttonIndex == alert.cancelButtonIndex) {
                                           } else if (buttonIndex == alert.destructiveButtonIndex) {
                                               [self deleteBook];
                                           }
                                       }];
}

- (void)deleteBook {
    NSNumber* bookId = _book[@"bookId"];
    [Backend.shared deleteBookInBookshelf:User.shared.userId bookId: bookId.intValue option:@{} callback:^(id responseObject, NSError *error) {
        BookShelfCollectionViewController* vc = (BookShelfCollectionViewController*)[self.navigationController popViewControllerAnimated:YES];
        [vc.collectionView reloadData];
    }];
}

@end
