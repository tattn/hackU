
#import "BookShelfCollectionViewCell.h"
#import <UIKit/UIKit.h>

@implementation BookShelfCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    [imageView setImage:image];
}

@end
