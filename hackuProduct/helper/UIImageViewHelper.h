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

@implementation UIImageView (UIUtil)

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

@end

#endif
