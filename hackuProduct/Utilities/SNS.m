//
//  SNS.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/29.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNS.h"

@implementation SNS

+ (void)postToLine:(NSString*)message {
    NSString *contentKey = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                    NULL,
                                                                    (CFStringRef)message,
                                                                    NULL,
                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                    kCFStringEncodingUTF8 );

    NSString *contentType = @"text";

    NSString *urlString = [NSString
                           stringWithFormat: @"http://line.naver.jp/R/msg/%@/?%@",
                           contentType, contentKey];
    NSURL *url = [NSURL URLWithString:urlString];
    /*
     // LINE に直接遷移。contentType で画像を指定する事もできる。アプリが入っていない場合は何も起きない。
     NSString *urlString2 = [NSString
     stringWithFormat:@"line://msg/%@/%@",
     contentType, contentKey];
     NSURL *url = [NSURL URLWithString:urlString2];
     */

    [[UIApplication sharedApplication] openURL:url];
}

@end
