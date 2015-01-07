//Stratos - Cortex Dev Team
//ethan arbuckle

#import "TouchHighjacker.h"

@implementation TouchHighjacker

- (id)initWithFrame:(CGRect)frame {

	if (self = [super initWithFrame:frame]) {

		[self setUserInteractionEnabled:NO];

		//works for some reason, dont question jesus
		[self setBackgroundColor:[UIColor blueColor]];
		[self setAlpha:.01];
	}

	return self;
}

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

	if ([[SwitcherTrayView sharedInstance] isOpen] && point.y <= kScreenHeight - kSwitcherHeight) {
		[[SwitcherTrayView sharedInstance] closeTray];
		[self removeFromSuperview];
	}

	return nil;
}

@end