#import <Preferences/PSTableCell.h>

@interface StratosHeaderCell : PSTableCell { }
@end

@implementation StratosHeaderCell


- (id)initWithSpecifier:(id)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        
    }
    
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    return 160.0f;
}

@end