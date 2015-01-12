#import "../Stratos.h"
#import <Preferences/Preferences.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "buttons.h"

#define DEBUG_PREFIX @"••• [Stratos Prefs]"
#import "../DebugLog.h"

@interface StratosListItemsController : PSListItemsController {
    UIWindow *settingsView;
}
@end

@interface StratosMovableItemsController : PSViewController <UITableViewDataSource, UITableViewDelegate> {
    NSUserDefaults *stratosUserDefaults;
    UIWindow *settingsView;
}
@property (nonatomic, strong) UITableView *tableView;
@end

@interface StratosPrefsController : PSListController {
    UIView *stratosHeightView;
    UIWindow *settingsView;
    UIBarButtonItem *composeTweet;
    NSUserDefaults *stratosUserDefaults;
    PSSpecifier *stratosHeader;
    PSSpecifier *enabledFooter;
    PSSpecifier *enabledSwitch;
    PSSpecifier *backgroundStyleFooter;
    PSSpecifier *backgroundStyleCell;
    PSSpecifier *heightSliderGroup;
    PSSpecifier *heightSlider;
    PSSpecifier *grabberSwitchFooter;
    PSSpecifier *grabberSwitch;
    PSSpecifier *showCCSwitchFooter;
    PSSpecifier *showCCSwitch;
    PSSpecifier *showRunningAppFooter;
    PSSpecifier *showRunningApp;
    PSSpecifier *defaultPageCellFooter;
    PSSpecifier *defaultPageCell;
    PSSpecifier *pageOrderCell;
    PSSpecifier *doublePressHomeFooter;
    PSSpecifier *doublePressHome;
    PSSpecifier *numberOfPagesCell;
    NSArray *hiddenSpecs;
}
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@end

@interface StratosTintedSwitchCell : PSSwitchTableCell { }
@end

@interface StratosTintedSliderCell : PSSliderTableCell {
    
}
@end

@interface StratosTintedCell : PSTableCell { }
@end

#define HEADER_HEIGHT		160.0f

@interface StratosHeaderCell : PSTableCell
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@end

@interface StratosCreditsListController : PSListController { }
@end

@interface StratosDevCell : PSTableCell {
    UIImageView *_background;
    UILabel *devName;
    UILabel *devRealName;
    UILabel *jobSubtitle;
}
@end

@interface StratosSocialCell : PSTableCell { }
@end

static UIColor *const kTintColor = [UIColor colorWithRed:96.0f/255.0f green:96.0f/255.0f blue:105.0f/255.0f alpha:1.0];
static UIColor *const kDarkerTintColor = [UIColor colorWithRed:67.0f/255.0f green:67.0f/255.0f blue:74.0f/255.0f alpha:1.0];

