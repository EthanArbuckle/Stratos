#import "StratosTintedSwitchCell.h"

@implementation StratosTintedSwitchCell

-(id)initWithStyle:(UITableViewCellStyle)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
    self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
    if (self) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Eclipse.dylib"] && [(__bridge id)CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("com.gmoran.eclipse")) boolValue]) //Eclipse Compatibility
            [((UISwitch *)[self control]) setTintColor:kTintColor];
        [((UISwitch *)[self control]) setOnTintColor:kTintColor]; //change the switch color
    }
    return self;
}

@end
