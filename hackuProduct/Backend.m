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
#define USER_URL @"users"
#define BOOK_URL @"books"
#define BOOKID_URL(bookId) MAKE_URL(BOOK_URL "/%d", (bookId))
#define BOOKSHELF_URL @"bookshelves"
#define BOOKSHELFID_URL(userId) MAKE_URL(BOOKSHELF_URL "/%d", (userId))
#define BOOKSHELFIDID_URL(userId, bookId) MAKE_URL(BOOKSHELF_URL "/%d/%d", (userId), (bookId))
#define BORROW_URL(userId) MAKE_URL(USER_URL "/%d/borrow", (userId))
#define BORROWID_URL(userId, bookId) MAKE_URL(USER_URL "/%d/borrow/%d", (userId), (bookId))

// Default parameters
#define DEFAULT_PARAM  option:(NSDictionary*)option callback:(CompletionBlock)callback
#define DEFAULT_PARAM2        (NSDictionary*)option callback:(CompletionBlock)callback

#define MAKE_PARAM(dict) \
NSMutableDictionary *param = [(dict) mutableCopy];\
[param addEntriesFromDictionary:option];

// Cast utilities
#define INT2NS(val) [NSNumber numberWithInt:(val)]



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
    [self GET:BORROW_URL(userId) parameters:option DEFAULT_CALLBACK];
}

- (void)addBorrow:(int)userId bookId:(int)bookId lenderId:(int)lenderId DEFAULT_PARAM {
    MAKE_PARAM((@{@"book_id":INT2NS(bookId), @"lender_id":INT2NS(lenderId)}));
    [self POST:BORROW_URL(userId) parameters:param DEFAULT_CALLBACK];
}

- (void)deleteBorrow:(int)userId bookId:(int)bookId DEFAULT_PARAM {
    [self DELETE:BORROWID_URL(userId, bookId) parameters:option DEFAULT_CALLBACK];
}

// === [/users/:user_id/borrow] end


@end