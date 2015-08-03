
#import "HomeViewController.h"
#import "Backend.h"
#import "Toast.h"
#import "User.h"
#import "SNS.h"
#import "BookDetailViewController.h"
#import "TimelineCell.h"
#import "UIImageViewHelper.h"

@implementation NotificationCell
@end

@interface HomeViewController ()

typedef NS_ENUM (NSUInteger, kMode) {
    kModeTimeline,
    kModeNotification,
};

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property kMode mode;

@property NSArray* timelines;
@property NSMutableArray* requests;
@property NSMutableArray* replies;

@end

@implementation HomeViewController

static NSString* NotificationCellID = @"NotificationCell";
static NSString* TimelineCellID = @"TimelineCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mode = kModeTimeline;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    self.navigationItem.title = @"Bookee";
    
    UINib *nib = [UINib nibWithNibName:@"HomeViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:NotificationCellID];
    UINib *nib2 = [UINib nibWithNibName:@"TimelineCell" bundle:nil];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:TimelineCellID];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getTimeline];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    _mode = sender.selectedSegmentIndex;
    
    //TODO: バックエンドとの接続
    if (_mode == kModeTimeline) {
        [self getTimeline];
    }
    else if (_mode == kModeNotification) {
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
        return 1;
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
            return @"本のリクエスト";
        }
        else {
            return @"友達からの返答";
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_mode == kModeTimeline) {
        return _timelines.count;
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
            [cell.friendImage my_setImageWithURL:PROFILE_IMAGE_URL2(bookshelf[@"user_id"])];
            cell.friendNameLabel.text = [NSString stringWithFormat:@"%@ %@", user[@"lastname"], user[@"firstname"]];
            [cell.friendBookImage my_setImageWithURL:book[@"cover_image_url"]];
            cell.addBookInfoLabel.text = [NSString stringWithFormat:@"本棚に「%@」を追加しました", book[@"title"]];
            NSDateFormatter* dateFormatter = [NSDateFormatter new];
            // 2015-08-03T06:35:49.589Z
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
            if (_requests.count <= 0) return cell; // 非同期処理関係のバグ対策
            NSDictionary* req = _requests[indexPath.row];
            NSDictionary* user = req[@"sender"];
            cell.msgLabel.text = [NSString stringWithFormat:@"%@さんから本のリクエストが届いています。", user[@"fullname"]];
        }
        else {
            if (_replies.count <= 0) return cell; // 非同期処理関係のバグ対策
            NSDictionary* req = _replies[indexPath.row];
            NSDictionary* book = req[@"book"];
            NSDictionary* user = req[@"receiver"];
            NSNumber* accepted = req[@"accepted"];
            
            if ([accepted  isEqual: @YES]) {
                cell.msgLabel.text = [NSString stringWithFormat:@"%@さんが%@のリクエストを許可しました。", user[@"fullname"], book[@"title"]];
            }
            else {
                cell.msgLabel.text = [NSString stringWithFormat:@"%@さんが%@のリクエストを拒否しました。", user[@"fullname"], book[@"title"]];
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
    
    if (_mode == kModeNotification) {
        if (indexPath.section == 0) {
            if (_requests.count <= 0) return; //非同期処理関係のバグ対策
            NSDictionary* req = _requests[indexPath.row];
            NSDictionary* user = req[@"sender"];
            NSDictionary* book = req[@"book"];
            [BookDetailViewController showForAcceptingBook:self book:book sender:user];
        }
        else {
            if (_replies.count <= 0) return; //非同期処理関係のバグ対策
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
