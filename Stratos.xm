//
//  Stratos Tweak
//  Description.
//
//  Copyright (c)2014 Cortex Dev Team. All rights reserved.
//
// 

#import "Stratos.h"

#define PREFS_PLIST_PATH	[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.cortexdevteam.stratos.plist"]

//
// set user defaults up
//
static inline void loadPrefs() {

	//make sure the settings get created
	[kStratosUserDefaults synchronize];
}

//
// Prefs Notification Handler
//
static void prefsChanged(CFNotificationCenterRef center, void *observer,
						 CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	
    [kStratosUserDefaults synchronize];

	//redraw background in case settings were changed
	[[SwitcherTrayView sharedInstance] reloadBlurView];

	//update grabber
	[[SwitcherTrayView sharedInstance] refreshGrabber];

	//update tray position (cards)
	[[SwitcherTrayView sharedInstance] trayHeightDidChange];

	//reload cards if # of pages has been changed OR parallax settings have been changed
	//if ([[SwitcherTrayView sharedInstance] localPageCount] != [kStratosUserDefaults integerForKey:kCDTSPreferencesNumberOfPages] || 
	//	[[SwitcherTrayView sharedInstance] enableParallax] != [kStratosUserDefaults boolForKey:kCDTSPreferencesEnableParallax]) {
		[[IdentifierDaemon sharedInstance] purgeCardCache];
		[[SwitcherTrayView sharedInstance] reloadShouldForce:YES];
//	}

}

//
// Init
//
%ctor {

	@autoreleasepool {

		loadPrefs();
		
		// listen for notifications from Settings
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)prefsChanged,
										CFSTR("com.cortexdevteam.stratos.prefs-changed"),
										NULL,
										CFNotificationSuspensionBehaviorDeliverImmediately);		

	}
}

