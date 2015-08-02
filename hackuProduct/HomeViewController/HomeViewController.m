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
#import "SNS.h"
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
@property NSMutableArray* replies;

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
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    _mode = sender.selectedSegmentIndex;
    
    //TODO: バックエンドとの接続
    if (_mode == kModeTimeline) {
        [_tableView reloadData];
    }
    else if (_mode == kModeNotification) {
        [self getBookRequests];
    }
}

- (void)getBookRequests {
    [Backend.shared getRequest:User.shared.userId option:@{} callback:^(id responseObject, NSError *error) {
        _requests = [NSMutableArray array];
        NSArray* reqs = responseObject[@"requests"];
        [reqs enumerateObjectsUsingBlock:^(id req, NSUInteger idx, BOOL *stop) {
            NSNumber* accepted = req[@"accepted"];
            if (accepted == (id)[NSNull null]) {
                [_requests addObject:req];
            }
        }];
        [Backend.shared getRequestIsent:@{} callback:^(id reqIsent, NSError *error) {
            _replies = [NSMutableArray array];
            NSArray* reqs = reqIsent[@"requests"];
            [reqs enumerateObjectsUsingBlock:^(id req, NSUInteger idx, BOOL *stop) {
                NSNumber* accepted = req[@"accepted"];
                if (accepted != (id)[NSNull null]) {
                    [_replies addObject:req];
                }
            }];
            [_tableView reloadData];
        }];
    }];
}


#pragma mark - tableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_mode == kModeTimeline) {
        return 0;
    }
    else {
        return 2;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_mode == kModeTimeline) {
        return @"";
    }
    else {
        if (section == 0) {
            return @"Request";
        }
        else {
            return @"Reply";
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_mode == kModeTimeline) {
        return 0;
    }
    else {
        if (section == 0) {
            return _requests.count;
        }
        else {
            return _replies.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_mode == kModeTimeline) {
        
    }
    else {
        NotificationCell* cell = [tableView dequeueReusableCellWithIdentifier:NotificationCellID forIndexPath:indexPath];
        
        if (indexPath.section == 0) {
            NSDictionary* req = _requests[indexPath.row];
            NSDictionary* user = req[@"sender"];
            cell.msgLabel.text = [NSString stringWithFormat:@"%@から本のリクエストが届いています。", user[@"fullname"]];
        }
        else {
            NSDictionary* req = _replies[indexPath.row];
            NSDictionary* book = req[@"book"];
            NSDictionary* user = req[@"receiver"];
            NSNumber* accepted = req[@"accepted"];
            
            if ([accepted  isEqual: @YES]) {
                cell.msgLabel.text = [NSString stringWithFormat:@"%@が%@のリクエストを許可しました。", user[@"fullname"], book[@"title"]];
            }
            else {
                cell.msgLabel.text = [NSString stringWithFormat:@"%@が%@のリクエストを拒否しました。", user[@"fullname"], book[@"title"]];
            }
        }
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_mode == kModeNotification) {
        if (indexPath.section == 0) {
            NSDictionary* req = _requests[indexPath.row];
            NSDictionary* user = req[@"sender"];
            NSDictionary* book = req[@"book"];
            [BookDetailViewController showForAcceptingBook:self book:book sender:user];
        }
        else {
            NSDictionary* req = _replies[indexPath.row];
            NSDictionary* book = req[@"book"];
            NSNumber* accepted = req[@"accepted"];
            if ([accepted isEqual: @YES]) {
                [SNS postToLine:@""];
            }
            else {
                int bookId = ((NSNumber*)book[@"bookId"]).intValue;
                [Backend.shared deleteRequest:User.shared.userId bookId:bookId option:@{} callback:^(id responseObject, NSError *error) {
                    [_tableView reloadData];
                }];
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
