#import "StratosPrefs.h"
#import <Preferences/PSListController.h>
#import <Preferences/PSTableCellType.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "buttons.h"

//OBJC_EXTERN UIImage *_UICreateScreenUIImage(void) NS_RETURNS_RETAINED;
//OBJC_EXTERN CGImageRef UIGetScreenImage(void);

#define localized(a, b) [[self bundle] localizedStringForKey:(a) value:(b) table:nil]

@interface StratosPrefsController : PSListController {
    UIView *stratosHeightView;
    UIWindow *settingsView;
    UIBarButtonItem *composeTweet;
    NSMutableArray *hiddenSpecs;
    UIView *switcherView;
    UIImageView *phoneView;
    UIView *grabberView;
}
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) NSUserDefaults *stratosUserDefaults;
@end
