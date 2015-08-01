//
//  AddFriendViewController.h
//  hackuProduct
//
//  Created by Tanaka Tatsuya on 2015/07/25.
//  Copyright (c) 2015年 Tatsuya Tanaka. All rights reserved.
//

#import "ImprovedViewController.h"
#import "BarcodeView.h"

@interface AddFriendViewController : ImprovedViewController <BarcodeDelegate>
@property (weak, nonatomic) IBOutlet UIButton *friendApplyButton;

@end
