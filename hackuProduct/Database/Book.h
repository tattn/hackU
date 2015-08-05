//
//  Book.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/08/04.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#ifndef hackuProduct_Book_h
#define hackuProduct_Book_h

@interface Book: NSObject {
    @public
    int bookId;
    NSString* title;
    NSString* isbn;
    NSString* author;
    NSString* publisher;
    NSString* manufacturer;
    int genreId;
    NSString* coverImageUrl;
    int salesrank;
    NSDate* publicationDate;
    NSString* publicationDateStr;
    NSString* amazonUrl;
    
}

+(instancetype)initWithDic:(NSDictionary*)dic;
+(instancetype)initWithDic2:(NSDictionary*)dic;

- (NSComparisonResult) compareTitle:(Book*)_book;
- (NSComparisonResult) compareTitleInv:(Book*)_book;
- (NSComparisonResult) comparePublicationDate:(Book*)_book;
- (NSComparisonResult) comparePublicationDateInv:(Book*)_book;

@end

#endif
