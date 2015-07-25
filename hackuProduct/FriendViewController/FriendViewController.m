
#import "FriendViewController.h"
#import "FriendTableViewCell.h"
#import "FriendBookShelfCollectionViewController.h"
#import "FriendBookShelfCell.h"
#import "AddFriendViewController.h"
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
        cell.alpha = 0.5f;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FriendBookShelfCollectionViewController *friendBookShelfCollectionVC = [[FriendBookShelfCollectionViewController alloc] init];
    
    [self.navigationController pushViewController:friendBookShelfCollectionVC animated:YES];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* friend = _friends[indexPath.row];
    if ([(NSNumber*)friend[@"new"] isEqual: @YES]) {
        // 拒否ボタン
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"拒否"
                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    NSDictionary* friend = _friends[indexPath.row];
                    [self rejectNewFriendById:((NSNumber*)friend[@"id"]).intValue];
        }];
        
        // 許可ボタン
        UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"許可"
                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    NSDictionary* friend = _friends[indexPath.row];
                    [self allowNewFriendById:((NSNumber*)friend[@"id"]).intValue];
        }];
        return @[deleteAction, editAction];
    }
    return @[];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // editActionsFroWorAtIndexPath の有効化
}

@end
