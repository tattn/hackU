//
//  SearchResultViewController.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/28.
//  Copyright © 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "SearchResultViewController.h"
#import "Backend.h"
#import "BookDetailViewController.h"
#import "UIImageViewHelper.h"

@implementation SearchResultCell
@end

@interface SearchResultViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray* books;

@end

@implementation SearchResultViewController

static NSString* SearchResultCellId = @"SearchResultCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"検索結果";
    _searchBar.text = _searchQuery;
    _searchBar.placeholder = @"タイトル, 著者, ISBN...";
    _searchBar.keyboardType = UIKeyboardTypeDefault;
    _searchBar.delegate = self;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    UINib *nib = [UINib nibWithNibName:SearchResultCellId bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:SearchResultCellId];
    
    [self searchBook: _searchQuery];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)searchBook:(NSString*)query {
    if ([[query stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
        return;
    }
    
    [Backend.shared searchBook:@{@"title":query, @"amazon":@""} callback:^(id res, NSError *error) {
        if (error) {
            NSLog(@"Error - searchBook: %@", error);
        }
        else {
            _books = res[@"books"];
            [_tableView reloadData];
        }
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    [self searchBook: _searchBar.text];
}

+ (void)show:(SearchViewController*)parent query:(NSString*)query {
    SearchResultViewController *vc = [SearchResultViewController new];
    vc.searchQuery = query;
    vc.searchVC = parent;
    [parent.navigationController pushViewController:vc animated: true];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _books.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell* cell = [tableView dequeueReusableCellWithIdentifier:SearchResultCellId];
    
    NSDictionary* book = _books[indexPath.row];
    cell.titleLabel.text = book[@"title"];
    
    [cell.bookImage my_setImageWithURL:book[@"coverImageUrl"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 127;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (_searchVC.mode) {
        case kModeNormal:
            break;
            
        case kModeAddingBookToBookshelf:
            [BookDetailViewController showForAddingBookToBookshelf:self book:_books[indexPath.row]];
            break;
            
        default:
            break;
    }
}


@end
