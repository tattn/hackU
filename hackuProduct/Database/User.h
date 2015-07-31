//
//  User.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/29.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#ifndef hackuProduct_User_h
#define hackuProduct_User_h

@interface User: NSObject

+ (instancetype)shared;

@property int userId;
@property NSString* email;
@property NSString* firstname;
@property NSString* lastname;
@property NSString* school;
@property NSString* comment;

- (void)update:(NSDictionary*)user;
- (void)reset;

@end

#endif
