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

#undef DEFAULT_PARAM
#undef DEFAULT_PARAM2

@end

#endif
