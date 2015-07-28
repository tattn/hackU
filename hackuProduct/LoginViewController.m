
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "LoginViewController.h"
#import "Backend.h"

@interface LoginViewController ()

typedef NS_ENUM (NSUInteger, kMode) {
    kModeLogin,
    kModeSignup,
};

@property (weak, nonatomic) IBOutlet UITextField *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *passLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UITextField *lastnameLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstnameLabel;

@property kMode mode;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailLabel.delegate = self;
    self.passLabel.delegate = self;
    self.lastnameLabel.delegate = self;
    self.firstnameLabel.delegate = self;
    
    self.loginButton.layer.cornerRadius = 8;
    self.loginButton.clipsToBounds = YES;
    self.switchButton.layer.cornerRadius = 8;
    self.switchButton.clipsToBounds = YES;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    [self.view addGestureRecognizer:gesture];
    
    _mode = kModeLogin;
    
    //FIXME: 前回のアカウントでログインする.ここで実行すると一瞬Viewが見えてしまうので、別の場所に移した方がいい
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults removeObjectForKey:@"LoginEmail"]; // for debug
    NSString *email = [userDefaults objectForKey:@"LoginEmail"];
    NSString *pass = [userDefaults objectForKey:@"LoginPass"];
    
    _emailLabel.text = email;
    _passLabel.text = pass;
//    if (email && pass) {
//        [self tryLogin:email password:pass];
//    }
}

- (IBAction)login:(id)sender {
    NSString *email = _emailLabel.text;
    NSString *pass = _passLabel.text;
    
    //FIXME: バリデーションを正しく行う
    if ([email isEqual: @""] || [pass isEqual: @""]) {
        return;
    }
    
    if (_mode == kModeLogin) {
        [self tryLogin:email password:pass];
    }
    else {
        NSString *firstname = _firstnameLabel.text;
        NSString *lastname = _lastnameLabel.text;
    
        //FIXME: バリデーションを正しく行う
        if ([firstname isEqual: @""] || [lastname isEqual: @""]) {
            return;
        }
        
        [self trySignup:email password:pass firstname:firstname lastname:lastname];
    }
}

- (void)tryLogin:(NSString*)email password:(NSString*)pass {
    Backend *backend = Backend.shared;
    [backend login:email password:pass option:@{} callback:^(id responseObject, NSError *error) {
        if (error) {
            //TODO: ログインに失敗したことをユーザーに通知する、テキストフィールドを赤枠にする
            NSLog(@"Login error: %@", error);
        }
        else {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:email forKey:@"LoginEmail"];
            [userDefaults setObject:pass forKey:@"LoginPass"];
            [userDefaults synchronize];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)trySignup:(NSString*)email password:(NSString*)pass
        firstname:(NSString*)fname lastname:(NSString*)lname {
    Backend *backend = Backend.shared;
    [backend addUser:email password:pass firstname:fname lastname:lname option:@{}
            callback:^(id responseObject, NSError *error) {
        if (error) {
            //TODO: 新規登録に失敗したことをユーザーに通知する、テキストフィールドを赤枠にする
            NSLog(@"Signup error");
        }
        else {
            [self tryLogin:email password:pass];
        }
    }];
}

- (IBAction)switchMode:(id)sender {
    _mode = (_mode + 1) % 2;
    if (_mode == kModeLogin) {
        _titleLabel.text = @"ログイン";
        [_loginButton setTitle:@"ログイン" forState:UIControlStateNormal];
        [_switchButton setTitle:@"新規登録" forState:UIControlStateNormal];
        [_nameView setHidden:YES];
    }
    else {
        _titleLabel.text = @"新規登録";
        [_loginButton setTitle:@"新規登録" forState:UIControlStateNormal];
        [_switchButton setTitle:@"ログイン" forState:UIControlStateNormal];
        [_nameView setHidden:NO];
    }
}

+ (void)showLoginIfNotLoggedIn:(UIViewController*)vc {
    LoginViewController *loginVC = [LoginViewController new];
    [loginVC setModalPresentationStyle:UIModalPresentationFullScreen];
    [vc presentViewController:loginVC animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)onSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

@end
