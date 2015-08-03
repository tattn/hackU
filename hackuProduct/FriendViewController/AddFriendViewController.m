
#import "AddFriendViewController.h"
#import "User.h"
#import "Backend.h"
#import "QRcodeView.h"
#import "Toast.h"

@interface AddFriendViewController ()

@property (weak, nonatomic) IBOutlet UITextField *invitationCode;
@property (weak, nonatomic) IBOutlet UIView *qrOrCameraView;
@property (weak, nonatomic) IBOutlet UIButton *qrButton;
@property (weak, nonatomic) IBOutlet UILabel *myInvitationLabel;

@property QRcodeView* qrCodeView;
@property BarcodeView* cameraView;

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
    _qrCodeView = [QRcodeView new];
    _qrCodeView.frame = CGRectMake(0, 0, size.width, size.height);
    _qrCodeView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _cameraView = [BarcodeView new];
    _cameraView.frame = CGRectMake(0, 0, size.width, size.height);
    _cameraView.delegate = self;
    [_cameraView setupCamera];
    
    [Backend.shared getInvitationCode:@{} callback:^(id responseObject, NSError *error) {
        NSString* invitationCode = responseObject[@"invitation_code"];
        _myInvitationLabel.text = invitationCode;
        [_qrCodeView setString:invitationCode];
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
        [_cameraView removeFromSuperview];
        [_qrOrCameraView addSubview:_qrCodeView];
        [_cameraView stop];
    }
    else { // _mode == kModeCamera
        [_qrButton setTitle:@"QRコードを表示する" forState:UIControlStateNormal];
        [_qrCodeView removeFromSuperview];
        [_qrOrCameraView addSubview:_cameraView];
        CGSize size = _qrOrCameraView.frame.size;
        _cameraView.frame = CGRectMake(0, 0, size.width, size.height);
        [self.view layoutIfNeeded];
        [_cameraView start:kBarcodeModeQRcode];
        [Toast show:self.view message:@"相手のQRコードにかざして下さい。"];
    }
}

#pragma mark - barcode delegate

- (void)detectedBarcode:(NSString *)code {
    _invitationCode.text = code;
    [self changeMode:kModeQR];
}

#pragma mark - button delegates

- (IBAction)touchUpRequest:(id)sender {
    NSString* code = _invitationCode.text;
    
    Backend* backend = Backend.shared;
    [backend addFriend:code option:@{} callback:^(id responseObject, NSError *error) {
        if (error) {
            [Toast show:self.view message:@"招待コードが間違っています"];
            NSLog(@"addFriend error: %@\n", error);
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)touchUpQRbutton:(id)sender {
    [self changeMode:(_mode + 1) % kModeMax];
}

- (IBAction)touchInvitationCode:(UITapGestureRecognizer *)sender {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setValue:_myInvitationLabel.text forPasteboardType:@"public.utf8-plain-text"];
    [Toast show:self.view message:@"自分の招待コードをクリップボードにコピーしました"];
}

#pragma mark - item bar buttons

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
