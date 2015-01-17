#import "StratosPrefs.h"
#import <UIKit/UIKit.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>

#define localized(a, b) [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/StratosPrefs.bundle"] localizedStringForKey:(a) value:(b) table:nil]

@interface StratosDevCell : PSTableCell {
    UIImageView *_background;
    UILabel *devName;
    UILabel *devRealName;
    UILabel *jobSubtitle;
}
@end