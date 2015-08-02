//
//  Backend.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/18.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#ifndef hackuProduct_Backend_h
#define hackuProduct_Backend_h

#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"


@interface Backend : AFHTTPSessionManager

typedef void (^CompletionBlock)(id responseObject, NSError *error);

+ (instancetype)shared;

// Default parameters
#define DEFAULT_PARAM  option:(NSDictionary*)option callback:(CompletionBlock)callback
#define DEFAULT_PARAM2        (NSDictionary*)option callback:(CompletionBlock)callback

// Cast utilities
#define INT2NS(val) [NSNumber numberWithInt:(val)]
#define LONG2NS(val) [NSNumber numberWithLong:(val)]
#define BOOL2NS(b) [NSNumber numberWithBool:(b)]
#define LONGLONG2NS(val) [NSNumber numberWithLongLong:(val)]


- (BOOL)isLoggedIn;

// === [/users] Users API
- (void)addUser:(NSString*)email password:(NSString*)password firstname:(NSString*)firstname lastname:(NSString*)lastname DEFAULT_PARAM;
- (void)getUser:(int)userId DEFAULT_PARAM;
- (void)updateUser:(int)userId DEFAULT_PARAM;
- (void)deleteUser:(int)userId DEFAULT_PARAM;
- (void)getProfileImage:(int)userId DEFAULT_PARAM;
- (void)uploadProfileImage:(int)userId image:(UIImage*)img DEFAULT_PARAM;
// === [/users] end

// === [/auth] Auth API
- (void)login:(NSString*)email password:(NSString*)password DEFAULT_PARAM;
- (void)logout: DEFAULT_PARAM2;
// === [/auth] end

// === [/books] Books API
- (void)addBook:(NSString*)title DEFAULT_PARAM;
- (void)getBook:(int)bookId DEFAULT_PARAM;
- (void)updateBook:(int)bookId DEFAULT_PARAM;
- (void)deleteBook:(int)bookId DEFAULT_PARAM;
- (void)searchBook:DEFAULT_PARAM2;
// === [/books] end

// === [/bookshelves] Bookshelves API
- (void)getBookshelf:(int)userId DEFAULT_PARAM;
- (void)addBookToBookshelf:(int)userId bookId:(int)bookId DEFAULT_PARAM;
- (void)updateBookshelf:(int)userId DEFAULT_PARAM;
- (void)deleteBookshelf:(int)userId DEFAULT_PARAM;
- (void)getBookInBookshelf:(int)userId bookId:(int)bookId DEFAULT_PARAM;
- (void)updateBookInBookshelf:(int)userId bookId:(int)bookId DEFAULT_PARAM;
- (void)deleteBookInBookshelf:(int)userId bookId:(int)bookId DEFAULT_PARAM;
- (void)searchBookInBookshelf:(int)userId DEFAULT_PARAM;
// === [/bookshelves] end

// === [/my/borrow] Borrow API
- (void)getBorrow: DEFAULT_PARAM2;
- (void)addBorrow:(int)bookId lenderId:(int)lenderId DEFAULT_PARAM;
- (void)deleteBorrow:(int)bookId DEFAULT_PARAM __attribute__ ((deprecated));
// === [/my/borrow] end

// === [/my/lend] Lend API
- (void)getLending: DEFAULT_PARAM2;
- (void)deleteLending:(int)bookId DEFAULT_PARAM;
// === [/my/lend] end

// === [/my/blacklist] Blacklist API
- (void)getBlacklist: DEFAULT_PARAM2;
- (void)addBlacklist:(long)userId DEFAULT_PARAM;
- (void)deleteBlacklist:(long)userId DEFAULT_PARAM;
// === [/my/blacklist] end

// === [/my/request] New Request API
- (void)getRequestIsent: DEFAULT_PARAM2;
// === [/my/request] end

// === [/users/:user_id/request] Request API
- (void)getRequest:(int)userId DEFAULT_PARAM;
- (void)addRequest:(int)userId bookId:(int)bookId DEFAULT_PARAM;
- (void)replyRequest:(int)userId bookId:(int)bookId accepted:(bool)accepted DEFAULT_PARAM;
- (void)deleteRequest:(int)userId bookId:(int)bookId DEFAULT_PARAM;
// === [/users/:user_id/request] end

// === [/users/:user_id/frined] Friend API
- (void)getFriend: DEFAULT_PARAM2;
- (void)addFriend:(int)friendId DEFAULT_PARAM;
- (void)deleteFriend:(long)friendId DEFAULT_PARAM;
- (void)getNewFriend: DEFAULT_PARAM2;
- (void)allowNewFriend:(int)friendId DEFAULT_PARAM;
- (void)rejectNewFriend:(int)friendId DEFAULT_PARAM;
// === [/users/:user_id/frined] end

#undef DEFAULT_PARAM
#undef DEFAULT_PARAM2

@end

#endif
