//
//  BarcodeView.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/30.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "BarcodeView.h"

@interface BarcodeView ()

@property AVCaptureSession *session;
@property AVCaptureDevice *device;
@property AVCaptureDeviceInput *input;
@property AVCaptureMetadataOutput *output;
@property AVCaptureVideoPreviewLayer *previewLayer;

@property UIView *frameView;

@property NSMutableArray *barCodeTypes;

@end


@implementation BarcodeView

- (void)drawRect:(CGRect)rect {
}

- (void)setupCamera {
    _frameView = [UIView new];
//    _frameView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _frameView.layer.borderColor = [UIColor greenColor].CGColor;
    _frameView.layer.borderWidth = 3;
    [self addSubview:_frameView];
    
    _session = [AVCaptureSession new];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    //TODO: カメラの使用許可が出てない場合はアラートを出して閉じるor設定画面へ
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    }
    else{
        NSLog(@"Error - Initialization of AVCaptureDeviceInput: %@", error);
    }
    
    _output = [AVCaptureMetadataOutput new];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:_previewLayer];
    
//    [self bringSubviewToFront:_frameView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _previewLayer.frame = self.frame;
}

- (void)start:(int)mode {
    _barCodeTypes = [NSMutableArray array];
    if (mode & kBarcodeModeBarcode) [_barCodeTypes addObject:AVMetadataObjectTypeEAN13Code];
    if (mode & kBarcodeModeQRcode) [_barCodeTypes addObject:AVMetadataObjectTypeQRCode];
    [_session startRunning];
}

- (void)stop {
    [_session stopRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in _barCodeTypes) {
            if ([metadata.type isEqualToString:type]) {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_previewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString && _delegate) {
            _frameView.frame = highlightViewRect;
            [self stop];
            [_delegate detectedBarcode:detectionString];
            break;
        }
    }
}

@end
