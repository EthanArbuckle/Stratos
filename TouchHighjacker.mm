//Stratos - Cortex Dev Team
//ethan arbuckle

#import "TouchHighjacker.h"
static CDTSPreferences *prefs;

@implementation TouchHighjacker

- (id)initWithFrame:(CGRect)frame {

	if (self = [super initWithFrame:frame]) {
		prefs = [CDTSPreferences sharedInstance];
		[self setUserInteractionEnabled:NO];

		//works for some reason, dont question jesus
		[self setBackgroundColor:[UIColor blueColor]];
		[self setAlpha:.01];
		//_stratosPrefs = [[NSUserDefaults alloc] _initWithSuiteName:kCDTSPreferencesDomain container:[NSURL URLWithString:@"/var/mobile"]];
		//[_stratosPrefs registerDefaults:kCDTSPreferencesDefaults];
		//[_stratosPrefs registerFloat:&switcherHeight default:[[kCDTSPreferencesDefaults objectForKey:kCDTSPreferencesSwitcherHeight] floatValue] forKey:kCDTSPreferencesSwitcherHeight];
	}

	return self;
}

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

	if ([[SwitcherTrayView sharedInstance] isOpen] && point.y <= kScreenHeight - [prefs switcherHeight]) {
		[[SwitcherTrayView sharedInstance] closeTray];
		[self removeFromSuperview];
	}

	return nil;
}

@end