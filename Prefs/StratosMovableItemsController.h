#import <UIKit/UIKit.h>
#import "../Stratos.h"
#import <Preferences/PSViewController.h>
#import <Cephei/HBPreferences.h>
#import "StratosPrefs.h"

#define localized(a, b) [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/StratosPrefs.bundle"] localizedStringForKey:(a) value:(b) table:nil]

@interface StratosMovableItemsController : PSViewController <UITableViewDataSource, UITableViewDelegate> {
    HBPreferences *preferences;
    UIWindow *settingsView;
    NSArray *names;
}
@property (nonatomic, strong) UITableView *tableView;
@end