#import "Stratos.h"

//
// This is for the app switching animations. All apps will animate side to side opening, instead of the weird
// springboard zooming effect.
//
static HBPreferences *stratosPrefs;
static BOOL isEnabled;

%hook SBAppToAppWorkspaceTransaction

- (id)_setupAnimationFrom:(SBApplication *)senderApp to:(SBApplication *)dest {

	if (!isEnabled) {
		return %orig;
	}
	
	//get running app idents
	NSArray *runningApps = [[IdentifierDaemon sharedInstance] identifiers];
	
	//get id of opening app
	NSString *toApp = [dest valueForKey:@"_bundleIdentifier"];

	//find the index of it
	if ([runningApps containsObject:toApp] && [[SwitcherTrayView sharedInstance] isOpen]) {
		int index = [runningApps indexOfObject:toApp];
		
		//make sure its not the first app
		if (index > 0) {
			//get ident of app right before it
			NSString *beforeApp = [runningApps objectAtIndex:index + 1];

			//get instance of sbapplication of before app
			id beforeSBApp = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:beforeApp];
			
			//call original method with new args
			DebugLog(@"Forcing side to side app transition animation");
			return %orig(beforeSBApp, dest);
		}
	}

	return %orig;
	
}

%end

static void loadPrefs() {
	isEnabled = [stratosPrefs boolForKey:kCDTSPreferencesEnabledKey];
}

%ctor {
	stratosPrefs = [[HBPreferences alloc] initWithIdentifier:kCDTSPreferencesDomain];
	[stratosPrefs registerDefaults:kCDTSPreferencesDefaults];
	loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)loadPrefs,
										(CFStringRef)[kCDTSPreferencesDomain stringByAppendingPathComponent:@"ReloadPrefs"],
										NULL,
										YES);
}
