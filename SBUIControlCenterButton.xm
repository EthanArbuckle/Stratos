#import "Stratos.h"

//This makes the control center and quicklaunch toggles transparent

%hook SBUIControlCenterButton

- (void)setIsRectButton:(bool)arg1 {
    return %orig(NO);
}

- (void)setIsCircleButton:(bool)arg1 {
    return %orig(NO);
}

-(void)_setBackgroundImage:(id)arg1 naturalHeight:(CGFloat)arg2 {
	[[self layer] setMasksToBounds:YES];
 	[[self layer] setBackgroundColor:[[UIColor clearColor] CGColor]];
  	return %orig([UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/clearbg.png"], arg2);
}

%end