#import "Stratos.h"

//
// This hooks into the quicklaunch item. If any button besides the torch
// is tapped, the switcher will be dismissed (because its opening a quicklaunch app).
//
static HBPreferences *stratosPrefs;
static BOOL isEnabled;

%hook SBCCQuickLaunchSectionController

- (void)buttonTapped:(id)tapped {
	
	%orig;

	if (isEnabled) {

		//if its x origin isnt 0, its not the flashlight and we need to close the switcher
		if ([(UIButton *)tapped frame].origin.x != 0) {

			[[SwitcherTrayView sharedInstance] closeTray];

		}

	}

}

%end

static void loadPrefs() {
	syncPrefs;
	boolPreference(kCDTSPreferencesEnabledKey, isEnabled);
	//isEnabled = [stratosPrefs boolForKey:kCDTSPreferencesEnabledKey];
}

%ctor {
	//stratosPrefs = [[HBPreferences alloc] initWithIdentifier:kCDTSPreferencesDomain];
	//[stratosPrefs registerDefaults:kCDTSPreferencesDefaults];
	loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)loadPrefs,
										(CFStringRef)[kCDTSPreferencesDomain stringByAppendingPathComponent:@"ReloadPrefs"],
										NULL,
										YES);
}