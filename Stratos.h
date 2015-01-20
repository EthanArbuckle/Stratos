#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "SwitcherTrayView.h"
#import "SwitcherTrayCardView.h"
#import "IdentifierDaemon.h"
#import "MultitaskView.h"
#import "MultitaskViewCard.h"
#import "TouchHighjacker.h"


// helpers
#define l(args...) 				NSLog(@"[Stratos] %@", args);

#define DEBUG_PREFIX 			@"😈 [Stratos]"
#import "DebugLog.h"

#define YES_OR_NO				@"Yes":@"No"
#define IS_OS_8_OR_LATER [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0
#define IS_OS_7_OR_UNDER [[[UIDevice currentDevice] systemVersion] floatValue] <= 7.0


// layout
#define kScreenHeight 			[[UIScreen mainScreen] bounds].size.height
#define kScreenWidth 			[[UIScreen mainScreen] bounds].size.width

#define kiPhoneSmall 			[[UIScreen mainScreen] bounds].size.height < 568

#define kSwitcherHeight 		[[(SBUIController *)NSClassFromString(@"SBUIController") stratosUserDefaults] floatForKey:kCDTSPreferencesSwitcherHeight]//kScreenHeight / 3.3 //172
#define kSwitcherMaxY 			kScreenHeight - kSwitcherHeight
#define kSwitcherCardWidth 		kScreenWidth / 4.5714 //70
#define kSwitcherCardHeight 	        kScreenHeight / 4.36 //130
#define kSwitcherCardSpacing	        ceil((kScreenWidth - (kSwitcherCardWidth * 4)) / 5) //8

#define kMultiViewCardWidth 	80
#define kMultiViewCardHeight 	150
#define kMultiViewCardSpacing 	20

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
static NSDictionary *const kCDTSPreferencesDefaults = @{
                                                        kCDTSPreferencesEnabledKey          : @NO,
                                                        kCDTSPreferencesTrayBackgroundStyle : @1,
                                                        @"switcherHeight"                   : @(kScreenHeight / 3.3),
                                                        kCDTSPreferencesShowGrabber         : @YES,
                                                        kCDTSPreferencesEnableParallax      : @YES,
                                                        kCDTSPreferencesInvokeControlCenter : @YES,
                                                        kCDTSPreferencesShowRunningApp      : @NO,
                                                        @"defaultPage"                      : @1,
                                                        kCDTSPreferencesActivateByDoubleHome: @NO,
                                                        @"pageOrder"                        : @[ @"controlCenter", @"mediaControls", @"switcherCards" ], //in order from left to right
                                                        @"numberOfPages"                    : @6 //number of pages for multitasking card view
                                                        };

// private interfaces
@interface SBUIController : NSObject
+(id)sharedInstance;
- (id)valueForKey:(id)arg1;
- (void)_suspendGestureBegan;
- (void)_suspendGestureChanged:(CGFloat)arg1;
- (void)animateObject:(id)view toFrame:(CGRect)frame;
- (void)activateApplicationAnimated:(id)application;
- (void)getRidOfAppSwitcher;
- (void)_installSystemGestureView:(UIView *)gestureView forKey:(id<NSCopying>)key forGesture:(NSUInteger)gestureType;
- (void)notifyAppResignActive:(id)active;
- (void)restoreContentAndUnscatterIconsAnimated:(BOOL)animated;
- (void)_clearInstalledSystemGestureViewForKey:(id<NSCopying>)key;
- (void)_showControlCenterGestureBeganWithLocation:(CGPoint)location;
- (void)_showControlCenterGestureEndedWithLocation:(CGPoint)location velocity:(CGPoint)velocity;
- (void)stopRestoringIconList;
- (void)tearDownIconListAndBar;
- (void)notifyAppResumeActive:(id)app;
- (NSUserDefaults *)stratosUserDefaults;
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
- (instancetype)initWithWorkspace:(id)workspace alertManager:(id)alertManager from:(SBApplication *)fromApp to:(SBApplication *)toApp activationHandler:(id)activationHandler;
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

@end

@interface NSUserDefaults (Private)

- (instancetype)_initWithSuiteName:(NSString *)suiteName container:(NSURL *)container;

@end

@interface VeloxNotficationController

+ (VeloxNotficationController *)sharedController;
- (BOOL)displayStratosViewForBundleIdentifier:(NSString *)identifier withFrame:(CGRect)frame;

@end