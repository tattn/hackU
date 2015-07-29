//
//  BarcodeViewController.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/28.
//  Copyright © 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "BarcodeViewController.h"
#import "UIView+Toast.h"

@interface BarcodeViewController ()

@property AVCaptureSession *session;
@property AVCaptureDevice *device;
@property AVCaptureDeviceInput *input;
@property AVCaptureMetadataOutput *output;
@property AVCaptureVideoPreviewLayer *layer;

@property UIView *frameView;

@end

@implementation BarcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"バーコード読み取り";
    self.view.backgroundColor = [UIColor blackColor];
    
    _frameView = [UIView new];
    _frameView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _frameView.layer.borderColor = [UIColor greenColor].CGColor;
    _frameView.layer.borderWidth = 3;
    [self.view addSubview:_frameView];
    
    _session = [AVCaptureSession new];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    //TODO: カメラの使用許可が出てない場合はアラートを出して閉じるor設定画面へ
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    }else{
        NSLog(@"Error - Initialization of AVCaptureDeviceInput: %@", error);
    }
    
    _output = [AVCaptureMetadataOutput new];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _layer.frame = self.view.frame;
    _layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_layer];
    
    [self.view bringSubviewToFront:_frameView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view makeToast:@"本のバーコードにかざして下さい。"];
    
    [_session startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_session stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[
//                              AVMetadataObjectTypeUPCECode,
//                              AVMetadataObjectTypeCode39Code,
//                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code,
//                              AVMetadataObjectTypeEAN8Code,
//                              AVMetadataObjectTypeCode93Code,
//                              AVMetadataObjectTypeCode128Code,
//                              AVMetadataObjectTypePDF417Code,
//                              AVMetadataObjectTypeQRCode,
//                              AVMetadataObjectTypeAztecCode,
                              ];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type]) {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_layer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString && _delegate) {
            [_delegate detectedBarcode:detectionString];
            _frameView.frame = highlightViewRect;
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
    }
}

@end
