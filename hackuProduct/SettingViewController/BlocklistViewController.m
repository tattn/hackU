//
//  BlocklistViewController.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/27.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "BlocklistViewController.h"
#import "Backend.h"
#import <RMUniversalAlert.h>

@interface BlocklistViewController ()

@property UITableView *tableView;

@property NSMutableArray* blocklist;

@end

@implementation BlocklistViewController

static NSString* BlocklistCellId = @"BlocklistCell";

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
            NSArray* users = res[@"users"];
            [users enumerateObjectsUsingBlock:^(NSDictionary* user, NSUInteger idx, BOOL *stop) {
                [_blocklist addObject:@{@"id":user[@"userId"], @"name":user[@"fullname"]}];
            }];
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

- (void)tappedEditButton:(UIButton*)sender {
    [RMUniversalAlert showActionSheetInViewController:self
                                            withTitle:nil
                                              message:nil
                                    cancelButtonTitle:@"キャンセル"
                               destructiveButtonTitle:@"削除"
                                    otherButtonTitles:@[@"ブロック解除"]
                   popoverPresentationControllerBlock:^(RMPopoverPresentationController *popover){
                       popover.sourceView = self.view;
                       popover.sourceRect = sender.frame;
                   }
                                             tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
                                                 if (buttonIndex == alert.cancelButtonIndex) {
                                                     NSLog(@"Cancel Tapped");
                                                 } else if (buttonIndex == alert.destructiveButtonIndex) {
                                                     [self deleteBlockUser:sender.tag];
                                                 } else if (buttonIndex == alert.firstOtherButtonIndex) {
                                                     [self unblockUser:sender.tag];
                                                 }
                                             }];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _blocklist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BlocklistCell* cell = [tableView dequeueReusableCellWithIdentifier:BlocklistCellId forIndexPath:indexPath];
    
    NSDictionary* user = _blocklist[indexPath.row];
    cell.nameLabel.text = user[@"name"];
    [cell.editButton addTarget:self action:@selector(tappedEditButton:) forControlEvents:UIControlEventTouchUpInside];
    cell.editButton.tag = indexPath.row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

@end

@implementation BlocklistCell
@end

