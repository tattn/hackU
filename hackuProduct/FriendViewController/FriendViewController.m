
#import "FriendViewController.h"
#import "FriendTableViewCell.h"
#import "FriendBookShelfCollectionViewController.h"
#import "FriendProfileViewController.h"
#import "AddFriendViewController.h"
#import "AlertHelper.h"
#import "Backend.h"
#import "User.h"
#import "UIImageViewHelper.h"
#import <REMenu/REMenu.h>

@interface FriendViewController ()

@property NSMutableArray* friends;
@property NSMutableArray* is_new;
@property int userId;

@property (strong, readwrite, nonatomic) REMenu *menu;

typedef NS_ENUM (int, SortType) {
    kSortTypeNameAsc,
    kSortTypeNumDesc,
    kSortTypeNumAsc,
};

@property SortType sortType;

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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[[UIImage imageNamed:@"SortIcon"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(didTapSort:)];
    
    REMenuItem *sortNameAsc = [[REMenuItem alloc] initWithTitle:@"名前順"
                                                      image:nil
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {
                                                         [self sort:kSortTypeNameAsc];
                                                     }];
    
    REMenuItem *sortNumDesc = [[REMenuItem alloc] initWithTitle:@"本の多い順"
                                                      image:nil
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {
                                                         [self sort:kSortTypeNumDesc];
                                                     }];
    
    REMenuItem *sortNumAsc = [[REMenuItem alloc] initWithTitle:@"本の少ない順"
                                                      image:nil
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {
                                                         [self sort:kSortTypeNumAsc];
                                                     }];
    
//https://github.com/romaonthego/REMenu/blob/master/REMenuExample/REMenuExample/Classes/Controllers/NavigationViewController.m
    self.menu = [[REMenu alloc] initWithItems:@[sortNameAsc, sortNumDesc, sortNumAsc]];
    self.menu.cornerRadius = 4;
    self.menu.shadowRadius = 4;
    self.menu.shadowColor = [UIColor blackColor];
    self.menu.shadowOffset = CGSizeMake(0, 1);
    self.menu.shadowOpacity = 1;
    self.menu.separatorOffset = CGSizeMake(15.0, 0.0);
    self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15.0f];
    self.menu.textColor = [UIColor whiteColor];
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
    
    _sortType = kSortTypeNameAsc;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //TODO: 表示するたびにデータベースに問い合わせをするのは良くないかも、必要なときだけ更新するように変更する
//    if (_userId != User.shared.userId) {
        _userId = My.shared.user->userId;
        [self getAllFriends];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didTapSort:(id)selector {
    if ([self.menu isOpen]) [self.menu close];
    [self.menu showFromNavigationController:self.navigationController];
}

- (void)sort:(SortType)sortType {
    _sortType = sortType;
    switch (sortType) {
        case kSortTypeNameAsc:  [self sortByNumAsc]; break;
        case kSortTypeNumDesc: [self sortByNumDesc]; break;
        case kSortTypeNumAsc: [self sortByNumAsc]; break;
    }
    [self.tableView reloadData];
}

- (void)sortByNameAsc {
    NSArray* friends = [_friends sortedArrayUsingSelector:@selector(compareName:)];
    _friends = [friends mutableCopy];
}

- (void)sortByNumDesc {
    NSArray* friends = [_friends sortedArrayUsingSelector:@selector(compareBookNumInv:)];
    _friends = [friends mutableCopy];
}

- (void)sortByNumAsc {
    NSArray* friends = [_friends sortedArrayUsingSelector:@selector(compareBookNum:)];
    _friends = [friends mutableCopy];
}

- (void)getAllFriends {
    _friends = [NSMutableArray array];
    _is_new = [NSMutableArray array];
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
    [users enumerateObjectsUsingBlock:^(NSDictionary *responseObject, NSUInteger idx, BOOL *stop) {
        User* user = [User initWithDic:responseObject];
        [_is_new addObject:new];
        [_friends addObject:user];
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
    [_is_new enumerateObjectsUsingBlock:^(NSNumber* is_new, NSUInteger idx, BOOL *stop) {
        if ([is_new isEqual: @YES]) {
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
    
    User* friend = _friends[indexPath.row];
    cell.firendNameLabel.text = friend->fullname;
    cell.friendCommentLabel.text = friend->comment;
    cell.friendBookNumLabel.text = [NSNumber numberWithInt:friend->bookNum].stringValue;
    [cell.friendImage my_setImageWithURL:PROFILE_IMAGE_URL(friend->userId) defaultImage:[UIImage imageNamed:@"ProfileImageDefault"]];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFriendIcon:)];
    [cell.friendImage addGestureRecognizer:tapGesture];
    
    if ([_is_new[indexPath.row] isEqual: @YES]) {
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
    
    User* friend = _friends[indexPath.row];
    if ([_is_new[indexPath.row] isEqual: @NO]) {
        FriendBookShelfCollectionViewController *friendBookShelfCollectionVC = [[FriendBookShelfCollectionViewController alloc] init];
        
        NSString *title = [NSString stringWithFormat:@"%@ の本棚", friend->fullname];
        friendBookShelfCollectionVC.title = title;
        friendBookShelfCollectionVC.userId = friend->userId;
        
        [self.navigationController pushViewController:friendBookShelfCollectionVC animated:YES];
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_friends.count <= 0) return @[]; // 非同期処理バグの一時的な対処
    
    if ([_is_new[indexPath.row] isEqual: @YES]) {
        // 拒否ボタン
        UITableViewRowAction *rejectAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"拒否"
                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    User* friend = _friends[indexPath.row];
                    [self rejectNewFriendById:friend->userId];
        }];
        
        // 許可ボタン
        UITableViewRowAction *allowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"許可"
                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    User* friend = _friends[indexPath.row];
                    [self allowNewFriendById:friend->userId];
        }];
        return @[rejectAction, allowAction];
    }
    else {
        // 削除ボタン
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"削除"
                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    User* friend = _friends[indexPath.row];
                    [self deleteFriendById:friend->userId];
        }];
        
        // ブロックボタン
        UITableViewRowAction *blockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"ブロック"
                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    User* friend = _friends[indexPath.row];
                    [self blockFriendById:friend->userId];
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
