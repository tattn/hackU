//
//  User.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/29.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "User.h"

@implementation My

static My* instance = nil;

+ (My*)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [My new];
        instance.user = [User new];
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

@end

@implementation User


- (void)update:(NSDictionary*)user {
    if ([user objectForKey:@"userId"]) userId = ((NSString*)user[@"userId"]).intValue;
    if ([user objectForKey:@"email"]) email = user[@"email"];
    if ([user objectForKey:@"firstname"]) firstname = user[@"firstname"];
    if ([user objectForKey:@"lastname"]) lastname = user[@"lastname"];
    if ([user objectForKey:@"school"]) school = user[@"school"];
    if ([user objectForKey:@"comment"]) comment = user[@"comment"];
    if ([user objectForKey:@"bookNum"]) bookNum = [self getInt:user[@"bookNum"]];
    if ([user objectForKey:@"lendNum"]) lendNum = [self getInt:user[@"lendNum"]];
    if ([user objectForKey:@"borrowNum"]) borrowNum = [self getInt:user[@"borrowNum"]];
}

- (void)reset {
    userId = -1;
}

+(instancetype)initWithDic:(NSDictionary*)dic {
    User* user = [User new];
    user->userId = [user getInt:dic[@"userId"]];
    user->email = dic[@"email"];
    user->firstname = dic[@"firstname"];
    user->lastname = dic[@"lastname"];
    user->fullname = dic[@"fullname"];
    user->school = [user getStr:dic[@"school"]];
    user->comment = [user getStr:dic[@"comment"]];
    user->bookNum = [user getInt:dic[@"bookNum"]];
    user->lendNum = [user getInt:dic[@"lendNum"]];
    user->borrowNum = [user getInt:dic[@"borrowNum"]];
    return user;
}

- (int)getInt:(NSNumber*)num {
    if (num == (id)[NSNull null]) {
        return -1;
    }
    return num.intValue;
}

- (NSString*)getStr:(NSString*)str {
    if (str == (id)[NSNull null]) {
        return @"";
    }
    return str;
}

- (NSComparisonResult) compareName:(User*)_user {
    return [self->fullname localizedCaseInsensitiveCompare:_user->fullname];
}

- (NSComparisonResult) compareBookNum:(User*)_user {
    if (self->bookNum < _user->bookNum) return NSOrderedAscending;
    else return NSOrderedDescending;
}

- (NSComparisonResult) compareBookNumInv:(User*)_user {
    if (self->bookNum > _user->bookNum) return NSOrderedAscending;
    else return NSOrderedDescending;
}

@end
