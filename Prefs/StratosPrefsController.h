#import "StratosPrefs.h"
#import <Preferences/PSListController.h>
#import <Preferences/PSTableCellType.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "buttons.h"

#define localized(a, b) [[self bundle] localizedStringForKey:(a) value:(b) table:nil]

@interface StratosPrefsController : PSListController {
    UIView *stratosHeightView;
    UIWindow *settingsView;
    UIBarButtonItem *composeTweet;
    PSSpecifier *stratosHeader;
    PSSpecifier *enabledFooter;
    PSSpecifier *enabledSwitch;
    PSSpecifier *backgroundStyleFooter;
    PSSpecifier *backgroundStyleCell;
    PSSpecifier *heightSliderGroup;
    PSSpecifier *heightSlider;
    PSSpecifier *previewSpecifier;
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
    UIView *switcherView;
    UIImageView *phoneView;
    UIView *grabberView;
}
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) NSUserDefaults *stratosUserDefaults;
@end