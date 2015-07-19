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
#define BOOK_URL @"books"
#define BOOKID_URL(bookId) MAKE_URL(BOOK_URL "/%d", (bookId))
#define BOOKSHELF_URL @"bookshelves"
#define BOOKSHELFID_URL(userId) MAKE_URL(BOOKSHELF_URL "/%d", (userId))
#define BOOKSHELFIDID_URL(userId, bookId) MAKE_URL(BOOKSHELF_URL "/%d/%d", (userId), (bookId))

// === [/books] Books API

- (void)addBook:(NSString*)title option:(NSDictionary*)option callback:(CompletionBlock)callback {
    NSMutableDictionary *param = [@{@"title":title} mutableCopy];
    for (id key in [option keyEnumerator]) {
        param[key] = [option valueForKey:key];
    }
    
    [self POST:BOOK_URL parameters:param DEFAULT_CALLBACK];
}

- (void)getBook:(int)bookId callback:(CompletionBlock)callback {
    [self GET:BOOKID_URL(bookId) parameters:nil DEFAULT_CALLBACK];
}

- (void)updateBook:(int)bookId option:(NSDictionary*)option callback:(CompletionBlock)callback {
    [self PUT:BOOKID_URL(bookId) parameters:option DEFAULT_CALLBACK];
}

- (void)deleteBook:(int)bookId option:(NSDictionary*)option callback:(CompletionBlock)callback {
    [self DELETE:BOOKID_URL(bookId) parameters:option DEFAULT_CALLBACK];
}

- (void)searchBook:(NSDictionary*)option callback:(CompletionBlock)callback {
    [self GET:BOOK_URL"/search" parameters:option DEFAULT_CALLBACK];
}

// === [/books] end

// === [/bookshelves] Bookshelves API

- (void)getBookshelf:(int)userId option:(NSDictionary*)option callback:(CompletionBlock)callback {
    [self GET:BOOKSHELFID_URL(userId) parameters:option DEFAULT_CALLBACK];
}

- (void)addBookToBookshelf:(int)userId bookId:(int)bookId option:(NSDictionary*)option callback:(CompletionBlock)callback {
    NSMutableDictionary *param = [@{@"book_id":[NSNumber numberWithInt:bookId]} mutableCopy];
    for (id key in [option keyEnumerator]) {
        param[key] = [option valueForKey:key];
    }
    
    [self GET:BOOKSHELFID_URL(userId) parameters:param DEFAULT_CALLBACK];
}

- (void)updateBookshelf:(int)userId option:(NSDictionary*)option callback:(CompletionBlock)callback {
    [self PUT:BOOKSHELFID_URL(userId) parameters:option DEFAULT_CALLBACK];
}

- (void)deleteBookshelf:(int)userId option:(NSDictionary*)option callback:(CompletionBlock)callback {
    [self DELETE:BOOKSHELFID_URL(userId) parameters:option DEFAULT_CALLBACK];
}

- (void)getBookInBookshelf:(int)userId bookId:(int)bookId option:(NSDictionary*)option callback:(CompletionBlock)callback {
    [self GET:BOOKSHELFIDID_URL(userId, bookId) parameters:option DEFAULT_CALLBACK];
}

- (void)updateBookInBookshelf:(int)userId bookId:(int)bookId option:(NSDictionary*)option callback:(CompletionBlock)callback {
    [self PUT:BOOKSHELFIDID_URL(userId, bookId) parameters:option DEFAULT_CALLBACK];
}

- (void)deleteBookInBookshelf:(int)userId bookId:(int)bookId option:(NSDictionary*)option callback:(CompletionBlock)callback {
    [self DELETE:BOOKSHELFIDID_URL(userId, bookId) parameters:option DEFAULT_CALLBACK];
}

- (void)searchBookInBookshelf:(int)userId option:(NSDictionary*)option callback:(CompletionBlock)callback {
    [self GET:BOOKSHELFID_URL(userId) parameters:option DEFAULT_CALLBACK];
}

// === [/bookshelves] end

@end