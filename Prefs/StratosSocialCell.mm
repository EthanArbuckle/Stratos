#import "StratosSocialCell.h"

@implementation StratosSocialCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
    if (self) {
    	self.detailTextLabel.text = specifier.properties[@"handle"];
    	self.detailTextLabel.textColor = [UIColor colorWithRed:151.0f/255.0f green:151.0f/255.0f blue:163.0f/255.0f alpha:1.0];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.textColor = kDarkerTintColor;
}

@end