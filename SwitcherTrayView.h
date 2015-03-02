#import "Stratos.h"
#import <QuartzCore/QuartzCore.h>

@interface SwitcherTrayView : UIView

@property (nonatomic, retain) UIWindow *parentWindow;
@property (nonatomic, retain) UIScrollView *trayScrollView;
@property (nonatomic, retain) NSMutableArray *switcherCards;
@property (nonatomic, retain) NSArray *localIdentifiers;
@property (nonatomic, retain) UIView *gestureView;
@property (nonatomic, retain) UIView *grabber;
@property (nonatomic, retain) UIView *blurView;
@property (nonatomic, retain) UIView *killAllContainer;
@property (nonatomic) BOOL isOpen;

//these are for checking if certain settings have been changes
@property (nonatomic) int localPageCount;
@property (nonatomic) BOOL enableParallax;

+ (id)sharedInstance;
- (void)updateTrayContentSize;
- (void)addMediaControls;
- (void)mediaTapped;
- (void)addSettingControls;
- (void)killAllApps:(UILongPressGestureRecognizer *)gesture;
- (void)prepareToOpenWithDefaultPage:(int)defaultPage;
- (void)reloadShouldForce:(BOOL)force;
- (void)createCardForIdentifier:(NSString *)ident atXOrigin:(int)xOrigin;
- (void)handlePan:(UIPanGestureRecognizer *)pan;
- (void)closeTray;
- (void)openTray;
- (void)animateObject:(id)view toFrame:(CGRect)frame;
- (void)cardRequestingToClose:(UIView *)card;
- (void)reloadBlurView;
- (void)refreshGrabber;
- (void)trayHeightDidChange;
- (void)cancelKillAll:(UIButton *)sender;
- (void)quitAllApps:(UIButton *)sender;

@end