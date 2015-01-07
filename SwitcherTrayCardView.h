#import "Stratos.h"

@interface SwitcherTrayCardView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) UIView *superSwitcher;
@property (nonatomic, retain) id application;

- (id)initWithIdentifier:(NSString *)identifier;
- (void)openApp;
- (void)panning:(UIPanGestureRecognizer *)pan;

@end