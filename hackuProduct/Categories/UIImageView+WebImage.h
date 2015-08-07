//
//  UIImageView.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/29.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#ifndef hackuProduct_UIImageViewHelper_h
#define hackuProduct_UIImageViewHelper_h

#import <UIKit/UIKit.h>
#import "SDWebImage/UIImageView+WebCache.h"

@interface UIImageView (WebImage)

- (void)my_setImageWithURL:(NSString*)url;
- (void)my_setImageWithURL:(NSString*)url defaultImage:(UIImage*)def;

@end

@implementation UIImageView (WebImage)

- (void)my_setImageWithURL:(NSString*)url {
    if (url != (id)[NSNull null] && ![url isEqual: @""]) {
        NSURL *nsurl = [NSURL URLWithString:url];
        [self sd_setImageWithURL:nsurl
                        placeholderImage:[UIImage imageNamed:nsurl.absoluteString]];
    }
    else {
        self.image = [UIImage imageNamed:@"NoImage"];
    }
}

- (void)my_setImageWithURL:(NSString*)url defaultImage:(UIImage*)def {
    if (url != (id)[NSNull null] && ![url isEqual: @""]) {
        NSURL *nsurl = [NSURL URLWithString:url];
        [self sd_setImageWithURL:nsurl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image.size.width == 0) {
                self.image = def;
            }
        }];
    }
    else {
        self.image = def;
    }
}

@end

#endif
