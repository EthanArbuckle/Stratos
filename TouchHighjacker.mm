//Stratos - Cortex Dev Team
//ethan arbuckle

#import "TouchHighjacker.h"

TouchHighjacker *hijacker;

static void loadPrefs() {
	floatPreference(kCDTSPreferencesSwitcherHeight, hijacker.switcherHeight);
	//hijacker.switcherHeight = [hijacker.stratosPrefs floatForKey:kCDTSPreferencesSwitcherHeight];
}

@implementation TouchHighjacker
@synthesize switcherHeight;

- (id)initWithFrame:(CGRect)frame {

	if (self = [super initWithFrame:frame]) {

		[self setUserInteractionEnabled:NO];

		//works for some reason, dont question jesus
		[self setBackgroundColor:[UIColor blueColor]];
		[self setAlpha:.01];
		hijacker = self;
		//_stratosPrefs = [[NSUserDefaults alloc] _initWithSuiteName:kCDTSPreferencesDomain container:[NSURL URLWithString:@"/var/mobile"]];
		//[_stratosPrefs registerDefaults:kCDTSPreferencesDefaults];
		loadPrefs();
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)loadPrefs,
										(CFStringRef)[kCDTSPreferencesDomain stringByAppendingPathComponent:@"ReloadPrefs"],
										NULL,
										YES);
		//[_stratosPrefs registerFloat:&switcherHeight default:[[kCDTSPreferencesDefaults objectForKey:kCDTSPreferencesSwitcherHeight] floatValue] forKey:kCDTSPreferencesSwitcherHeight];
	}

	return self;
}

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

	if ([[SwitcherTrayView sharedInstance] isOpen] && point.y <= kScreenHeight - switcherHeight) {
		[[SwitcherTrayView sharedInstance] closeTray];
		[self removeFromSuperview];
	}

	return nil;
}

@end