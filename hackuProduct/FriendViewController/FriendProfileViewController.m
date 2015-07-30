
#import "FriendProfileViewController.h"
#import "FriendBookShelfCollectionViewController.h"
#import "AlertHelper.h"
#import "Backend.h"

@interface FriendProfileViewController ()

@property NSDictionary* user;

@end

@implementation FriendProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //UIImageViewを円形にして表示する
    self.friendImage.layer.cornerRadius = self.friendImage.frame.size.width / 2.f;
    self.friendImage.layer.masksToBounds = YES;
    self.friendImage.layer.borderColor = [UIColor colorWithRed:0.22 green:0.80 blue:0.49 alpha:1.0].CGColor;
    self.friendImage.layer.borderWidth = 5;
    
    self.bookShelfButton.layer.cornerRadius = 8;
    self.bookShelfButton.clipsToBounds = YES;
    self.blockButton.layer.cornerRadius = 8;
    self.blockButton.clipsToBounds = YES;
    
    self.friendNameLabel.text = _user[@"fullname"]; // dirty hack
    self.registerNumberLabel.text = ((NSNumber*)_user[@"bookNum"]).stringValue;
    self.rentNumberLabel.text = ((NSNumber*)_user[@"lendNum"]).stringValue;
    self.borrowNumberLabel.text = ((NSNumber*)_user[@"borrowNum"]).stringValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)bookShelfButton:(UIButton *)sender {
    FriendBookShelfCollectionViewController *vc = [FriendBookShelfCollectionViewController new];
    NSString *title = [NSString stringWithFormat:@"%@ の本棚", _user[@"fullname"]];
    vc.title = title;
    vc.userId = ((NSNumber*)_user[@"userId"]).intValue;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)blockButton:(UIButton *)sender {
    [AlertHelper showYesNo:self title:@"フレンドのブロック" msg:@"フレンドをブロックします。本当によろしいですか？"
                  yesTitle:@"ブロック" noTitle:@"キャンセル" yes:^() {
                      NSNumber* userId = _user[@"userId"];
                      [Backend.shared addBlacklist:userId.intValue option:@{} callback:^(id responseObject, NSError *error) {
                      }];
                  } no:^() {
                  }];
}

+ (void)show:(UIViewController*)parent user:(NSDictionary*)user {
    FriendProfileViewController* vc = [FriendProfileViewController new];
    vc.user = user;
    [parent.navigationController pushViewController:vc animated:YES];
}

@end
