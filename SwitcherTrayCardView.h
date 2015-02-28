#import "Stratos.h"

@interface SwitcherTrayCardView : UIView <UIGestureRecognizerDelegate, UIAlertViewDelegate> {
}

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) UIView *superSwitcher;
@property (nonatomic, retain) id application;
@property (nonatomic, retain) UIImageView *snapshotHolder;
@property (nonatomic, retain) UILabel *appName;
@property (nonatomic, retain) UIImageView *iconHolder;
@property (nonatomic) CGFloat offset;

- (id)initWithIdentifier:(NSString *)identifier;
- (void)openApp;
- (void)panning:(UIPanGestureRecognizer *)pan;
- (void)cardNeedsUpdating;
- (void)zeroOutYOrigin;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(int)buttonIndex;

@end