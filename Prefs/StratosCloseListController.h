#import <Preferences/PSListController.h>
#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCellType.h>
#import "StratosPrefs.h"
@interface StratosCloseListController : PSListController {
	UIImageView *phoneView;
	UIWindow *settingsView;
}
@end

#define localized(a, b) [[self bundle] localizedStringForKey:(a) value:(b) table:nil]