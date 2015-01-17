#import <UIKit/UIKit.h>
#import "../Stratos.h"
#import <Preferences/PSViewController.h>
#import "StratosPrefs.h"

#define localized(a, b) [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/StratosPrefs.bundle"] localizedStringForKey:(a) value:(b) table:nil]

@interface StratosMovableItemsController : PSViewController <UITableViewDataSource, UITableViewDelegate> {
    NSUserDefaults *stratosUserDefaults;
    UIWindow *settingsView;
    NSDictionary *names;
}
@property (nonatomic, strong) UITableView *tableView;
@end