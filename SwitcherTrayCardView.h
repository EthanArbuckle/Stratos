#import "Stratos.h"

@interface SwitcherTrayCardView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) UIView *superSwitcher;
@property (nonatomic, retain) id application;
@property (nonatomic, retain) UIImageView *snapshotHolder;

- (id)initWithIdentifier:(NSString *)identifier;
- (void)openApp;
- (void)panning:(UIPanGestureRecognizer *)pan;
- (void)cardNeedsUpdating;

@end