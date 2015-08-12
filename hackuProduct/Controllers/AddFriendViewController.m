
#import "AddFriendViewController.h"
#import "User.h"
#import "Backend.h"
//#import "QRcodeView.h"
#import <TTToast/TTToast-Swift.h>
#import <TTScanView/TTScanView.h>
#import <TTScanView/TTScanView-Swift.h>

@interface AddFriendViewController () <TTScanDelegate>

@property (weak, nonatomic) IBOutlet UITextField *invitationCode;
@property (weak, nonatomic) IBOutlet UIView *qrOrCameraView;
@property (weak, nonatomic) IBOutlet UIButton *qrButton;
@property (weak, nonatomic) IBOutlet UILabel *myInvitationLabel;

@property TTScanView* scanView;

typedef NS_ENUM (NSUInteger, Mode) {
    kModeQR,
    kModeCamera,
    kModeMax,
};

@property Mode mode;

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.friendApplyButton.layer.cornerRadius = 8;
    self.friendApplyButton.clipsToBounds = YES;
    self.qrButton.layer.cornerRadius = 8;
    self.qrButton.clipsToBounds = YES;
    self.title = @"フレンドの追加";
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc]
                            initWithImage:[UIImage imageNamed:@"IconCancelButton"]
                            style:UIBarButtonItemStylePlain
                            target:self action:@selector(close)];
    self.navigationItem.rightBarButtonItems = @[btn];
    
    CGSize size = _qrOrCameraView.frame.size;
    _scanView = [TTScanView new];
    _scanView.frame = CGRectMake(0, 0, size.width, size.height);
    _scanView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _scanView.delegate = self;
//    [_scanView setupCamera];
    [_qrOrCameraView addSubview:_scanView];
    
    [Backend.shared getInvitationCode:@{} callback:^(id responseObject, NSError *error) {
        NSString* invitationCode = responseObject[@"invitation_code"];
        _myInvitationLabel.text = invitationCode;
        [_scanView showQRcode:invitationCode];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self changeMode:kModeQR];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)changeMode:(Mode)mode {
    _mode = mode;
    
    if (_mode == kModeQR) {
        [_qrButton setTitle:@"QRコードを読み取る" forState:UIControlStateNormal];
        [_scanView showQRcode:_myInvitationLabel.text];
        [self.view layoutIfNeeded];
    }
    else { // _mode == kModeCamera
        [_qrButton setTitle:@"QRコードを表示する" forState:UIControlStateNormal];
        [_scanView showCamera: TTScanViewCameraTypeQRcode];
        [self.view layoutIfNeeded];
        [TTToast show:@"相手のQRコードにかざして下さい。"];
    }
}

#pragma mark - scanview delegate


- (void)detectedCode:(NSString *)code {
    _invitationCode.text = code;
    [self changeMode:kModeQR];
}

#pragma mark - button delegates

- (IBAction)touchUpRequest:(id)sender {
    NSString* code = _invitationCode.text;
    
    Backend* backend = Backend.shared;
    [backend addFriend:code option:@{} callback:^(id responseObject, NSError *error) {
        if (error) {
            [TTToast show:@"招待コードが間違っています"];
            NSLog(@"addFriend error: %@\n", error);
        }
        else {
            [TTToast show:@"申請しました"];
            [self close];
        }
    }];
}

- (IBAction)touchUpQRbutton:(id)sender {
    [self changeMode:(_mode + 1) % kModeMax];
}

- (IBAction)touchInvitationCode:(UITapGestureRecognizer *)sender {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setValue:_myInvitationLabel.text forPasteboardType:@"public.utf8-plain-text"];
    [TTToast show:@"自分の招待コードをクリップボードにコピーしました"];
}

#pragma mark - item bar buttons

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
