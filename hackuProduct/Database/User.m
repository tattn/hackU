//
//  User.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/29.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface User()

@end


@implementation User

static User* instance = nil;

+ (User*)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [User new];
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
    return self;
}

- (void)update:(NSDictionary*)user {
    if ([user objectForKey:@"userId"]) _userId = ((NSString*)user[@"userId"]).intValue;
    if ([user objectForKey:@"email"]) _email = user[@"email"];
    if ([user objectForKey:@"firstname"]) _firstname = user[@"firstname"];
    if ([user objectForKey:@"lastname"]) _lastname = user[@"lastname"];
    if ([user objectForKey:@"school"]) _school = user[@"school"];
    if ([user objectForKey:@"comment"]) _comment = user[@"comment"];
    if ([user objectForKey:@"bookNum"]) _bookNum = user[@"bookNum"];
    if ([user objectForKey:@"lendNum"]) _lendNum = user[@"lendNum"];
    if ([user objectForKey:@"borrowNum"]) _borrowNum = user[@"borrowNum"];
}

- (void)reset {
    _userId = -1;
}

@end
