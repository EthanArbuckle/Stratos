#import "Stratos.h"
@interface CDTSPreferences : NSObject

+(id)sharedInstance;
-(void)loadPrefs:(BOOL)fromNotification;

@property(nonatomic) BOOL isEnabled;
@property(nonatomic) BOOL showGrabber;
@property(nonatomic) BOOL shouldInvokeCC;
@property(nonatomic) BOOL showRunningApp;
@property(nonatomic) BOOL activateViaHome;
@property(nonatomic) BOOL activeMediaEnabled;
@property(nonatomic) BOOL thirdSplit;
@property(nonatomic) BOOL enableQuickLaunch;
@property(nonatomic) BOOL enableHomescreen;
@property(nonatomic) BOOL enableParallax;
@property(nonatomic) BOOL swipeToClose;
@property(nonatomic) NSInteger closeRegionIndex;
@property(nonatomic) NSInteger switcherBackgroundStyle;
@property(nonatomic) NSInteger defaultPage;
@property(nonatomic) NSInteger numberOfPages;
@property(nonatomic) CGFloat switcherHeight;
@property(nonatomic) CGFloat swipeToCloseWidth;
@property(nonatomic, retain) NSArray *pageOrder;
@end