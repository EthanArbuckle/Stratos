#import "CDTSPreferences.h"
CDTSPreferences *prefs;
@implementation CDTSPreferences

+(id)sharedInstance {
	static dispatch_once_t p = 0;
	__strong static id _sharedObject = nil;
	 
	dispatch_once(&p, ^{
		_sharedObject = [[self alloc] init];
	});

	return _sharedObject;
}

-(id)init {
	self = [super init];
	if (self) {
		[self loadPrefs:NO];
	}
	return self;
}

-(BOOL)getBoolForKey:(NSString *)key {
	NSNumber *tempVal = (NSNumber *)CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)(key), (CFStringRef)kCDTSPreferencesDomain));
	return tempVal ? [tempVal boolValue] : [kCDTSPreferencesDefaults[key] boolValue];
}

-(NSInteger)getIntegerForKey:(NSString *)key {
	NSNumber *tempVal = (NSNumber *)CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)(key), (CFStringRef)kCDTSPreferencesDomain));
	return tempVal ? [tempVal intValue] : [kCDTSPreferencesDefaults[key] intValue];
}

-(CGFloat)getFloatForKey:(NSString *)key {
	NSNumber *tempVal = (NSNumber *)CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)(key), (CFStringRef)kCDTSPreferencesDomain));
	return tempVal ? [tempVal floatValue] : [kCDTSPreferencesDefaults[key] floatValue];	
}

-(id)getObjectForKey:(NSString *)key {
	id obj = (id)CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)(key), (CFStringRef)kCDTSPreferencesDomain));
	return obj ?: kCDTSPreferencesDefaults[key];
}

-(void)loadPrefs:(BOOL)fromNotification {

	CFPreferencesAppSynchronize((CFStringRef)kCDTSPreferencesDomain);

	self.isEnabled = [self getBoolForKey:kCDTSPreferencesEnabledKey];

	self.showGrabber = [self getBoolForKey:kCDTSPreferencesShowGrabber];

	self.shouldInvokeCC = [self getBoolForKey:kCDTSPreferencesInvokeControlCenter];

	self.showRunningApp = [self getBoolForKey:kCDTSPreferencesShowRunningApp];
	
	self.activateViaHome = [self getBoolForKey:kCDTSPreferencesActivateByDoubleHome];

	self.activeMediaEnabled = [self getBoolForKey:kCDTSPreferencesActiveMediaEnabled];

	self.thirdSplit = [self getBoolForKey:kCDTSPreferencesThirdSplit];

	self.enableQuickLaunch = [self getBoolForKey:kCDTSPreferencesEnableQuickLaunch];

	self.enableHomescreen = [self getBoolForKey:kCDTSPreferencesEnableHomescreen];

	self.enableParallax = [self getBoolForKey:kCDTSPreferencesEnableParallax];

	self.switcherBackgroundStyle = [self getIntegerForKey:kCDTSPreferencesTrayBackgroundStyle];

	self.defaultPage = [self getIntegerForKey:kCDTSPreferencesDefaultPage];

	self.numberOfPages = [self getIntegerForKey:kCDTSPreferencesNumberOfPages];

	self.switcherHeight = [self getFloatForKey:kCDTSPreferencesSwitcherHeight];

	self.pageOrder = (NSArray *)[self getObjectForKey:kCDTSPreferencesPageOrder];
	
	if (fromNotification) {
		[self reloadStuff];
	}
	
}

-(void)reloadStuff {
	//redraw background in case settings were changed
	[[SwitcherTrayView sharedInstance] reloadBlurView];

	//update grabber
	[[SwitcherTrayView sharedInstance] refreshGrabber];

	//update tray position (cards)
	[[SwitcherTrayView sharedInstance] trayHeightDidChange];

	if ([[SwitcherTrayView sharedInstance] localPageCount] != self.numberOfPages || 
	[[SwitcherTrayView sharedInstance] enableParallax] != self.enableParallax) {
		[[IdentifierDaemon sharedInstance] purgeCardCache];
		[[SwitcherTrayView sharedInstance] reloadShouldForce:YES];
	}
}

@end

static void loadPrefs() {
	[prefs loadPrefs:YES];
}

__attribute__((constructor)) static void init() {
	prefs = [CDTSPreferences sharedInstance];
	//loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)loadPrefs,
										(CFStringRef)[kCDTSPreferencesDomain stringByAppendingPathComponent:@"ReloadPrefs"],
										NULL,
										YES);
}