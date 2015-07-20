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

@interface Backend ()
// maybe write private property here
//    @property int dummy;
@property NSString* accessToken;
@end

@implementation Backend : AFHTTPSessionManager

static Backend* instance = nil;

+ (Backend*)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *url = [[[NSProcessInfo processInfo]environment]objectForKey:@"BACKEND_URL"];
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
    callback(responseObject, nil);\
}\
failure:^(NSURLSessionDataTask *task, NSError *error) {\
    callback(nil, error);\
}

// URL builders
#define MAKE_URL(fmt, ...) [NSString stringWithFormat:(fmt), __VA_ARGS__]
#define USER_URL @"users"
#define USERID_URL(userId) MAKE_URL(USER_URL "/%d", (userId))
#define AUTH_URL @"auth"
#define AUTH_LOGIN_URL (AUTH_URL "/login")
#define BOOK_URL @"books"
#define BOOKID_URL(bookId) MAKE_URL(BOOK_URL "/%d", (bookId))
#define BOOKSHELF_URL @"bookshelves"
#define BOOKSHELFID_URL(userId) MAKE_URL(BOOKSHELF_URL "/%d", (userId))
#define BOOKSHELFIDID_URL(userId, bookId) MAKE_URL(BOOKSHELF_URL "/%d/%d", (userId), (bookId))
#define BORROW_URL(userId) MAKE_URL(USER_URL "/%d/borrow", (userId))
#define BORROWID_URL(userId, bookId) MAKE_URL(USER_URL "/%d/borrow/%d", (userId), (bookId))
#define BLACKLIST_URL(userId) MAKE_URL(USER_URL "/%d/blacklist", (userId))
#define BLACKLISTID_URL(userId, bookId) MAKE_URL(USER_URL "/%d/blacklist/%d", (userId), (bookId))
#define REQUEST_URL(userId) MAKE_URL(USER_URL "/%d/request", (userId))
#define REQUESTID_URL(userId, bookId) MAKE_URL(USER_URL "/%d/request/%d", (userId), (bookId))
#define FRIEND_URL(userId) MAKE_URL(USER_URL "/%d/friend", (userId))
#define FRIENDID_URL(userId, friendId) MAKE_URL(USER_URL "/%d/friend/%d", (userId), (friendId))
#define FRIEND_NEW_URL(userId) MAKE_URL(USER_URL "/%d/friend/new", (userId))
#define FRIEND_NEWID_URL(userId, friendId) MAKE_URL(USER_URL "/%d/friend/new/%d", (userId), (friendId))

// Default parameters
#define DEFAULT_PARAM  option:(NSDictionary*)option callback:(CompletionBlock)callback
#define DEFAULT_PARAM2        (NSDictionary*)option callback:(CompletionBlock)callback

// Make parameter
#define MAKE_PARAM(dict) \
NSMutableDictionary *param = [(dict) mutableCopy];\
[param addEntriesFromDictionary:option];

#define MAKE_PARAM_WITH_TOKEN(dict) \
MAKE_PARAM(dict);\
[param setObject:self.accessToken forKey:@"token"];

#define MAKE_TOKEN_PARAM() MAKE_PARAM(@{@"token":self.accessToken})

// Cast utilities
#define INT2NS(val) [NSNumber numberWithInt:(val)]
#define BOOL2NS(b) [NSNumber numberWithBool:(b)]



// === [/users] Users API

- (void)addUser:(NSString*)email password:(NSString*)password firstname:(NSString*)firstname lastname:(NSString*)lastname DEFAULT_PARAM {
    MAKE_PARAM((@{@"email":email, @"password":password, @"firstname":firstname, @"lastname":lastname }));
    [self POST:USER_URL parameters:param DEFAULT_CALLBACK];
}

- (void)getUser:(int)userId DEFAULT_PARAM {
    [self GET:USERID_URL(userId) parameters:option DEFAULT_CALLBACK];
}

- (void)updateUser:(int)userId DEFAULT_PARAM {
    [self PUT:USERID_URL(userId) parameters:option DEFAULT_CALLBACK];
}

- (void)deleteUser:(int)userId DEFAULT_PARAM {
    [self DELETE:USERID_URL(userId) parameters:option DEFAULT_CALLBACK];
}

// === [/users] end

// === [/auth] Auth API

- (void)login:(NSString*)email password:(NSString*)password DEFAULT_PARAM {
    MAKE_PARAM((@{@"email":email, @"password":password}));
    [self POST:AUTH_LOGIN_URL parameters:param
       success:^(NSURLSessionDataTask *task, id responseObject) {
           self.accessToken = responseObject[@"token"];
           callback(responseObject, nil);
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           callback(nil, error);
       }
    ];
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
    [self GET:BOOKSHELFID_URL(userId) parameters:option DEFAULT_CALLBACK];
}

- (void)addBookToBookshelf:(int)userId bookId:(int)bookId DEFAULT_PARAM {
    MAKE_PARAM(@{@"book_id":INT2NS(bookId)});
    [self GET:BOOKSHELFID_URL(userId) parameters:param DEFAULT_CALLBACK];
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
    [self GET:BOOKSHELFID_URL(userId) parameters:option DEFAULT_CALLBACK];
}

// === [/bookshelves] end

// === [/users/:user_id/borrow] Borrow API

- (void)getBorrow:(int)userId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self GET:BORROW_URL(userId) parameters:param DEFAULT_CALLBACK];
}

- (void)addBorrow:(int)userId bookId:(int)bookId lenderId:(int)lenderId DEFAULT_PARAM {
    MAKE_PARAM_WITH_TOKEN((@{@"book_id":INT2NS(bookId), @"lender_id":INT2NS(lenderId)}));
    [self POST:BORROW_URL(userId) parameters:param DEFAULT_CALLBACK];
}

- (void)deleteBorrow:(int)userId bookId:(int)bookId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self DELETE:BORROWID_URL(userId, bookId) parameters:param DEFAULT_CALLBACK];
}

// === [/users/:user_id/borrow] end

// === [/users/:user_id/blacklist] Blacklist API

- (void)getBlacklist:(int)userId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self GET:BLACKLIST_URL(userId) parameters:param DEFAULT_CALLBACK];
}

- (void)addBlacklist:(int)userId bookId:(int)bookId lenderId:(int)lenderId DEFAULT_PARAM {
    MAKE_PARAM_WITH_TOKEN((@{@"book_id":INT2NS(bookId), @"lender_id":INT2NS(lenderId)}));
    [self POST:BLACKLIST_URL(userId) parameters:param DEFAULT_CALLBACK];
}

- (void)deleteBlacklist:(int)userId bookId:(int)bookId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self DELETE:BLACKLISTID_URL(userId, bookId) parameters:param DEFAULT_CALLBACK];
}

// === [/users/:user_id/blacklist] end

// === [/users/:user_id/request] Request API

- (void)getRequest:(int)userId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self GET:REQUEST_URL(userId) parameters:param DEFAULT_CALLBACK];
}

- (void)addRequest:(int)userId bookId:(int)bookId senderId:(int)senderId DEFAULT_PARAM {
    MAKE_PARAM_WITH_TOKEN((@{@"book_id":INT2NS(bookId), @"sender_id":INT2NS(senderId)}));
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

- (void)getFriend:(int)userId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self GET:FRIEND_URL(userId) parameters:param DEFAULT_CALLBACK];
}

- (void)addFriend:(int)userId friendId:(int)friendId DEFAULT_PARAM {
    MAKE_PARAM_WITH_TOKEN((@{@"friend_id":INT2NS(friendId)}));
    [self POST:FRIEND_URL(userId) parameters:param DEFAULT_CALLBACK];
}

- (void)deleteFriend:(int)userId friendId:(int)friendId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self DELETE:FRIENDID_URL(userId, friendId) parameters:param DEFAULT_CALLBACK];
}

- (void)getNewFriend:(int)userId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self GET:FRIEND_NEW_URL(userId) parameters:param DEFAULT_CALLBACK];
}

- (void)allowNewFriend:(int)userId friendId:(int)friendId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self PUT:FRIEND_NEWID_URL(userId, friendId) parameters:param DEFAULT_CALLBACK];
}

- (void)rejectNewFriend:(int)userId friendId:(int)friendId DEFAULT_PARAM {
    MAKE_TOKEN_PARAM();
    [self DELETE:FRIEND_NEWID_URL(userId, friendId) parameters:param DEFAULT_CALLBACK];
}

// === [/users/:user_id/frined] end



@end