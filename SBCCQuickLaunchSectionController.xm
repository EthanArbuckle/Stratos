#import "Stratos.h"

//
// This hooks into the quicklaunch item. If any button besides the torch
// is tapped, the switcher will be dismissed (because its opening a quicklaunch app).
//
%hook SBCCQuickLaunchSectionController

- (void)buttonTapped:(id)tapped {
	
	%orig;

	if ([kStratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {

		//if its x origin isnt 0, its not the flashlight and we need to close the switcher
		if ([(UIButton *)tapped frame].origin.x != 0) {

			[[SwitcherTrayView sharedInstance] closeTray];

		}

	}

}

%end
/*
%hook UIVisualEffectView

- (id)contentView {
	id ori = %orig;

	if ([[self superview] isKindOfClass:NSClassFromString(@"SBControlCenterButton")])
		[self removeFromSuperview];
	NSLog(@"hhh\n\n%@", [self valueForKey:@"_effect"]);
	return ori;
}

%end */