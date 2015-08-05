
#import "FriendViewController.h"
#import "FriendTableViewCell.h"
#import "FriendBookShelfCollectionViewController.h"
#import "FriendProfileViewController.h"
#import "AddFriendViewController.h"
#import "AlertHelper.h"
#import "Backend.h"
#import "User.h"
#import "UIImageViewHelper.h"

@interface FriendViewController ()

@property NSMutableArray* friends;
@property int userId;

@end

@implementation FriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new]; // 余分なCellのセパレータを表示しないための処理
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"IconAddButton"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(didTapAddFriend:)];
    
    UINib *nib = [UINib nibWithNibName:@"FriendTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"FriendTableViewCell"];
    
    //戻るボタンの表示変更
    UIBarButtonItem* btn = [[UIBarButtonItem alloc] initWithTitle:@""
                                                            style:UIBarButtonItemStylePlain
                                                           target:nil
                                                           action:nil];
    self.navigationItem.backBarButtonItem = btn;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //TODO: 表示するたびにデータベースに問い合わせをするのは良くないかも、必要なときだけ更新するように変更する
//    if (_userId != User.shared.userId) {
        _userId = User.shared.userId;
        [self getAllFriends];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)getAllFriends {
    _friends = [NSMutableArray array];
    [Backend.shared getNewFriend:@{} callback:^(NSDictionary* res, NSError *error) {
        if (error) {
        }
        else {
            [self addFriends:res[@"users"] new:@YES];
            [Backend.shared getFriend:@{} callback:^(NSDictionary* res, NSError *error) {
                if (error) {
                }
                else {
                    [self addFriends:res[@"users"] new:@NO];
                    [self showBadge];
                    [self.tableView reloadData];
                }
            }];
        }
    }];
}

- (void)addFriends:(NSArray*)users new:(NSNumber*)new {
    [users enumerateObjectsUsingBlock:^(NSDictionary *user, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *friend = [@{@"new":new} mutableCopy];
        [friend addEntriesFromDictionary:user];
        [_friends addObject:friend];
    }];
}

- (void)allowNewFriendById:(int)userId {
    [AlertHelper showYesNo:self title:@"フレンド申請の許可" msg:@"フレンド申請を許可します。よろしいですか？" yesTitle:@"はい" yes:^() {
        [Backend.shared allowNewFriend:userId option:@{} callback:^(id responseObject, NSError *error) {
            [self getAllFriends];
        }];
    }];
}

- (void)rejectNewFriendById:(int)userId {
    [AlertHelper showYesNo:self title:@"フレンド申請の拒否" msg:@"フレンド申請を拒否します。よろしいですか？" yesTitle:@"はい" yes:^() {
        [Backend.shared rejectNewFriend:userId option:@{} callback:^(id responseObject, NSError *error) {
            [self getAllFriends];
        }];
    }];
}

- (void)deleteFriendById:(int)userId {
    [AlertHelper showYesNo:self title:@"フレンドの削除" msg:@"フレンドを削除します。本当によろしいですか？" yesTitle:@"削除" yes:^() {
        [Backend.shared deleteFriend:userId option:@{} callback:^(id responseObject, NSError *error) {
            [self getAllFriends];
        }];
    }];
}

- (void)blockFriendById:(int)userId {
    [AlertHelper showYesNo:self title:@"フレンドのブロック" msg:@"フレンドをブロックします。本当によろしいですか？" yesTitle:@"ブロック" yes:^() {
        [Backend.shared addBlacklist:userId option:@{} callback:^(id responseObject, NSError *error) {
            [self getAllFriends];
        }];
    }];
}

- (void)showBadge {
    __block int num = 0;
    [_friends enumerateObjectsUsingBlock:^(NSDictionary *friend, NSUInteger idx, BOOL *stop) {
        if ([(NSNumber*)friend[@"new"] isEqual: @YES]) {
            num++;
        }
    }];
    if (num > 0) {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", num];
    }
    else {
        self.navigationController.tabBarItem.badgeValue = nil; // nilにすると消える
    }
}

- (void)didTapAddFriend:(id)selector {
    AddFriendViewController *vc = [AddFriendViewController new];
//    vc.tabBarController.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated: YES];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _friends.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FriendTableViewCell" forIndexPath:indexPath];
    if (_friends.count <= 0) return cell; // 非同期処理バグの一時的な対処
    
    NSDictionary* friend = _friends[indexPath.row];
    cell.firendNameLabel.text = friend[@"fullname"];
    cell.friendCommentLabel.text = friend[@"comment"];
    cell.friendBookNumLabel.text = ((NSNumber*)friend[@"bookNum"]).stringValue;
    [cell.friendImage my_setImageWithURL:PROFILE_IMAGE_URL2(friend[@"userId"]) defaultImage:[UIImage imageNamed:@"ProfileImageDefault"]];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFriendIcon:)];
    [cell.friendImage addGestureRecognizer:tapGesture];
    
    if ([(NSNumber*)friend[@"new"] isEqual: @YES]) {
        cell.backgroundColor = [UIColor yellowColor];
    }
    else {
        cell.backgroundColor = nil;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_friends.count <= 0) return; // 非同期処理バグの一時的な対処
    
    NSDictionary* friend = _friends[indexPath.row];
    if ([(NSNumber*)friend[@"new"] isEqual: @NO]) {
        FriendBookShelfCollectionViewController *friendBookShelfCollectionVC = [[FriendBookShelfCollectionViewController alloc] init];
        
        NSString *title = [NSString stringWithFormat:@"%@ の本棚", friend[@"fullname"]];
        friendBookShelfCollectionVC.title = title;
        friendBookShelfCollectionVC.userId = ((NSNumber*)friend[@"userId"]).intValue;
        
        [self.navigationController pushViewController:friendBookShelfCollectionVC animated:YES];
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_friends.count <= 0) return @[]; // 非同期処理バグの一時的な対処
    
    NSDictionary* friend = _friends[indexPath.row];
    if ([(NSNumber*)friend[@"new"] isEqual: @YES]) {
        // 拒否ボタン
        UITableViewRowAction *rejectAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"拒否"
                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    NSDictionary* friend = _friends[indexPath.row];
                    [self rejectNewFriendById:((NSNumber*)friend[@"userId"]).intValue];
        }];
        
        // 許可ボタン
        UITableViewRowAction *allowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"許可"
                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    NSDictionary* friend = _friends[indexPath.row];
                    [self allowNewFriendById:((NSNumber*)friend[@"userId"]).intValue];
        }];
        return @[rejectAction, allowAction];
    }
    else {
        // 削除ボタン
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"削除"
                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    NSDictionary* friend = _friends[indexPath.row];
                    [self deleteFriendById:((NSNumber*)friend[@"userId"]).intValue];
        }];
        
        // ブロックボタン
        UITableViewRowAction *blockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"ブロック"
                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    NSDictionary* friend = _friends[indexPath.row];
                    [self blockFriendById:((NSNumber*)friend[@"userId"]).intValue];
        }];
        return @[deleteAction, blockAction];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // editActionsFroWorAtIndexPath の有効化
}

#pragma mark - tap imageView

- (void)tapFriendIcon:(UITapGestureRecognizer*)sender {
    if (_friends.count <= 0) return; // 非同期処理バグの一時的な対処
    CGPoint p = [sender locationInView:self.tableView];
    NSIndexPath* path = [self.tableView indexPathForRowAtPoint:p];
    [FriendProfileViewController show:self user:_friends[path.row]];
}

@end
