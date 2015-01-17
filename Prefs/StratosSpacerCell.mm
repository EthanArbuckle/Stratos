#import "StratosSpacerCell.h"

@implementation StratosSpacerCell


- (id)initWithSpecifier:(id)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        height = [[specifier propertyForKey:@"spacerHeight"] floatValue];
    }
    
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    return height;
}

@end