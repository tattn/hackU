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

typedef NS_ENUM (int, BarcodeMode) {
    kBarcodeModeBarcode = 0x1,
    kBarcodeModeQRcode  = 0x2,
};

- (void)setupCamera;
- (void)start:(int)mode;
- (void)stop;

@end
