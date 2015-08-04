//
//  Book.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/08/04.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"

@implementation Book

+(instancetype)initWithDic:(NSDictionary*)dic {
    Book* book = [Book new];
    book->bookId = [book getInt:dic[@"bookId"]];
    book->title = [book getStr:dic[@"title"]];
    book->isbn = [book getStr:dic[@"isbn"]];
    book->author = [book getStr:dic[@"author"]];
    book->publisher = [book getStr:dic[@"publisher"]];
    book->manufacturer = [book getStr:dic[@"manufacturer"]];
    book->genreId = [book getInt:dic[@"genreId"]];
    book->coverImageUrl = [book getStr:dic[@"coverImageUrl"]];
    book->salesrank = [book getInt:dic[@"salesrank"]];
    book->publicationDateStr = [book getStr:dic[@"publicationDate"]];
//    book->publicationDate;
    book->amazonUrl = [book getStr:dic[@"amazonUrl"]];
    return book;
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

- (NSComparisonResult) compareTitle:(Book*)_book {
  return [self->title localizedCaseInsensitiveCompare:_book->title];
}

- (NSComparisonResult) compareTitleInv:(Book*)_book {
  return [_book->title localizedCaseInsensitiveCompare:self->title];
}

@end