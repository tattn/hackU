//
//  HomeViewController.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/26.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "HomeViewController.h"
#import "Backend.h"
#import "User.h"

@implementation NotificationCell
@end

@interface HomeViewController ()

typedef NS_ENUM (NSUInteger, kMode) {
    kModeTimeline,
    kModeNotification,
};

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property kMode mode;

@property NSArray* requests;

@end

@implementation HomeViewController

static NSString* NotificationCellID = @"NotificationCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mode = kModeTimeline;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    self.navigationController.navigationBarHidden = YES;
    
    UINib *nib = [UINib nibWithNibName:@"HomeViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:NotificationCellID];
//    [self.tableView registerClass:[NotificationCell class] forCellReuseIdentifier:NotificationCellID];
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
        _requests = responseObject[@"requests"];
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
    
}

@end
