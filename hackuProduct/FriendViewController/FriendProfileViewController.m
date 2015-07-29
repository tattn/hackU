
#import "FriendProfileViewController.h"

@interface FriendProfileViewController ()

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)bookShelfButton:(UIButton *)sender {
}

- (IBAction)blockButton:(UIButton *)sender {
}
@end
