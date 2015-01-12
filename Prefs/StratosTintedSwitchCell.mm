#import <UIKit/UIKit.h>
#import <Preferences/PSSwitchTableCell.h>
#import "StratosPrefs.h"

@interface StratosTintedSwitchCell : PSSwitchTableCell { }
@end

@implementation StratosTintedSwitchCell

-(id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
    self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
    if (self) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Eclipse.dylib"] && [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("com.gmoran.eclipse"))) boolValue]) //Eclipse Compatibility
            [((UISwitch *)[self control]) setTintColor:kTintColor];
        [((UISwitch *)[self control]) setOnTintColor:kTintColor]; //change the switch color
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.textColor = kDarkerTintColor;
}

@end
