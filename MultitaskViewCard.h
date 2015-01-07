#import "Stratos.h"

@interface MultitaskViewCard : UIView {
	UIView *_closeView;
}

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) id application;
@property (nonatomic, retain) UIView *superView;

- (id)initWithIdentifier:(NSString *)identifier;
- (void)openApp;
- (void)shouldTellSuperToKill;
- (void)setEditing:(NSNumber *)editing; //cant pass bool through makeObjectsPerformSelector?
- (void)didStopWobble;

@end