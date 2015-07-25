
#import "FriendViewController.h"
#import "FriendTableViewCell.h"
#import "FriendBookShelfCollectionViewController.h"
#import "FriendBookShelfCell.h"
#import "Backend.h"

@interface FriendViewController ()

@property NSMutableArray* friends;

@end

@implementation FriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    UINib *nib = [UINib nibWithNibName:@"FriendTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"FriendTableViewCell"];
    
    _friends = [NSMutableArray array];
    Backend *backend = Backend.shared;
    [backend getFriend:1 option:@{} callback:^(NSDictionary* res, NSError *error) {
        NSArray* users = res[@"users"];
        [users enumerateObjectsUsingBlock:^(NSDictionary *user, NSUInteger idx, BOOL *stop) {
            NSString *fullname = [NSString stringWithFormat:@"%@ %@", user[@"lastname"], user[@"firstname"]];
            [_friends addObject:fullname];
        }];
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    
    cell.firendNameLabel.text = _friends[indexPath.row];
    
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

@end
