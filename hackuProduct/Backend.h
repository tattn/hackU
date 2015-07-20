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

// === [/users] Users API
- (void)addUser:(NSString*)email password:(NSString*)password firstname:(NSString*)firstname lastname:(NSString*)lastname DEFAULT_PARAM;
- (void)getUser:(int)userId DEFAULT_PARAM;
- (void)updateUser:(int)userId DEFAULT_PARAM;
- (void)deleteUser:(int)userId DEFAULT_PARAM;
// === [/users] end

// === [/auth] Auth API
- (void)login:(NSString*)email password:(NSString*)password DEFAULT_PARAM;
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

// === [/users/:user_id/borrow] Borrow API
- (void)getBorrow:(int)userId DEFAULT_PARAM;
- (void)addBorrow:(int)userId bookId:(int)bookId lenderId:(int)lenderId DEFAULT_PARAM;
- (void)deleteBorrow:(int)userId bookId:(int)bookId DEFAULT_PARAM;
// === [/users/:user_id/borrow] end

// === [/users/:user_id/blacklist] Blacklist API
- (void)getBlacklist:(int)userId DEFAULT_PARAM;
- (void)addBlacklist:(int)userId bookId:(int)bookId lenderId:(int)lenderId DEFAULT_PARAM;
- (void)deleteBlacklist:(int)userId bookId:(int)bookId DEFAULT_PARAM;
// === [/users/:user_id/blacklist] end

// === [/users/:user_id/request] Request API
- (void)getRequest:(int)userId DEFAULT_PARAM;
- (void)addRequest:(int)userId bookId:(int)bookId senderId:(int)senderId DEFAULT_PARAM;
- (void)replyRequest:(int)userId bookId:(int)bookId accepted:(bool)accepted DEFAULT_PARAM;
- (void)deleteRequest:(int)userId bookId:(int)bookId DEFAULT_PARAM;
// === [/users/:user_id/request] end

// === [/users/:user_id/frined] Friend API
- (void)getFriend:(int)userId DEFAULT_PARAM;
- (void)addFriend:(int)userId friendId:(int)friendId DEFAULT_PARAM;
- (void)deleteFriend:(int)userId friendId:(int)friendId DEFAULT_PARAM;
- (void)getNewFriend:(int)userId DEFAULT_PARAM;
- (void)allowNewFriend:(int)userId friendId:(int)friendId DEFAULT_PARAM;
- (void)rejectNewFriend:(int)userId friendId:(int)friendId DEFAULT_PARAM;
// === [/users/:user_id/frined] end

#undef DEFAULT_PARAM
#undef DEFAULT_PARAM2

@end

#endif
