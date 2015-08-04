//
//  Bookshelf.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/08/05.
//  Copyright (c) 2015年 Kazusa Sakamoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bookshelf.h"

@implementation Bookshelf

+(instancetype)initWithDic:(NSDictionary*)dic {
    Bookshelf* bookshelf = [Bookshelf new];
    bookshelf->userId = [bookshelf getInt:dic[@"userId"]];
    bookshelf->borrowerId = [bookshelf getInt:dic[@"borrowerId"]];
    bookshelf->rate = [bookshelf getInt:dic[@"rate"]];
    bookshelf->book = [Book initWithDic:dic[@"book"]];
    NSString* createdAt = dic[@"createdAt"];
    if (createdAt != (id)[NSNull null]) {
        NSDateFormatter* dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSZZ"];
        bookshelf->createdAt = [dateFormatter dateFromString:createdAt];
    }
    return bookshelf;
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

- (NSComparisonResult) compareTitle:(Bookshelf*)_bookshelf {
    return [self->book compareTitle:_bookshelf->book];
}

- (NSComparisonResult) compareTitleInv:(Bookshelf*)_bookshelf {
    return [self->book compareTitleInv:self->book];
}

- (NSComparisonResult) comparePublicationDate:(Bookshelf*)_bookshelf {
    return [self->book comparePublicationDate:_bookshelf->book];
}

- (NSComparisonResult) comparePublicationDateInv:(Bookshelf*)_bookshelf {
    return [self->book comparePublicationDateInv:_bookshelf->book];
}

- (NSComparisonResult) compareCreatedAt:(Bookshelf*)_bookshelf {
  return [self->createdAt compare:_bookshelf->createdAt];
}

- (NSComparisonResult) compareCreatedAtInv:(Bookshelf*)_bookshelf {
  return [_bookshelf->createdAt compare:self->createdAt];
}

@end