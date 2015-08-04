//
//  User.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/29.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#ifndef hackuProduct_User_h
#define hackuProduct_User_h

@interface User: NSObject {
    
@public
    int userId;
    NSString* email;
    NSString* firstname;
    NSString* lastname;
    NSString* fullname;
    NSString* school;
    NSString* comment;
    int bookNum;
    int lendNum;
    int borrowNum;
}


- (void)update:(NSDictionary*)user;
- (void)reset;
+(instancetype)initWithDic:(NSDictionary*)dic;

- (NSComparisonResult) compareName:(User*)_user;
- (NSComparisonResult) compareBookNum:(User*)_user;
- (NSComparisonResult) compareBookNumInv:(User*)_user;

@end

@interface My: NSObject

@property User* user;
    
+ (instancetype)shared;

@end

#endif
