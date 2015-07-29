
#import "FriendBookDetailViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import <RMUniversalAlert.h>
#import "Backend.h"
#import "User.h"
#import "UIImageViewHelper.h"
#import "SNS.h"

@interface FriendBookDetailViewController ()

@end

@implementation FriendBookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDictionary* book = _bookshelf[@"book"];
    NSString* coverImageUrl = book[@"coverImageUrl"];
    [_friendBookImage my_setImageWithURL: coverImageUrl];
    
    _bookTitleLabel.text = book[@"title"];
    _publisherLabel.text = book[@"manufacturer"];
    _authorLabel.text = book[@"author"];
    
    [self checkRequest];
    [self checkLending];
}

- (void) checkRequest {
    //FIXME: 自分以外の誰かがリクエストしている時もボタンが押せなくなる.現在はそれが仕様.
    [Backend.shared getRequest:_userId option:@{} callback:^(id responseObject, NSError *error) {
        NSArray* books = responseObject[@"books"];
        [books enumerateObjectsUsingBlock:^(NSDictionary* book, NSUInteger idx, BOOL *stop) {
            NSNumber* bookId = book[@"bookId"];
            if ([bookId isEqualToNumber: _bookshelf[@"book"][@"bookId"]]) {
                [_rentRequestButton setTitle:@"リクエスト中" forState:UIControlStateNormal];
                _rentRequestButton.enabled = NO;
            }
        }];
    }];
}

- (void) checkLending {
    NSNumber* borrowerId = _bookshelf[@"borrowerId"];
    if (![borrowerId isEqualToNumber:@0]) {
        [_rentRequestButton setTitle:@"貸出中" forState:UIControlStateNormal];
        _rentRequestButton.enabled = NO;
    }
}

- (IBAction)tapRequest:(id)sender {
    [RMUniversalAlert showAlertInViewController:self
                                      withTitle:@"本のリクエスト"
                                        message:@"この本のリクエストを送ります。よろしいですか？"
                              cancelButtonTitle:@"キャンセル"
                         destructiveButtonTitle:@"はい"
                              otherButtonTitles:@[]
                                       tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
                                           if (buttonIndex == alert.cancelButtonIndex) {
                                           } else if (buttonIndex == alert.destructiveButtonIndex) {
                                               [self requestBook];
                                           }
                                       }];
}

- (void)requestBook {
    NSNumber* bookId = _bookshelf[@"book"][@"bookId"];
    [Backend.shared addRequest:_userId bookId:bookId.intValue option:@{} callback:^(id responseObject, NSError *error) {
        ;
    }];
}


@end
