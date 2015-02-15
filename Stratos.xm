//
//  Stratos Tweak
//  Description.
//
//  Copyright (c)2014 Cortex Dev Team. All rights reserved.
//
// 

#import "Stratos.h"

static HBPreferences *stratosPrefs;

//
// Prefs Notification Handler
//
static void prefsChanged(CFNotificationCenterRef center, void *observer,
						 CFStringRef name, const void *object, CFDictionaryRef userInfo) {

	//redraw background in case settings were changed
	[[SwitcherTrayView sharedInstance] reloadBlurView];

	//update grabber
	[[SwitcherTrayView sharedInstance] refreshGrabber];

	//update tray position (cards)
	[[SwitcherTrayView sharedInstance] trayHeightDidChange];

	//reload cards if # of pages has been changed OR parallax settings have been changed
	if ([[SwitcherTrayView sharedInstance] localPageCount] != [stratosPrefs integerForKey:kCDTSPreferencesNumberOfPages] || 
		[[SwitcherTrayView sharedInstance] enableParallax] != [stratosPrefs boolForKey:kCDTSPreferencesEnableParallax]) {
		[[IdentifierDaemon sharedInstance] purgeCardCache];
		[[SwitcherTrayView sharedInstance] reloadShouldForce:YES];
	}

}

//
// Init
//
%ctor {

	@autoreleasepool {
		
		// listen for notifications from Settings
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)prefsChanged,
										(CFStringRef)[kCDTSPreferencesDomain stringByAppendingPathComponent:@"ReloadPrefs"],
										NULL,
										YES);		

	}
}

