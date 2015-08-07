//
//  QRcodeView.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/08/01.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "QRcodeView.h"

@implementation QRcodeView

-(instancetype)init {
    self = [super init];
    
    // QRコードがぼやけないように最近傍法で拡大する
    self.layer.magnificationFilter = kCAFilterNearest;
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    return self;
}

-(void)layoutSubviews {
    
}

- (void)setString:(NSString*)str {
    CIFilter *ciFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [ciFilter setDefaults];
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [ciFilter setValue:data forKey:@"inputMessage"];
    
    // 誤り訂正レベル(Low)
    [ciFilter setValue:@"L" forKey:@"inputCorrectionLevel"];
    
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgimg =
    [ciContext createCGImage:[ciFilter outputImage]
                    fromRect:[[ciFilter outputImage] extent]];
    UIImage *image = [UIImage imageWithCGImage:cgimg scale:1.0f
                                   orientation:UIImageOrientationUp];
    CGImageRelease(cgimg);
    
    self.image = image;
}

@end
