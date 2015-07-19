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

// === [/books] Books API
- (void)addBook:(NSString*)title option:(NSDictionary*)option callback:(CompletionBlock)callback;
- (void)getBook:(int)bookId callback:(CompletionBlock)callback;
- (void)updateBook:(int)bookId option:(NSDictionary*)option callback:(CompletionBlock)callback;
- (void)deleteBook:(int)bookId option:(NSDictionary*)option callback:(CompletionBlock)callback;
- (void)searchBook:(NSDictionary*)option callback:(CompletionBlock)callback;
// === [/books] end

// === [/bookshelves] Bookshelves API
- (void)getBookshelf:(int)userId option:(NSDictionary*)option callback:(CompletionBlock)callback;
- (void)addBookToBookshelf:(int)userId bookId:(int)bookId option:(NSDictionary*)option callback:(CompletionBlock)callback;
- (void)updateBookshelf:(int)userId option:(NSDictionary*)option callback:(CompletionBlock)callback;
- (void)deleteBookshelf:(int)userId option:(NSDictionary*)option callback:(CompletionBlock)callback;
- (void)getBookInBookshelf:(int)userId bookId:(int)bookId option:(NSDictionary*)option callback:(CompletionBlock)callback;
- (void)updateBookInBookshelf:(int)userId bookId:(int)bookId option:(NSDictionary*)option callback:(CompletionBlock)callback;
- (void)deleteBookInBookshelf:(int)userId bookId:(int)bookId option:(NSDictionary*)option callback:(CompletionBlock)callback;
- (void)searchBookInBookshelf:(int)userId option:(NSDictionary*)option callback:(CompletionBlock)callback;
// === [/bookshelves] end

@end

#endif
