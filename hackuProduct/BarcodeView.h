//
//  BarcodeView.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/30.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol BarcodeDelegate <NSObject>

- (void)detectedBarcode:(NSString*)code;

@end

@interface BarcodeView : UIView <AVCaptureMetadataOutputObjectsDelegate>

@property id<BarcodeDelegate> delegate;

- (void)setupCamera;
- (void)start;
- (void)stop;

@end
