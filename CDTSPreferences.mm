#import "CDTSPreferences.h"
//CDTSPreferences *prefs;
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

-(BOOL)getBoolForKey:(NSString *)key dictionary:(NSDictionary *)dictionary {
	NSNumber *tempVal = (NSNumber *)[dictionary objectForKey:key];
	return tempVal ? [tempVal boolValue] : [kCDTSPreferencesDefaults[key] boolValue];
}

-(NSInteger)getIntegerForKey:(NSString *)key dictionary:(NSDictionary *)dictionary {
	NSNumber *tempVal = (NSNumber *)[dictionary objectForKey:key];
	return tempVal ? [tempVal intValue] : [kCDTSPreferencesDefaults[key] intValue];
}

-(CGFloat)getFloatForKey:(NSString *)key dictionary:(NSDictionary *)dictionary {
	NSNumber *tempVal = (NSNumber *)[dictionary objectForKey:key];
	return tempVal ? [tempVal floatValue] : [kCDTSPreferencesDefaults[key] floatValue];	
}

-(id)getObjectForKey:(NSString *)key dictionary:(NSDictionary *)dictionary {
	id obj = [dictionary objectForKey:key];
	return obj ?: kCDTSPreferencesDefaults[key];
}

-(void)loadPrefs:(BOOL)fromNotification {

	NSDictionary *prefsDict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];

	self.isEnabled = [self getBoolForKey:kCDTSPreferencesEnabledKey dictionary:prefsDict];

	self.showGrabber = [self getBoolForKey:kCDTSPreferencesShowGrabber dictionary:prefsDict];

	self.shouldInvokeCC = [self getBoolForKey:kCDTSPreferencesInvokeControlCenter dictionary:prefsDict];

	self.showRunningApp = [self getBoolForKey:kCDTSPreferencesShowRunningApp dictionary:prefsDict];
	
	self.activateViaHome = [self getBoolForKey:kCDTSPreferencesActivateByDoubleHome dictionary:prefsDict];

	self.activeMediaEnabled = [self getBoolForKey:kCDTSPreferencesActiveMediaEnabled dictionary:prefsDict];

	self.thirdSplit = [self getBoolForKey:kCDTSPreferencesThirdSplit dictionary:prefsDict];

	self.enableQuickLaunch = [self getBoolForKey:kCDTSPreferencesEnableQuickLaunch dictionary:prefsDict];

	self.enableHomescreen = [self getBoolForKey:kCDTSPreferencesEnableHomescreen dictionary:prefsDict];

	self.enableParallax = [self getBoolForKey:kCDTSPreferencesEnableParallax dictionary:prefsDict];

	self.swipeToClose = [self getBoolForKey:kCDTSPreferencesSwipeToClose dictionary:prefsDict];

	self.switcherBackgroundStyle = [self getIntegerForKey:kCDTSPreferencesTrayBackgroundStyle dictionary:prefsDict];

	self.defaultPage = [self getIntegerForKey:kCDTSPreferencesDefaultPage dictionary:prefsDict];

	self.numberOfPages = [self getIntegerForKey:kCDTSPreferencesNumberOfPages dictionary:prefsDict];

	self.switcherHeight = [self getFloatForKey:kCDTSPreferencesSwitcherHeight dictionary:prefsDict];

	self.swipeToCloseWidth = [self getFloatForKey:kCDTSPreferencesSwipeToCloseWidth dictionary:prefsDict];

	self.pageOrder = (NSArray *)[self getObjectForKey:kCDTSPreferencesPageOrder dictionary:prefsDict];
	
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

	//if ([[SwitcherTrayView sharedInstance] localPageCount] != self.numberOfPages || 
	//[[SwitcherTrayView sharedInstance] enableParallax] != self.enableParallax) {
		[[IdentifierDaemon sharedInstance] purgeCardCache];
		[[SwitcherTrayView sharedInstance] reloadShouldForce:YES];
//	}
	//update homescreen card
	[[NSClassFromString(@"SBUIController") sharedInstance] updateHomescreenImage];
}

@end
/*
static void loadPrefs() {
	[prefs loadPrefs:YES];
}

__attribute__((constructor)) static void init() {
	
}
*/