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

@end

#endif
