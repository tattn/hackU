//
//  BarcodeViewController.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/28.
//  Copyright © 2015年 Tatsuya Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol BarcodeDelegate <NSObject>

- (void)detectedBarcode:(NSString*)code;

@end

@interface BarcodeViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property id<BarcodeDelegate> delegate;

@end

