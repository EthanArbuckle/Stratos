#import "StratosSpacerCell.h"

@implementation StratosSpacerCell


- (id)initWithSpecifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        height = [specifier.properties[@"spacerHeight"] floatValue];
    }
    
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    return height;
}

@end