
#import "HomeViewController.h"
#import "Backend.h"
#import "Toast.h"
#import "User.h"
#import "SNS.h"
#import "BookDetailViewController.h"
#import "TimelineCell.h"
#import "UIImageViewHelper.h"
#import "AlertHelper.h"
#import "Book.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation NotificationCell
@end

@interface HomeViewController ()

typedef NS_ENUM (NSUInteger, kMode) {
    kModeTimeline,
    kModeNotification,
};

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property kMode mode;

@property NSArray* timelines;
@property NSMutableArray* requests;
@property NSMutableArray* replies;
@property NSMutableArray* statuses;

@end

@implementation HomeViewController

static NSString* NotificationCellID = @"NotificationCell";
static NSString* TimelineCellID = @"TimelineCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mode = kModeTimeline;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new]; // 余分なCellのセパレータを表示しないための処理
    
    self.navigationItem.title = @"Bookee";
    
    UINib *nib = [UINib nibWithNibName:@"HomeViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:NotificationCellID];
    UINib *nib2 = [UINib nibWithNibName:@"TimelineCell" bundle:nil];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:TimelineCellID];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self segmentChanged:kModeTimeline];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    [self changeMode:sender.selectedSegmentIndex];
}

- (void)changeMode:(kMode)mode {
    _mode =mode;
    _segmentedControl.selectedSegmentIndex = mode;
    if (mode == kModeTimeline) {
        [self getTimeline];
    }
    else if (mode == kModeNotification) {
        [self getBookRequests];
    }
}

- (void)getTimeline {
    [Backend.shared getTimeline:@{} callback:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"getTimeline: %@", error);
        }
        else {
            _timelines = responseObject[@"timelines"];
            [_tableView reloadData];
        }
    }];
}

- (void)getBookRequests {
    [Backend.shared getRequest:My.shared.user->userId option:@{} callback:^(id responseObject, NSError *error) {
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
            [self getBookStatuses];
        }];
    }];
}

- (void)getBookStatuses {
    [SVProgressHUD showWithStatus:@"通知取得中"];
    [Backend.shared getLending:@{} callback:^(id responseObject, NSError *error) {
        _statuses = [NSMutableArray array];
        NSArray* lendings = responseObject[@"lendings"];
        [lendings enumerateObjectsUsingBlock:^(id lending, NSUInteger idx, BOOL *stop) {
            [_statuses addObject:@{@"lending":lending}];
        }];
        
        [Backend.shared getBorrow:@{} callback:^(id responseObject, NSError *error) {
            NSArray* borrows = responseObject[@"borrows"];
            [borrows enumerateObjectsUsingBlock:^(id borrow, NSUInteger idx, BOOL *stop) {
                [_statuses addObject:@{@"borrow":borrow}];
            }];
            
            [Backend.shared getRequestIsent:@{} callback:^(id responseObject, NSError *error) {
                NSArray* reqs = responseObject[@"requests"];
                [reqs enumerateObjectsUsingBlock:^(id req, NSUInteger idx, BOOL *stop) {
                    if (!req[@"accepted"]) {
                        [_statuses addObject:@{@"request":req}];
                    }
                }];
                [_tableView reloadData];
            }];
            
        }];
    }];
}

- (void)showBadge {
    unsigned long num =  _requests.count + _replies.count;
    if (num > 0) {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu", num];
    }
    else {
        self.navigationController.tabBarItem.badgeValue = nil; // nilにすると消える
    }
}

#pragma mark - tableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [self showBadge]; //FIXME: この場所がベストではない
    if (_mode == kModeTimeline) {
        return 1;
    }
    else {
        return 3;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_mode == kModeTimeline) {
        return @"";
    }
    else {
        if (section == 0) {
            return @"本のリクエスト";
        }
        else if (section == 1){
            return @"友達からの返答";
        }
        else {
            return @"ステータス";
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_mode == kModeTimeline) {
        return _timelines.count;
    }
    else {
        if (section == 0) {
            if (_requests.count <= 0) return 1; // 〜はありません用
            return _requests.count;
        }
        else if (section == 1){
            if (_replies.count <= 0) return 1; // 〜はありません用
            return _replies.count;
        }
        else {
            if (_statuses.count <= 0) return 1; // 〜はありません用
            return _statuses.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_mode == kModeTimeline) {
        TimelineCell *cell = [tableView dequeueReusableCellWithIdentifier:TimelineCellID forIndexPath:indexPath];
        cell.layer.borderColor = [UIColor colorWithRed:0.22 green:0.80 blue:0.49 alpha:1.0].CGColor;
        cell.layer.borderWidth = 2;
        if (_timelines.count <= 0) return cell; // 非同期処理関係のバグ対策
        //FIXME: 無理やり実装. バックエンドともにリファクタリングしたい
        NSDictionary *timeline = _timelines[indexPath.row];
        NSString *type = timeline[@"type"];
        if ([type isEqualToString: @"bookshelf"]) {
            NSDictionary* bookshelf = timeline[@"data"][@"bookshelf"];
            NSDictionary* book = bookshelf[@"book"];
            NSDictionary* user = bookshelf[@"user"];
            [cell.friendImage my_setImageWithURL:PROFILE_IMAGE_URL2(bookshelf[@"user_id"]) defaultImage:[UIImage imageNamed:@"ProfileImageDefault"]];
            cell.friendNameLabel.text = [NSString stringWithFormat:@"%@ %@", user[@"lastname"], user[@"firstname"]];
            [cell.friendBookImage my_setImageWithURL:book[@"cover_image_url"]];
            cell.addBookInfoLabel.text = [NSString stringWithFormat:@"本棚に「%@」を追加しました", book[@"title"]];
            NSDateFormatter* dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSZZ"];
            NSDate *timestamps = [dateFormatter dateFromString:timeline[@"timestamps"]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            cell.addDateTimeLabel.text = [dateFormatter stringFromDate:timestamps];
        }
        return cell;
    }
    else {
        NotificationCell* cell = [tableView dequeueReusableCellWithIdentifier:NotificationCellID forIndexPath:indexPath];
        
        if (indexPath.section == 0) {
            if (_requests.count <= 0) {
                cell.msgLabel.text = @"リクエストはありません。";
                return cell; // 非同期処理関係のバグ対策
            }
            NSDictionary* req = _requests[indexPath.row];
            NSDictionary* user = req[@"sender"];
            cell.msgLabel.text = [NSString stringWithFormat:@"%@さんから本のリクエストが届いています。", user[@"fullname"]];
        }
        else if (indexPath.section == 1){
            if (_replies.count <= 0) {
                cell.msgLabel.text = @"返信はありません。";
                return cell; // 非同期処理関係のバグ対策
            }
            NSDictionary* req = _replies[indexPath.row];
            NSDictionary* book = req[@"book"];
            NSDictionary* user = req[@"receiver"];
            NSNumber* accepted = req[@"accepted"];
            
            if ([accepted  isEqual: @YES]) {
                cell.msgLabel.text = [NSString stringWithFormat:@"%@さんが「%@」のリクエストを許可しました。", user[@"fullname"], book[@"title"]];
            }
            else {
                cell.msgLabel.text = [NSString stringWithFormat:@"%@さんが「%@」のリクエストを拒否しました。", user[@"fullname"], book[@"title"]];
            }
        }
        else {
            if (_statuses.count <= 0) {
                cell.msgLabel.text = @"ステータスはありません。";
                return cell; // 非同期処理関係のバグ対策
            }
            NSDictionary* status = _statuses[indexPath.row];
            if ([[status allKeys] containsObject:@"lending"]) {
                NSDictionary* lending = status[@"lending"];
                NSDictionary* user = lending[@"borrower"];
                NSDictionary* book = lending[@"book"];
                cell.msgLabel.text = [NSString stringWithFormat:@"%@さんに「%@」を貸しています。", user[@"fullname"], book[@"title"]];
            }
            else if ([[status allKeys] containsObject:@"borrow"]) {
                NSDictionary* borrow = status[@"borrow"];
                NSDictionary* user = borrow[@"lender"];
                NSDictionary* book = borrow[@"book"];
                cell.msgLabel.text = [NSString stringWithFormat:@"%@さんから「%@」を借りています", user[@"fullname"], book[@"title"]];
            }
            else {
                NSDictionary* borrow = status[@"request"];
                NSDictionary* user = borrow[@"receiver"];
                NSDictionary* book = borrow[@"book"];
                cell.msgLabel.text = [NSString stringWithFormat:@"%@さんへ「%@」をリクエストしています", user[@"fullname"], book[@"title"]];
            }
        }
        
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_mode == kModeTimeline){
        return 210;
    }else{
        return 60;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_mode == kModeTimeline) {
        // バックエンド側の調整が必要
        NSDictionary *timeline = _timelines[indexPath.row];
        NSString *type = timeline[@"type"];
        if ([type isEqualToString: @"bookshelf"]) {
//            NSDictionary* bookshelf = timeline[@"data"][@"bookshelf"];
            Bookshelf* bookshelf = [Bookshelf initWithDic2: timeline[@"data"][@"bookshelf"]];
            [BookDetailViewController showForRequestingBook:self bookshelf:bookshelf];
        }
    }
    else if (_mode == kModeNotification) {
        if (indexPath.section == 0) {
            if (_requests.count <= 0) return; //非同期処理関係のバグ対策
            NSDictionary* req = _requests[indexPath.row];
            NSDictionary* user = req[@"sender"];
            Book* book = [Book initWithDic:req[@"book"]];
            [BookDetailViewController showForAcceptingBook:self book:book sender:user];
        }
        else if (indexPath.section == 1) {
            if (_replies.count <= 0) return; //非同期処理関係のバグ対策
            NSDictionary* req = _replies[indexPath.row];
            NSDictionary* book = req[@"book"];
            NSNumber* accepted = req[@"accepted"];
            int bookId = ((NSNumber*)book[@"bookId"]).intValue;
            if ([accepted isEqual: @YES]) {
                [Backend.shared deleteRequestIsent:bookId option:@{} callback:^(id responseObject, NSError *error) {
                    if (error) {
                        NSLog(@"deleteRequestIsent: %@", error);
                    }
                    else {
                        [AlertHelper showYesNo:self title:@"確認" msg:@"LINEに移動します。よろしいですか？" yesTitle:@"はい" yes:^{
                            [SNS postToLine:@""];
                        }];
                        [self getBookRequests];
                    }
                }];
            }
            else {
                [Backend.shared deleteRequestIsent:bookId option:@{} callback:^(id responseObject, NSError *error) {
                    if (error) {
                        NSLog(@"deleteRequestIsent: %@", error);
                    }
                    [self getBookRequests];
                }];
            }
        }
        else {
            if (_statuses.count <= 0) return; //非同期処理関係のバグ対策
            
            NSDictionary* status = _statuses[indexPath.row];
            if ([[status allKeys] containsObject:@"lending"]) {
                NSDictionary* lending = status[@"lending"];
                NSDictionary* book = lending[@"book"];
                int bookId = ((NSNumber*)book[@"bookId"]).intValue;
                // 貸している
                [AlertHelper showYesNo:self title:@"確認" msg:@"この本は返却されましたか？" yesTitle:@"はい" noTitle:@"いいえ" yes:^{
                    [Backend.shared deleteLending:bookId option:@{} callback:^(id responseObject, NSError *error) {
                        if (error) {
                            NSLog(@"Error - deleteLending: %@", error);
                        }
                        [self getBookRequests];
                    }];
                }];
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
