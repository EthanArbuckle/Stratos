#import "StratosTintedSwitchCell.h"

@implementation StratosTintedSwitchCell
/*
-(id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
	DebugLog(@"1");
    self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
    if (self) {
    	DebugLog(@"2");
        if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Eclipse.dylib"] && [(__bridge id)CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("com.gmoran.eclipse")) boolValue]) //Eclipse Compatibility
            [((UISwitch *)[self control]) setTintColor:kTintColor];
        DebugLog(@"3");
        [((UISwitch *)[self control]) setOnTintColor:kTintColor]; //change the switch color
    }
    return self;
}
*/
-(void)layoutSubviews {
	DebugLog(@"4");
    [super layoutSubviews];
    DebugLog(@"5");
    self.textLabel.textColor = kDarkerTintColor;
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Eclipse.dylib"] && [(__bridge id)CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("com.gmoran.eclipse")) boolValue]) //Eclipse Compatibility
        [((UISwitch *)[self control]) setTintColor:kTintColor];
    DebugLog(@"3");
    [((UISwitch *)[self control]) setOnTintColor:kTintColor]; //change the switch color
}

@end
