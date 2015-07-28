//
//  SettingViewController.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/23.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "SettingViewController.h"
#import "LicenseViewController.h"
#import "BlocklistViewController.h"
#import "ProfileEditViewController.h"
#import "AccountEditViewController.h"
#import "Backend.h"

@interface SettingViewController ()

//@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property UITableView *tableView;
@property UIButton *signoutButton;

@property NSArray *sections;

@property NSArray *menu;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _sections = @[@"ACCOUNT", @"BASIC", @"HELP", @"ABOUT"];

    _menu = @[
        @[@"プロフィール", @"アカウント"],
        @[@"通知", @"連携", @"ブロックリスト"],
        @[@"よくある質問", @"フィードバック"],
        @[@"Version", @"利用規約", @"プライバシーポリシー", @"ライセンス"],
    ];

    self.title = @"設定";
    self.view.backgroundColor = [UIColor whiteColor];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _tableView.sectionHeaderHeight = 40;
    _tableView.scrollEnabled = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [scrollView addSubview:_tableView];

    UIColor *themeColor = [UIColor colorWithRed:0.22 green:0.80 blue:0.49 alpha:1.0];
    _signoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _signoutButton.backgroundColor = themeColor;
    _signoutButton.tintColor = [UIColor whiteColor];
    _signoutButton.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:13.0f];
    [_signoutButton setTitle:@"ログアウト" forState:UIControlStateNormal];
    [_signoutButton addTarget:self
               action:@selector(signout:)
     forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:_signoutButton];

    [self.view addSubview:scrollView];
}

-(void)viewWillLayoutSubviews {
    //FIXME: 試行錯誤したがこれ以外の方法でうまくサイズ調整できなかった
    dispatch_async(dispatch_get_main_queue(), ^{
        UIScrollView *scrollView = (UIScrollView*)_tableView.superview;
        CGRect frame = self.view.frame;
        frame.size.height = _tableView.contentSize.height + _tableView.sectionHeaderHeight;
        _tableView.frame = frame;

        _signoutButton.frame = CGRectMake(20, frame.size.height + 10, frame.size.width - 40, 40);
        scrollView.contentSize = CGSizeMake(frame.size.width, frame.size.height + 50);
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)signout:(UIButton *)buttona {
    Backend *backend = Backend.shared;
    [backend logout: @{} callback:^(id responseObject, NSError *error) {
        if (error) {
            //TODO: ログアウトに失敗したことをユーザーに通知する?
            NSLog(@"Logout error: %@", error);
        }
        else {
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

// 文字色を変更するだけのために下記のメソッドを実装する必要があるらしい
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return _sections[section];
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [UIView new];
    v.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 320.0f, 30.0f)];
    UIColor *themeColor = [UIColor colorWithRed:0.22 green:0.80 blue:0.49 alpha:1.0];
    lbl.textColor = themeColor;
    lbl.text = _sections[section];
    lbl.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:16.0f];
    lbl.shadowColor = [UIColor whiteColor];
    lbl.shadowOffset = CGSizeMake(0, 1);
    [v addSubview:lbl];
    return v;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray*)_menu[section]).count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellId = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellId];
    }

    cell.textLabel.text = _menu[indexPath.section][indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:13.0f];

    if ([(NSString*)(_menu[indexPath.section][indexPath.row]) isEqual: @"Version"]) { //FIXME: use enum?
        // Version
        cell.detailTextLabel.text = @"1.0.0";
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *menuItem = _menu[indexPath.section][indexPath.row];
    if ([menuItem isEqual: @"プロフィール"]) { //FIXME: use enum?
        ProfileEditViewController *profileEditVC = [ProfileEditViewController new];
        profileEditVC.hidesBottomBarWhenPushed = YES;
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:profileEditVC];
        profileEditVC.title = @"プロフィール";
        [self presentViewController:nvc animated:YES completion:nil];
    }
    
    else if ([menuItem isEqual:@"アカウント"]) {
        AccountEditViewController *accountEditVC = [AccountEditViewController new];
        accountEditVC.hidesBottomBarWhenPushed = YES;
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:accountEditVC];
        accountEditVC.title = @"アカウント";
        [self presentViewController:nvc animated:YES completion:nil];
    }
    
    else if ([menuItem isEqual: @"ライセンス"]) { //FIXME: use enum?
        LicenseViewController *vc = [LicenseViewController new];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([menuItem isEqual: @"ブロックリスト"]) {
        BlocklistViewController *vc = [BlocklistViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
