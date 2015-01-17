#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCellType.h>
#import "StratosPrefs.h"

#define localized(a, b) [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/StratosPrefs.bundle"] localizedStringForKey:(a) value:(b) table:nil]

@interface StratosCreditsListController : PSListController {
    UIWindow *settingsView;
}
@end