#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "SwitcherTrayView.h"
#import "SwitcherTrayCardView.h"
#import "IdentifierDaemon.h"
#import "TouchHighjacker.h"
#import "CDTSPreferences.h"


// helpers
#define l(args...) 				NSLog(@"[Stratos] %@", args);

#define DEBUG_PREFIX 			@"😈 [Stratos]"
#import "DebugLog.h"

#define PLIST_PATH [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences"] stringByAppendingPathComponent:kCDTSPreferencesDomain] stringByAppendingPathExtension:@"plist"]

#define YES_OR_NO				@"Yes":@"No"
#define IS_OS_8_OR_LATER [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0
#define IS_OS_7_OR_UNDER [[[UIDevice currentDevice] systemVersion] floatValue] <= 7.0

#define syncPrefs
#define boolPreference(key, var) do { NSNumber *obj = (NSNumber *)[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] objectForKey:(key)]; \
        (var) = obj ? [obj boolValue] : [kCDTSPreferencesDefaults[key] boolValue]; } while (0)
#define floatPreference(key, var) do { NSNumber *obj = (NSNumber *)[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] objectForKey:(key)]; \
        (var) = obj ? [obj floatValue] : [kCDTSPreferencesDefaults[key] floatValue]; } while (0)
#define integerPreference(key, var) do { NSNumber *obj = (NSNumber *)[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] objectForKey:(key)]; \
        (var) = obj ? [obj intValue] : [kCDTSPreferencesDefaults[key] intValue]; } while (0)
//#define getPreference(key) CFPreferencesCopyAppValue((CFStringRef)(key), (CFStringRef)kCDTSPreferencesDomain)

// layout
#define kScreenHeight 			[[UIScreen mainScreen] bounds].size.height
#define kScreenWidth 			[[UIScreen mainScreen] bounds].size.width

#define kiPhoneSmall 			[[UIScreen mainScreen] bounds].size.height < 568

//#define kSwitcherHeight 		[[(SBUIController *)NSClassFromString(@"SBUIController") stratosUserDefaults] floatForKey:kCDTSPreferencesSwitcherHeight]//kScreenHeight / 3.3 //172
#define kSwitcherMaxY 			kScreenHeight - [prefs switcherHeight]
#define kSwitcherCardWidth 		kScreenWidth / 4.5714 //70
#define kSwitcherCardHeight 	        kScreenHeight / 4.36 //130
#define kSwitcherCardSpacing	        ceil((kScreenWidth - (kSwitcherCardWidth * 4)) / 5) //8

#define kMultiViewCardWidth 	80
#define kMultiViewCardHeight 	150
#define kMultiViewCardSpacing 	20

#define kQuickLaunchTouchOffset 90

#define kStratosUserDefaults [(SBUIController *)NSClassFromString(@"SBUIController") stratosUserDefaults] 

#define kMediaControlsKey @3
#define kSwitcherCardsKey @1
#define kControlCenterKey @2


//settings
static NSString *const kCDTSPreferencesDomain = @"com.cortexdevteam.stratos";
static NSString *const kCDTSPreferencesEnabledKey = @"isEnabled";
static NSString *const kCDTSPreferencesTrayBackgroundStyle = @"switcherBackgroundStyle";
static NSString *const kCDTSPreferencesShowGrabber = @"showGrabber";
static NSString *const kCDTSPreferencesInvokeControlCenter = @"shouldInvokeCC";
static NSString *const kCDTSPreferencesShowRunningApp = @"showRunningApp";
static NSString *const kCDTSPreferencesActivateByDoubleHome = @"activateViaHome";
static NSString *const kCDTSPreferencesDefaultPage = @"defaultPage";
static NSString *const kCDTSPreferencesSwitcherHeight = @"switcherHeight";
static NSString *const kCDTSPreferencesPageOrder = @"pageOrder";
static NSString *const kCDTSPreferencesNumberOfPages = @"numberOfPages";
static NSString *const kCDTSPreferencesEnableParallax = @"enableParallax";
static NSString *const kCDTSPreferencesActiveMediaEnabled = @"activeMediaEnabled";
static NSString *const kCDTSPreferencesThirdSplit = @"thirdSplit";
static NSString *const kCDTSPreferencesEnableQuickLaunch = @"enableQuickLaunch";
static NSString *const kCDTSPreferencesEnableHomescreen = @"enableHomescreen";
static NSString *const kCDTSPreferencesSwipeToClose = @"swipeToClose";
static NSString *const kCDTSPreferencesSwipeToCloseWidth = @"swipeToCloseWidth";
static NSDictionary *const kCDTSPreferencesDefaults = @{
                                                                kCDTSPreferencesEnabledKey          : @NO,
                                                                kCDTSPreferencesTrayBackgroundStyle : @9999,
                                                                kCDTSPreferencesSwitcherHeight      : @(kScreenHeight / 3.3),
                                                                kCDTSPreferencesShowGrabber         : @YES,
                                                                kCDTSPreferencesEnableParallax      : @NO,
                                                                kCDTSPreferencesEnableQuickLaunch   : @YES,
                                                                kCDTSPreferencesInvokeControlCenter : @YES,
                                                                kCDTSPreferencesActiveMediaEnabled  : @NO,
                                                                kCDTSPreferencesShowRunningApp      : @NO,
                                                                kCDTSPreferencesDefaultPage         : kSwitcherCardsKey,
                                                                kCDTSPreferencesEnableHomescreen    : @NO,
                                                                kCDTSPreferencesActivateByDoubleHome: @NO,
                                                                kCDTSPreferencesPageOrder           : @[ kControlCenterKey, kMediaControlsKey, kSwitcherCardsKey ], //in order from left to right
                                                                kCDTSPreferencesNumberOfPages       : @6, //number of pages for multitasking card view
                                                                kCDTSPreferencesThirdSplit          : @NO,
                                                                kCDTSPreferencesEnableQuickLaunch   : @NO,
                                                                kCDTSPreferencesEnableHomescreen    : @NO,
                                                                kCDTSPreferencesSwipeToClose        : @NO,
                                                                kCDTSPreferencesSwipeToCloseWidth   : @(kScreenWidth/3)
                                                        };

// private interfaces
@interface SBUIController : NSObject
+ (id)sharedInstance;
- (id)valueForKey:(id)arg1;
- (void)_suspendGestureBegan;
- (void)_suspendGestureChanged:(CGFloat)arg1;
- (void)_suspendGestureCancelled;
- (BOOL)_ignoringEvents;
- (void)activateApplicationAnimated:(id)application;
- (void)getRidOfAppSwitcher;
- (BOOL)clickedMenuButton;
- (void)_installSystemGestureView:(UIView *)gestureView forKey:(id<NSCopying>)key forGesture:(NSUInteger)gestureType;
- (void)notifyAppResignActive:(id)active;
- (void)restoreContentAndUnscatterIconsAnimated:(BOOL)animated;
- (void)_clearInstalledSystemGestureViewForKey:(id<NSCopying>)key;
- (void)_showControlCenterGestureBeganWithLocation:(CGPoint)location;
- (void)_showControlCenterGestureEndedWithLocation:(CGPoint)location velocity:(CGPoint)velocity;
- (void)stopRestoringIconList;
- (void)tearDownIconListAndBar;
- (void)notifyAppResumeActive:(id)app;
@end

@interface SBUIController (Stratos)
- (void)stratos_animateObject:(id)view toFrame:(CGRect)frame withDuration:(CGFloat)duration;
//+ (NSUserDefaults *)stratosUserDefaults;
- (void)stratos_updateHomescreenImage;
- (UIImage *)stratos_homeScreenImage;
@end

@interface SBAppSliderSnapshotView : UIView
- (void)_loadSnapshotSync;
@end

@interface SBAppSwitcherSnapshotView : NSObject

@end

@interface SBAppSwitcherModel : NSObject
- (id)sharedInstance;
- (NSArray *)identifiers;
- (NSArray *)snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary;
@end

@interface SBAppSwitcherController

-(id)_snapshotViewForDisplayItem:(id)displayItem;

@end

@interface _UIBackdropView : UIView
- (id)initWithStyle:(int)arg1;
@end


@interface SBControlCenterGrabberView : UIView
- (id)chevronView;
@end

@interface SBChevronView
- (void)setState:(int)state animated:(BOOL)animated;
@end

@interface SBApplicationController : NSObject
- (id)applicationWithDisplayIdentifier:(id)arg1;
- (id)applicationWithBundleIdentifier:(id)arg1;
@end

@interface SBApplicationController (Stratos)
- (id)stratos_applicationWithDisplayIdentifier:(id)arg1;
@end


@interface SBApplicationIcon : NSObject
- (id)initWithApplication:(id)arg1;
- (id)generateIconImage:(int)arg1;
@end

@interface SBDeactivationSettings

-(id)init;
-(void)setFlag:(int)flag forDeactivationSetting:(unsigned)deactivationSetting;

@end

@interface SBApplication : UIApplication

@property(copy) NSString* displayIdentifier;
@property(copy) NSString* bundleIdentifier;
@property(copy, nonatomic, setter=_setDeactivationSettings:) SBDeactivationSettings *_deactivationSettings;
- (id)valueForKey:(id)arg1;
- (NSString *)displayName;
- (int)pid;
- (id)mainScene;
- (NSString *)path;
- (id)mainScreenContextHostManager;
- (void)setDeactivationSetting:(unsigned int)setting value:(id)value;
- (void)setDeactivationSetting:(unsigned int)setting flag:(BOOL)flag;
- (id)bundleIdentifier;
- (id)displayIdentifier;
- (void)notifyResignActiveForReason:(int)reason;
- (void)notifyResumeActiveForReason:(int)reason;
- (void)activate;
@end

@interface SBApplication (Stratos)
- (NSString *)stratos_displayIdentifier;
@end


@interface MPUSystemMediaControlsViewController : UIViewController
- (id)initWithStyle:(int)arg1;
- (id)view;
@end


@interface SBControlCenterController : UIViewController
- (void)presentAnimated:(BOOL)animated;
- (UIWindow *)_window;
+ (id)_sharedInstanceCreatingIfNeeded:(BOOL)needed;
@end


@interface SBCCBrightnessSectionController : UIViewController
@end


@interface SBCCSettingsSectionController : UIViewController
@end


@interface SBCCQuickLaunchSectionController : UIViewController
@end


@interface SBSyncController : NSObject
- (id)sharedInstance;
- (void)_killApplications;
@end


@interface SBAppSliderController : UIViewController
- (id)_snapshotViewForDisplayIdentifier:(id)displayIdentifier;
- (UIViewController *)pageController;
- (void)sliderScroller:(id)arg1 itemTapped:(unsigned long long)arg2;
@end


@interface SBAppStatusBarManager : NSObject
- (id)sharedInstance;
- (void)showStatusBar;
@end


@interface SBCloseBoxView : UIView
@end


@interface SpringBoard : UIApplication
- (id)_accessibilityFrontMostApplication;
@end

@interface UIApplication (Private)
- (void)_relaunchSpringBoardNow;
- (id)_accessibilityFrontMostApplication;
- (void)launchApplicationWithIdentifier: (NSString*)identifier suspended: (BOOL)suspended;
@end

@interface SBGestureViewVendor : NSObject
+ (id)sharedInstance;
- (id)viewForApp:(id)app gestureType:(unsigned)type includeStatusBar:(BOOL)bar;
@end


@interface SBWallpaperController : NSObject
+ (instancetype)sharedInstance;
- (void)endRequiringWithReason:(id)reason;
- (void)beginRequiringWithReason:(id)reason;
@end


@interface SBWindowContextHostManager : NSObject
- (void)disableHostingForRequester:(NSString *)requestor;
@end


@interface SBWorkspaceEvent : NSObject
+ (instancetype)eventWithLabel:(NSString *)label handler:(id)handler;
@end

@interface FBWorkspaceEvent : NSObject
+ (instancetype)eventWithName:(NSString *)label handler:(id)handler;
@end


@interface SBWorkspaceEventQueue : NSObject
+ (instancetype)sharedInstance;
- (void)executeOrAppendEvent:(SBWorkspaceEvent *)event;
@end

@interface FBWorkspaceEventQueue : NSObject
+ (instancetype)sharedInstance;
- (void)executeOrAppendEvent:(FBWorkspaceEvent *)event;
@end

@class BKSWorkspace;
@interface SBWorkspace : NSObject
- (SBApplication *)_applicationForBundleIdentifier:(NSString *)identifier frontmost:(BOOL)frontmost;
@property (readonly, nonatomic) BKSWorkspace *bksWorkspace;
@property(retain, nonatomic) id currentTransaction;
@end


@interface SBAppToAppWorkspaceTransaction : NSObject
- (void)begin;
- (id)initWithAlertManager:(id)alertManager exitedApp:(id)app;
- (id)initWithAlertManager:(id)alertManager toApplication:(id)app withResult:(id)result;
- (id)initWithAlertManager:(id)arg1 from:(id)arg2 to:(id)arg3 withResult:(id)arg4;
@end


@interface SBMediaController : NSObject
@property (copy) SBApplication *nowPlayingApplication;
+ (id)sharedInstance;
@end

@interface SBDisplayItem : NSObject

+(id)displayItemWithType:(NSString*)type displayIdentifier:(id)identifier;

@end

@interface FBScene : NSObject

@property(readonly, retain, nonatomic) SBWindowContextHostManager *contextHostManager;
- (id)contextHostManager;
- (id)mutableSettings;
-(void)_applyMutableSettings:(id)arg1 withTransitionContext:(id)arg2 completion:(id)arg3;
@end

@interface VeloxNotficationController

+ (VeloxNotficationController *)sharedController;
- (BOOL)displayStratosViewForBundleIdentifier:(NSString *)identifier withFrame:(CGRect)frame;

@end

@interface SBWallpaperEffectView : UIView

-(id)initWithWallpaperVariant:(int)wallpaperVariant;
-(void)setStyle:(int)style;

@end

@interface SBViewSnapshotProvider

@property(copy, nonatomic) id completionBlock;
-(UIImage *)snapshot;
-(void)snapshotAsynchronously:(BOOL)asynchronously withImageBlock:(id)imageBlock;
-(id)initWithView:(id)view;
@end

@interface SBHomeScreenPreviewView : UIView
+ (void)cleanupPreview;
+ (id)preview;
@end

@interface SBCCAirStuffSectionController : UIViewController

- (void)controlCenterWillPresent;

@end

@interface SBUIControlCenterButton : UIView
@end

@interface FBWindowContextHostManager : NSObject
- (void)enableHostingForRequester:(id)arg1 orderFront:(BOOL)arg2;
- (id)hostViewForRequester:(id)arg1 enableAndOrderFront:(BOOL)arg2;
- (void)disableHostingForRequester:(NSString *)requestor;
@end

@interface FBSMutableSceneSettings
- (void)setBackgrounded:(bool)arg1;
@end

@interface SBLaunchAppListener
- (id)initWithBundleIdentifier:(id)arg1 handlerBlock:(id)arg2;
@end