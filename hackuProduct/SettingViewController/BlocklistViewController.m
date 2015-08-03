//
//  BlocklistViewController.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/27.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "BlocklistViewController.h"
#import "Backend.h"
#import "FriendTableViewCell.h"
#import <RMUniversalAlert.h>

@interface BlocklistViewController ()

@property UITableView *tableView;

@property NSArray* blocklist;

@end

@implementation BlocklistViewController

static NSString* BlocklistCellId = @"FriendTableViewCell";

- (void)viewDidLoad {
    self.title = @"ブロックリスト";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UINib *nib = [UINib nibWithNibName:BlocklistCellId bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:BlocklistCellId];
    
    [self getBlocklist];
}

- (void)getBlocklist {
    _blocklist = [NSMutableArray array];
    [Backend.shared getBlacklist: @{} callback:^(NSDictionary* res, NSError *error) {
        if (error) {
        }
        else {
            _blocklist = res[@"users"];
            [_tableView reloadData];
        }
    }];
}

- (void)deleteBlockUser:(long)userId {
    [self unblockUser:userId];
    [Backend.shared deleteFriend:userId option:@{} callback:^(id responseObject, NSError *error) {
    }];
}

- (void)unblockUser:(long)userId {
    [Backend.shared deleteBlacklist:userId option:@{} callback:^(id responseObject, NSError *error) {
        [_tableView reloadData];
    }];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _blocklist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:BlocklistCellId forIndexPath:indexPath];
    if (_blocklist.count <= 0) return cell; // 非同期処理関係のバグの対処
    
    NSDictionary* user = _blocklist[indexPath.row];
    cell.firendNameLabel.text = user[@"fullname"];
    cell.friendCommentLabel.text = user[@"comment"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_blocklist.count <= 0) return; // 非同期処理関係のバグの対処
    
    NSDictionary* user = _blocklist[indexPath.row];
    int userId = ((NSNumber*)user[@"userId"]).intValue;
    
    [RMUniversalAlert showActionSheetInViewController:self
                                            withTitle:nil
                                              message:nil
                                    cancelButtonTitle:@"キャンセル"
                               destructiveButtonTitle:@"削除"
                                    otherButtonTitles:@[@"ブロック解除"]
                   popoverPresentationControllerBlock:^(RMPopoverPresentationController *popover){
                       popover.sourceView = self.view;
                       popover.sourceRect = self.view.frame;
                   }
                                             tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
                                                 if (buttonIndex == alert.cancelButtonIndex) {
                                                 } else if (buttonIndex == alert.destructiveButtonIndex) {
                                                     [self deleteBlockUser:userId];
                                                 } else if (buttonIndex == alert.firstOtherButtonIndex) {
                                                     [self unblockUser:userId];
                                                 }
                                             }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

@end
