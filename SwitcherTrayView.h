#import "Stratos.h"

@interface SwitcherTrayView : UIView

@property (nonatomic, retain) UIWindow *parentWindow;
@property (nonatomic, retain) UIScrollView *trayScrollView;
@property (nonatomic, retain) NSMutableArray *switcherCards;
@property (nonatomic, retain) NSArray *localIdentifiers;
@property (nonatomic) BOOL isOpen;

+ (id)sharedInstance;
- (void)updateTrayContentSize;
- (void)addMediaControls;
- (void)mediaTapped;
- (void)addSettingControls;
- (void)killAllApps;
- (void)reloadIfNecessary;
- (void)createCardForIdentifier:(NSString *)ident atXOrigin:(int)xOrigin;
- (void)handlePan:(UIPanGestureRecognizer *)pan;
- (void)closeTray;
- (void)openTray;
- (void)animateObject:(id)view toFrame:(CGRect)frame;
- (void)cardRequestingToClose:(UIView *)card;
- (void)reloadBlurView;

@end