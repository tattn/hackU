//
//  Bookshelf.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/08/05.
//  Copyright (c) 2015年 Kazusa Sakamoto. All rights reserved.
//

#ifndef hackuProduct_Bookshelf_h
#define hackuProduct_Bookshelf_h
#import "Book.h"

@interface Bookshelf: NSObject {
    @public
    int userId;
    int borrowerId;
    int rate;
    Book* book;
    NSDate* createdAt;
}

+(instancetype)initWithDic:(NSDictionary*)dic;

- (NSComparisonResult) compareTitle:(Bookshelf*)_book;
- (NSComparisonResult) compareTitleInv:(Bookshelf*)_book;
- (NSComparisonResult) comparePublicationDate:(Bookshelf*)_book;
- (NSComparisonResult) comparePublicationDateInv:(Bookshelf*)_book;

- (NSComparisonResult) compareCreatedAt:(Bookshelf*)_bookshelf;
- (NSComparisonResult) compareCreatedAtInv:(Bookshelf*)_bookshelf;

@end

#endif
