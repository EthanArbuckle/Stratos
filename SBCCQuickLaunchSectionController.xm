#import "Stratos.h"

//
// This hooks into the quicklaunch item. If any button besides the torch
// is tapped, the switcher will be dismissed (because its opening a quicklaunch app).
//
static CDTSPreferences *prefs;

%hook SBCCQuickLaunchSectionController

- (void)buttonTapped:(id)tapped {

	%orig;

	if (prefs.isEnabled) {

		//if its x origin isnt 0, its not the flashlight and we need to close the switcher
		if ([(UIButton *)tapped frame].origin.x != 0) {

			[[SwitcherTrayView sharedInstance] closeTray];

		}

	}

}

%end

%ctor {
	prefs = [CDTSPreferences sharedInstance];
}

