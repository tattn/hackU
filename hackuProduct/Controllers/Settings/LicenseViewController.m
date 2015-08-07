//
//  LicenseViewController.m
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/25.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "LicenseViewController.h"

@interface LicenseViewController ()

@end

@implementation LicenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
//    float navBarHeight = self.navigationController.navigationBar.frame.size.height;
//    float topMargin = statusBarHeight + navBarHeight;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [UILabel new];
    label.frame = self.view.frame;
    label.text = @"Copyright(C) 2015 クマさんチーム All rights reserved.\n\n本アプリケーションは、以下のオープンソースソフトウェアを使用しています。\n\n";
    label.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:9.0f];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSString *settingBundlePath = [[[NSBundle mainBundle] bundlePath]
                                   stringByAppendingPathComponent:@"Settings.bundle"];
    NSBundle *settingBundle = [NSBundle bundleWithPath:settingBundlePath];
    NSString *licensePath = [settingBundle pathForResource:@"Acknowledgements" ofType:@"plist"];
    NSDictionary *licensePlist = [NSDictionary dictionaryWithContentsOfFile:licensePath];
    NSArray *licenses = licensePlist[@"PreferenceSpecifiers"];
    
    [licenses enumerateObjectsUsingBlock:^(NSDictionary *license, NSUInteger idx, BOOL *stop) {
        if (idx != 0 && idx != licenses.count - 1) {
            NSString *text = [NSString stringWithFormat:@"%@\n%@\n", license[@"Title"], license[@"FooterText"]];
            label.text = [label.text stringByAppendingString:text];
        }
    }];
    
    [label sizeToFit];
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.contentSize = label.frame.size;
    scrollView.frame = self.view.frame;
    [scrollView addSubview:label];
    [self.view addSubview:scrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
