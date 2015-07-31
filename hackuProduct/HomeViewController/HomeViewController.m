//
//  HomeViewController.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/26.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "HomeViewController.h"
#import "Backend.h"
#import "Toast.h"
#import "User.h"
#import "BookDetailViewController.h"

@implementation NotificationCell
@end

@interface HomeViewController ()

typedef NS_ENUM (NSUInteger, kMode) {
    kModeTimeline,
    kModeNotification,
};

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property kMode mode;

@property NSMutableArray* requests;

@end

@implementation HomeViewController

static NSString* NotificationCellID = @"NotificationCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mode = kModeTimeline;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    UINib *nib = [UINib nibWithNibName:@"HomeViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:NotificationCellID];
//    [self.tableView registerClass:[NotificationCell class] forCellReuseIdentifier:NotificationCellID];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    [super viewDidAppear:animated];
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    _mode = sender.selectedSegmentIndex;
    
    //TODO: バックエンドとの接続
    if (_mode == kModeNotification) {
        [self getBookRequests];
    }
}

- (void)getBookRequests {
    [Backend.shared getRequest:User.shared.userId option:@{} callback:^(id responseObject, NSError *error) {
        _requests = [NSMutableArray array];
        NSArray* requests = responseObject[@"requests"];
        [requests enumerateObjectsUsingBlock:^(NSDictionary* req, NSUInteger idx, BOOL *stop) {
            NSNumber* accepted = req[@"accepted"];
            if (accepted == (id)[NSNull null]) {
                [_requests addObject:req];
            }
        }];
        [_tableView reloadData];
    }];
}


#pragma mark - tableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_mode == kModeTimeline) {
        return 0;
    }
    else {
        return _requests.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCell* cell = [tableView dequeueReusableCellWithIdentifier:NotificationCellID forIndexPath:indexPath];
    
    NSDictionary* req = _requests[indexPath.row];
    NSDictionary* user = req[@"sender"];
//    NSDictionary* book = req[@"book"];
    
    cell.msgLabel.text = [NSString stringWithFormat:@"%@から本のリクエストが届いています。", user[@"fullname"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* req = _requests[indexPath.row];
    NSDictionary* user = req[@"sender"];
    NSDictionary* book = req[@"book"];
    
    if (_mode == kModeNotification) {
        [BookDetailViewController showForAcceptingBook:self book:book sender:user];
    }
}

@end
