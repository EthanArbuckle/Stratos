#import "Stratos.h"

//
// This hooks into the quicklaunch item. If any button besides the torch
// is tapped, the switcher will be dismissed (because its opening a quicklaunch app).
//
static CDTSPreferences *prefs;

%hook SBCCQuickLaunchSectionController

- (void)buttonTapped:(id)tapped {

	%orig;

	if ([prefs isEnabled]) {

		//if its x origin isnt 0, its not the flashlight and we need to close the switcher
		if ([(UIButton *)tapped frame].origin.x != 0) {

			[[SwitcherTrayView sharedInstance] closeTray];

		}

	}

}

%end
@interface SBUIControlCenterButton : UIView @end
%hook SBUIControlCenterButton

- (void)setIsRectButton:(bool)arg1 {
    return %orig(NO);
}

- (void)setIsCircleButton:(bool)arg1 {
    return %orig(NO);
}

-(void)_setBackgroundImage:(id)arg1 naturalHeight:(CGFloat)arg2 {
	[self.layer setMasksToBounds:YES];
 	[self.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
  	return %orig([UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/clearbg.png"], arg2);
}

%end

%ctor {
	prefs = [CDTSPreferences sharedInstance];
}

