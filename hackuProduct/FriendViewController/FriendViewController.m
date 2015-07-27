
#import "FriendViewController.h"
#import "FriendTableViewCell.h"
#import "FriendBookShelfCollectionViewController.h"
#import "FriendBookShelfCell.h"
#import "AddFriendViewController.h"
#import <RMUniversalAlert.h>
#import "Backend.h"

@interface FriendViewController ()

@property NSMutableArray* friends;

@end

@implementation FriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new]; // 余分なCellのセパレータを表示しないための処理
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
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
    
    [self getAllFriends];
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
        NSString *fullname = [NSString stringWithFormat:@"%@ %@", user[@"lastname"], user[@"firstname"]];
        [_friends addObject:@{@"id":user[@"userId"], @"name":fullname, @"new":new}];
    }];
}

- (void)allowNewFriendById:(int)userId {
    [Backend.shared allowNewFriend:userId option:@{} callback:^(id responseObject, NSError *error) {
        [self getAllFriends];
    }];
}

- (void)rejectNewFriendById:(int)userId {
    [Backend.shared rejectNewFriend:userId option:@{} callback:^(id responseObject, NSError *error) {
        [self getAllFriends];
    }];
}

- (void)deleteFriendById:(int)userId {
    [RMUniversalAlert showAlertInViewController:self
                                      withTitle:@"フレンドの削除"
                                        message:@"フレンドを削除します。本当によろしいですか？"
                              cancelButtonTitle:@"キャンセル"
                         destructiveButtonTitle:@"削除"
                              otherButtonTitles:@[]
                                       tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
                                           if (buttonIndex == alert.cancelButtonIndex) {
                                           } else if (buttonIndex == alert.destructiveButtonIndex) {
                                               
    [Backend.shared deleteFriend:userId option:@{} callback:^(id responseObject, NSError *error) {
        [self getAllFriends];
    }];
                                               
                                           }
                                       }];
}

- (void)blockFriendById:(int)userId {
    [RMUniversalAlert showAlertInViewController:self
                                      withTitle:@"フレンドのブロック"
                                        message:@"フレンドをブロックします。本当によろしいですか？"
                              cancelButtonTitle:@"キャンセル"
                         destructiveButtonTitle:@"ブロック"
                              otherButtonTitles:@[]
                                       tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
                                           if (buttonIndex == alert.cancelButtonIndex) {
                                           } else if (buttonIndex == alert.destructiveButtonIndex) {
                                               
    [Backend.shared addBlacklist:userId option:@{} callback:^(id responseObject, NSError *error) {
        [self getAllFriends];
    }];
                                               
                                           }
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
    [self.navigationController pushViewController:vc animated: true];
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
    
    NSDictionary* friend = _friends[indexPath.row];
    cell.firendNameLabel.text = friend[@"name"];
    
    if ([(NSNumber*)friend[@"new"] isEqual: @YES]) {
        cell.backgroundColor = [UIColor yellowColor];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* friend = _friends[indexPath.row];
    if ([(NSNumber*)friend[@"new"] isEqual: @NO]) {
        FriendBookShelfCollectionViewController *friendBookShelfCollectionVC = [[FriendBookShelfCollectionViewController alloc] init];
        
        
        NSString *name = friend[@"name"];
        NSString *shelf = @"の本棚";
        NSString *str = [NSString stringWithFormat:@"%@ %@",name,shelf];
        friendBookShelfCollectionVC.title = str;
        
        
        [self.navigationController pushViewController:friendBookShelfCollectionVC animated:YES];
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* friend = _friends[indexPath.row];
    if ([(NSNumber*)friend[@"new"] isEqual: @YES]) {
        // 拒否ボタン
        UITableViewRowAction *rejectAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"拒否"
                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    NSDictionary* friend = _friends[indexPath.row];
                    [self rejectNewFriendById:((NSNumber*)friend[@"id"]).intValue];
        }];
        
        // 許可ボタン
        UITableViewRowAction *allowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"許可"
                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    NSDictionary* friend = _friends[indexPath.row];
                    [self allowNewFriendById:((NSNumber*)friend[@"id"]).intValue];
        }];
        return @[rejectAction, allowAction];
    }
    else {
        // 削除ボタン
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"削除"
                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    NSDictionary* friend = _friends[indexPath.row];
                    [self deleteFriendById:((NSNumber*)friend[@"id"]).intValue];
        }];
        
        // ブロックボタン
        UITableViewRowAction *blockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"ブロック"
                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    NSDictionary* friend = _friends[indexPath.row];
                    [self blockFriendById:((NSNumber*)friend[@"id"]).intValue];
        }];
        return @[deleteAction, blockAction];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
//    NSDictionary* friend = _friends[indexPath.row];
//    return ((NSNumber*)friend[@"new"]).intValue;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // editActionsFroWorAtIndexPath の有効化
}

@end