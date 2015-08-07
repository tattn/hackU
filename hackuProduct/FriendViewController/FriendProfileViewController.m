
#import "FriendProfileViewController.h"
#import "FriendBookShelfController.h"
#import "AlertHelper.h"
#import "Backend.h"
#import "UIImageViewHelper.h"

@interface FriendProfileViewController ()

@property User* user;

@end

@implementation FriendProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"プロフィール";
    
    self.friendImage.layer.cornerRadius = self.friendImage.frame.size.width / 2.f;
    self.friendImage.layer.masksToBounds = YES;
    self.friendImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.friendImage.layer.borderWidth = 5;
    [self.friendImage my_setImageWithURL:PROFILE_IMAGE_URL(_user->userId) defaultImage:[UIImage imageNamed:@"ProfileImageDefault"]];
    
    self.bookShelfButton.layer.cornerRadius = 8;
    self.bookShelfButton.clipsToBounds = YES;
    self.blockButton.layer.cornerRadius = 8;
    self.blockButton.clipsToBounds = YES;
    
    self.friendNameLabel.text = _user->fullname;
    self.friendWordLabel.text = _user->comment;
    self.registerNumberLabel.text = [NSNumber numberWithInt:_user->bookNum].stringValue;
    self.rentNumberLabel.text = [NSNumber numberWithInt:_user->lendNum].stringValue;
    self.borrowNumberLabel.text = [NSNumber numberWithInt:_user->borrowNum].stringValue;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)bookShelfButton:(UIButton *)sender {
    FriendBookShelfController *vc = [FriendBookShelfController new];
    NSString *title = [NSString stringWithFormat:@"%@ の本棚", _user->fullname];
    vc.title = title;
    vc.user = _user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)blockButton:(UIButton *)sender {
    [AlertHelper showYesNo:self title:@"フレンドのブロック" msg:@"フレンドをブロックします。本当によろしいですか？"
                  yesTitle:@"ブロック" noTitle:@"キャンセル" yes:^() {
                      [Backend.shared addBlacklist:_user->userId option:@{} callback:^(id responseObject, NSError *error) {
                      }];
                  } no:^() {
                  }];
}

+ (void)show:(UIViewController*)parent user:(User*)user {
    FriendProfileViewController* vc = [FriendProfileViewController new];
    vc.user = user;
    [parent.navigationController pushViewController:vc animated:YES];
}

@end
