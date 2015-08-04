//
//  Backend.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/18.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Backend.h"
#import "AFNetworking.h"
#import "User.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface Backend ()
@property NSString* accessToken;
@end

@implementation Backend : AFHTTPSessionManager

static Backend* instance = nil;

+ (Backend*)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *url = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"BACKEND_URL"];
        instance = [[Backend manager] initWithBaseURL:[[NSURL alloc] initWithString:url]];
    });
    return instance;
}

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (id)copyWithZone:(NSZone*)zone {
    return self;
}

- (instancetype)init {
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    [self.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    //    [self.requestSerializer setValue:@"hogehoge" forHTTPHeaderField:@"User-Agent"];
    return self;
}

#define DEFAULT_CALLBACK \
success:^(NSURLSessionDataTask *task, id responseObject) {\
    [SVProgressHUD dismiss];\
    callback(responseObject, nil);\
}\
failure:^(NSURLSessionDataTask *task, NSError *error) {\
    [SVProgressHUD dismiss];\
    callback(nil, error);\
}

#define TRIGGER_CALLBACK(stmt) \
success:^(NSURLSessionDataTask *task, id responseObject) {\
    [SVProgressHUD dismiss];\
    stmt;\
    callback(responseObject, nil);\
}\
failure:^(NSURLSessionDataTask *task, NSError *error) {\
    [SVProgressHUD dismiss];\
    callback(nil, error);\
}

#define MULTIPART_CALLBACK(stmt) \
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) { \
    stmt;\
} success:^(NSURLSessionDataTask *task, id responseObject) {\
    callback(responseObject, nil);\
} failure:^(NSURLSessionDataTask *task, NSError *error) {\
    callback(nil, error);\
}

// URL builders
#define MAKE_URL(fmt, ...) [NSString stringWithFormat:(fmt), __VA_ARGS__]
#define USER_URL @"users"
#define USERID_URL(userId) MAKE_URL(USER_URL "/%d", (userId))
#define ICON_URL(userId) MAKE_URL(USER_URL "/%d/icon", (userId))
#define AUTH_URL @"auth"
#define AUTH_LOGIN_URL (AUTH_URL "/login")
#define AUTH_LOGOUT_URL (AUTH_URL "/logout")
#define BOOK_URL @"books"
#define BOOKID_URL(bookId) MAKE_URL(BOOK_URL "/%d", (bookId))
#define BOOKSHELF_URL @"bookshelves"
#define BOOKSHELFID_URL(userId) MAKE_URL(BOOKSHELF_URL "/%d", (userId))
#define BOOKSHELF_SEARCH_URL(userId) MAKE_URL(BOOKSHELF_URL "/%d/search", (userId))
#define BOOKSHELFIDID_URL(userId, bookId) MAKE_URL(BOOKSHELF_URL "/%d/%d", (userId), (bookId))
#define BORROW_URL @"my/borrow"
#define BORROWID_URL(bookId) MAKE_URL(BORROW_URL "/%d", (bookId))
#define LEND_URL @"my/lend"
#define LENDID_URL(bookId) MAKE_URL(LEND_URL "/%d", (bookId))
#define BLACKLIST_URL @"my/blacklist"
#define BLACKLISTID_URL(userId) MAKE_URL(BLACKLIST_URL "/%ld", (userId))
#define REQUEST_URL(userId) MAKE_URL(USER_URL "/%d/request", (userId))
#define REQUESTID_URL(userId, bookId) MAKE_URL(USER_URL "/%d/request/%d", (userId), (bookId))
#define FRIEND_URL(userId) MAKE_URL(USER_URL "/%d/friend", (userId))
#define FRIENDID_URL(userId, friendId) MAKE_URL(USER_URL "/%d/friend/%ld", (userId), (friendId))
#define FRIEND_NEW_URL(userId) MAKE_URL(USER_URL "/%d/friend/new", (userId))
#define FRIEND_NEWID_URL(userId, friendId) MAKE_URL(USER_URL "/%d/friend/new/%d", (userId), (friendId))
#define TIMELINE_URL @"my/timeline"

// Default parameters
#define DEFAULT_PARAM  option:(NSDictionary*)option callback:(CompletionBlock)callback
#define DEFAULT_PARAM2        (NSDictionary*)option callback:(CompletionBlock)callback

// Make parameter
#define MAKE_PARAM(dict) \
NSMutableDictionary *param = [(dict) mutableCopy];\
[param addEntriesFromDictionary:option];

#define MAKE_PARAM_WITH_TOKEN(dict) \
if (![self isLoggedIn]) { NSLog(@"Backend: ログインしていません"); return;} \
MAKE_PARAM(dict);\
[param setObject:self.accessToken forKey:@"token"];

#define MAKE_TOKEN_PARAM() \
if (![self isLoggedIn]) { NSLog(@"Backend: ログインしていません"); return;} \
MAKE_PARAM(@{@"token":self.accessToken})


- (BOOL)isLoggedIn {
    return _accessToken != nil;
}


// === [/users] Users API

- (void)addUser:(NSString*)email password:(NSString*)password firstname:(NSString*)firstname lastname:(NSString*)lastname DEFAULT_PARAM {
    MAKE_PARAM((@{@"email":email, @"password":password, @"firstname":firstname, @"lastname":lastname }));
    [self POST:USER_URL parameters:param DEFAULT_CALLBACK];
}

- (void)getUser:(int)userId DEFAULT_PARAM {
    [self GET:USERID_URL(userId) parameters:option DEFAULT_CALLBACK];
}

- (void)updateUser:(int)userId DEFAULT_PARAM {
    [self PUT:USERID_URL(userId) parameters:option TRIGGER_CALLBACK({
        [User.shared update:option];
    })];
}

- (void)deleteUser:(int)userId DEFAULT_PARAM {
    [self DELETE:USERID_URL(userId) parameters:option DEFAULT_CALLBACK];
}

- (void)getProfileImage:(int)userId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self GET:ICON_URL(userId) parameters:param DEFAULT_CALLBACK];
}

- (void)uploadProfileImage:(int)userId image:(UIImage*)img DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self POST:ICON_URL(userId) parameters:param MULTIPART_CALLBACK(
    NSData* imgData = UIImagePNGRepresentation(img);
    [formData appendPartWithFileData:imgData name:@"upload_file" fileName:@"img.png" mimeType:@"image/png"];
     )];
}

// === [/users] end

// === [/my] My API

- (void)getInvitationCode: DEFAULT_PARAM2 {
    MAKE_TOKEN_PARAM();
    [self GET:@"my/invitation_code" parameters:param DEFAULT_CALLBACK];
}

- (void)searchBookInFriends: DEFAULT_PARAM2 {
    MAKE_TOKEN_PARAM();
    [self GET:@"my/friends/bookshelves/search" parameters:param DEFAULT_CALLBACK];
}

// === [/my] end

// === [/auth] Auth API

- (void)login:(NSString*)email password:(NSString*)password DEFAULT_PARAM {
    MAKE_PARAM((@{@"email":email, @"password":password}));
    [self POST:AUTH_LOGIN_URL parameters:param TRIGGER_CALLBACK({
        _accessToken = responseObject[@"token"];
        NSDictionary* user = responseObject[@"users"];
        [User.shared update:user];
    })];
}

- (void)logout: DEFAULT_PARAM2 {
    MAKE_TOKEN_PARAM();
    [self POST:AUTH_LOGOUT_URL parameters:param TRIGGER_CALLBACK({
        _accessToken = nil;
        [User.shared reset];
    })];
}

// === [/auth] end

// === [/books] Books API

- (void)addBook:(NSString*)title DEFAULT_PARAM {
    MAKE_PARAM(@{@"title":title});
    [self POST:BOOK_URL parameters:param DEFAULT_CALLBACK];
}

- (void)getBook:(int)bookId DEFAULT_PARAM {
    [self GET:BOOKID_URL(bookId) parameters:option DEFAULT_CALLBACK];
}

- (void)updateBook:(int)bookId DEFAULT_PARAM {
    [self PUT:BOOKID_URL(bookId) parameters:option DEFAULT_CALLBACK];
}

- (void)deleteBook:(int)bookId DEFAULT_PARAM {
    [self DELETE:BOOKID_URL(bookId) parameters:option DEFAULT_CALLBACK];
}

- (void)searchBook:DEFAULT_PARAM2 {
    [self GET:BOOK_URL"/search" parameters:option DEFAULT_CALLBACK];
}

// === [/books] end

// === [/bookshelves] Bookshelves API

- (void)getBookshelf:(int)userId DEFAULT_PARAM {
    [SVProgressHUD showWithStatus:@"本棚の読み込み中"];
    [self GET:BOOKSHELFID_URL(userId) parameters:option DEFAULT_CALLBACK];
}

- (void)addBookToBookshelf:(int)userId bookId:(int)bookId DEFAULT_PARAM {
    MAKE_PARAM(@{@"book_id":INT2NS(bookId)});
    [self POST:BOOKSHELFID_URL(userId) parameters:param DEFAULT_CALLBACK];
}

- (void)updateBookshelf:(int)userId DEFAULT_PARAM {
    [self PUT:BOOKSHELFID_URL(userId) parameters:option DEFAULT_CALLBACK];
}

- (void)deleteBookshelf:(int)userId DEFAULT_PARAM {
    [self DELETE:BOOKSHELFID_URL(userId) parameters:option DEFAULT_CALLBACK];
}

- (void)getBookInBookshelf:(int)userId bookId:(int)bookId DEFAULT_PARAM {
    [self GET:BOOKSHELFIDID_URL(userId, bookId) parameters:option DEFAULT_CALLBACK];
}

- (void)updateBookInBookshelf:(int)userId bookId:(int)bookId DEFAULT_PARAM {
    [self PUT:BOOKSHELFIDID_URL(userId, bookId) parameters:option DEFAULT_CALLBACK];
}

- (void)deleteBookInBookshelf:(int)userId bookId:(int)bookId DEFAULT_PARAM {
    [self DELETE:BOOKSHELFIDID_URL(userId, bookId) parameters:option DEFAULT_CALLBACK];
}

- (void)searchBookInBookshelf:(int)userId DEFAULT_PARAM {
    [self GET:BOOKSHELF_SEARCH_URL(userId) parameters:option DEFAULT_CALLBACK];
}

// === [/bookshelves] end

// === [/my/borrow] Borrow API

- (void)getBorrow: DEFAULT_PARAM2 {
    MAKE_TOKEN_PARAM();
    [self GET:BORROW_URL parameters:param DEFAULT_CALLBACK];
}

- (void)addBorrow:(int)bookId lenderId:(int)lenderId DEFAULT_PARAM {
    MAKE_PARAM_WITH_TOKEN((@{@"book_id":INT2NS(bookId), @"lender_id":INT2NS(lenderId)}));
    [self POST:BORROW_URL parameters:param DEFAULT_CALLBACK];
}

- (void)deleteBorrow:(int)bookId DEFAULT_PARAM __attribute__ ((deprecated)){
    MAKE_TOKEN_PARAM();
    [self DELETE:BORROWID_URL(bookId) parameters:param DEFAULT_CALLBACK];
}

// === [/my/borrow] end

// === [/my/lend] Lend API

- (void)getLending: DEFAULT_PARAM2 {
    MAKE_TOKEN_PARAM();
    [self GET:LEND_URL parameters:param DEFAULT_CALLBACK];
}

- (void)deleteLending:(int)bookId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self DELETE:LENDID_URL(bookId) parameters:param DEFAULT_CALLBACK];
}

// === [/my/lend] end

// === [/my/blacklist] Blacklist API

- (void)getBlacklist: DEFAULT_PARAM2 {
    MAKE_TOKEN_PARAM();
    [self GET:BLACKLIST_URL parameters:param DEFAULT_CALLBACK];
}

- (void)addBlacklist:(long)userId DEFAULT_PARAM {
    MAKE_PARAM_WITH_TOKEN((@{@"user_id":LONG2NS(userId)}));
    [self POST:BLACKLIST_URL parameters:param DEFAULT_CALLBACK];
}

- (void)deleteBlacklist:(long)userId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self DELETE:BLACKLISTID_URL(userId) parameters:param DEFAULT_CALLBACK];
}

// === [/my/blacklist] end

// === [/my/request] New Request API

- (void)getRequestIsent: DEFAULT_PARAM2 {
    MAKE_TOKEN_PARAM();
    [self GET:@"my/request/sent" parameters:param DEFAULT_CALLBACK];
}

- (void)deleteRequestIsent:(int)bookId DEFAULT_PARAM {
    MAKE_PARAM_WITH_TOKEN((@{@"book_id":INT2NS(bookId)}));
    [self PUT:@"my/request/sent" parameters:param DEFAULT_CALLBACK];
}

// === [/my/request] end

// === [/users/:user_id/request] Request API

- (void)getRequest:(int)userId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self GET:REQUEST_URL(userId) parameters:param DEFAULT_CALLBACK];
}

- (void)addRequest:(int)userId bookId:(int)bookId DEFAULT_PARAM {
    MAKE_PARAM_WITH_TOKEN((@{@"book_id":INT2NS(bookId)}));
    [self POST:REQUEST_URL(userId) parameters:param DEFAULT_CALLBACK];
}

- (void)replyRequest:(int)userId bookId:(int)bookId accepted:(bool)accepted DEFAULT_PARAM {
    MAKE_PARAM_WITH_TOKEN((@{@"book_id":INT2NS(bookId), @"accepted":BOOL2NS(accepted)}));
    [self PUT:REQUESTID_URL(userId, bookId) parameters:param DEFAULT_CALLBACK];
}

- (void)deleteRequest:(int)userId bookId:(int)bookId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self DELETE:REQUESTID_URL(userId, bookId) parameters:param DEFAULT_CALLBACK];
}

// === [/users/:user_id/request] end

// === [/users/:user_id/frined] Friend API

- (void)getFriend: DEFAULT_PARAM2 {
    [SVProgressHUD showWithStatus:@"友達情報の読み込み中"];
    MAKE_TOKEN_PARAM();
    [self GET:FRIEND_URL(User.shared.userId) parameters:param DEFAULT_CALLBACK];
}

- (void)addFriend:(NSString*)invitationCode DEFAULT_PARAM {
    MAKE_PARAM_WITH_TOKEN((@{@"invitation_code":invitationCode}));
    [self POST:FRIEND_URL(User.shared.userId) parameters:param DEFAULT_CALLBACK];
}

- (void)deleteFriend:(long)friendId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self DELETE:FRIENDID_URL(User.shared.userId, friendId) parameters:param DEFAULT_CALLBACK];
}

- (void)getNewFriend: DEFAULT_PARAM2 {
    MAKE_TOKEN_PARAM();
    [self GET:FRIEND_NEW_URL(User.shared.userId) parameters:param DEFAULT_CALLBACK];
}

- (void)allowNewFriend:(int)friendId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self PUT:FRIEND_NEWID_URL(User.shared.userId, friendId) parameters:param DEFAULT_CALLBACK];
}

- (void)rejectNewFriend:(int)friendId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self DELETE:FRIEND_NEWID_URL(User.shared.userId, friendId) parameters:param DEFAULT_CALLBACK];
}

// === [/users/:user_id/frined] end


// === [/my/timeline] Timeline API

- (void)getTimeline: DEFAULT_PARAM2 {
    MAKE_TOKEN_PARAM();
    [self GET:TIMELINE_URL parameters:param DEFAULT_CALLBACK];
}

// === [/my/timeline] end


@end