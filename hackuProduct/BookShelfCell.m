
#import "BookShelfCell.h"

@implementation BookShelfCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    NSLog(@"bundleLoader waked");
}

@end
