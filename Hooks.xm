//
//  Stratos Tweak
//  Description.
//
//  Copyright (c)2014 Cortex Dev Team. All rights reserved.
//
// 

#import "Stratos.h"

#define PREFS_PLIST_PATH	[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.cortexdevteam.stratos.plist"]

static SBApplication *topMostApp;
static SBControlCenterController *controlCenter;
static id mainWorkspace;
static UIView *gestureView;
static UIWindow *trayWindow;
static TouchHighjacker *touchView;

static SwitcherTrayView *switcher;

static NSUserDefaults *stratosUserDefaults;

static BOOL isSwipeToCloseEnabled;


//
// set user defaults up
//
static inline void loadPrefs() {

	//create user default instance
	stratosUserDefaults = [[NSUserDefaults alloc] _initWithSuiteName:kCDTSPreferencesDomain container:[NSURL URLWithString:@"/var/mobile"]];

	//set default values
	[stratosUserDefaults registerDefaults:@{
		kCDTSPreferencesEnabledKey: @"YES",
		kCDTSPreferencesTrayBackgroundStyle : @1
	}];

	[stratosUserDefaults synchronize];

}

//
// Prefs Notification Handler
//
static void prefsChanged(CFNotificationCenterRef center, void *observer,
						 CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	
	DebugLogC(@"** Preferences Changed Notification **");

    [stratosUserDefaults synchronize];

	//redraw background in case settings were changed
	[switcher reloadBlurView];

	//update grabber
	[switcher refreshGrabber];

}


//iOS 8 compat stuff
%group iOS8

//iOS 8 no longer has applicationWithDisplayIdentifier, so create this method and
//return the bundlIdent method instead
%hook SBApplicationController

%new
- (id)applicationWithDisplayIdentifier:(NSString *)ident {
	
	if (self) {

		DebugLog(@"iOS 8 device, adding displayIdentifier method");
		return [self applicationWithBundleIdentifier:ident];
	}

	return nil;
}

%end

//iOS 8 no longer uses -displayIdent, so replace it with bundleIdent
%hook SBApplication

%new
- (id)displayIdentifier {
	DebugLog(@"iOS 8 device, adding displayIdentifier method");
	return [self bundleIdentifier];
}

%end

%end

//END IOS 8 COMPAT

// Hooks -----------------------------------------------------------------------

%group main

//
// Does stuff.
//
%hook SBUIController

- (void)_showControlCenterGestureBeganWithLocation:(CGPoint)location {

	DebugLog(@"swipe up gesture started at %f : %f", location.x, location.y);

	//if tweak is disabled, run original method
	if (![stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {
		%orig;
		return;
	}

	//dont open the switcher while multitask view is open, REDUUUUUNDANt 
	if ([[[[NSClassFromString(@"SBUIController") sharedInstance] valueForKey:@"switcherController"] valueForKey:@"_visible"] boolValue]) {
		DebugLog(@"Appswitcher is open, dont show tray");
		%orig;
		return;
	}
	
	//this is the 'base'. The UIWindow is able to add itself to anything on the screen, SpringBoard or app
	if (!trayWindow) {
		trayWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
		[trayWindow setWindowLevel:9999];
	}

	[trayWindow makeKeyAndVisible];

	//create the background view. This is what everything will be added to
	switcher = [SwitcherTrayView sharedInstance];

	//this method will check to see if the current running apps have changed, and update if need be
	[switcher reloadIfNecessary];

	[switcher setParentWindow:trayWindow];
	[trayWindow addSubview:switcher];

	//this makes everything under the traywindow not recieve our touches, but enables interaction with the switcher view.
	[trayWindow setUserInteractionEnabled:YES];

	//Dismiss the tray when tapped outside of it
	touchView = [[TouchHighjacker alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kSwitcherHeight)];
	[trayWindow addSubview:touchView];

	//detect the touches to setup the closing gesture
	if (location.x <= 30 && isSwipeToCloseEnabled) {

		//sbapplication instance of open app
		topMostApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];

		//make sure its open or exists
		if (topMostApp == nil) {

			return;
		}

		//create gesture view
		gestureView = [[NSClassFromString(@"SBGestureViewVendor") sharedInstance] viewForApp:topMostApp gestureType:1 includeStatusBar:YES];

		//shadows (TAKEN FROM MultitaskingGestures)
		[gestureView.layer setShadowOpacity:0.8];
        [gestureView.layer setShadowRadius:5];
        [gestureView.layer setShadowOffset:CGSizeMake(0, 10)];
        [gestureView.layer setShadowPath:[[UIBezierPath bezierPathWithRect:gestureView.bounds] CGPath]];

        //add gesture to springboard
        [[NSClassFromString(@"SBUIController") sharedInstance] _installSystemGestureView:gestureView forKey:topMostApp.displayIdentifier forGesture:1];

        //notify app. notifyAppResignActive ios iOS 7 only
        if ([[NSClassFromString(@"SBUIController") sharedInstance] respondsToSelector:@selector(notifyAppResignActive:)]) {
        	[[NSClassFromString(@"SBUIController") sharedInstance] notifyAppResignActive:topMostApp];
        }
        else { //iOS 8
 			//get topmost app
			SBApplication *frontApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
			[frontApp notifyResignActiveForReason:1];
        }

        [[NSClassFromString(@"SBWallpaperController") sharedInstance] beginRequiringWithReason:@"CloseAppGesture"];

        //restore homescreen
        [[NSClassFromString(@"SBUIController") sharedInstance] restoreContentAndUnscatterIconsAnimated:NO];
	}

	//dont actually show the controlcenter
	[self _suspendGestureBegan];

}

- (void)_showControlCenterGestureChangedWithLocation:(CGPoint)location velocity:(CGPoint)velocity duration:(double)duration {

	//if tweak is disabled, run original method
	if (![stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {

		%orig;
		return;
	}

	//dont open the switcher while multitask view is open, REDUUUUUNDANt 
	if ([[[[NSClassFromString(@"SBUIController") sharedInstance] valueForKey:@"switcherController"] valueForKey:@"_visible"] boolValue]) {
		%orig;
		return;
	}

	//detect touches for closing gesture
	if (location.x <= 30 || [gestureView frame].origin.y != 0) {

		//only if we have a top app and gesture view
		if (topMostApp && gestureView && isSwipeToCloseEnabled) {

			CGRect gestureFrame = [gestureView frame];
			gestureFrame.origin.y = location.y - [[UIScreen mainScreen] bounds].size.height;

			//iOS 8 has a diff way, but use the same frame anyways
			if (IS_OS_7_OR_UNDER) {
				[gestureView setFrame:gestureFrame];
			}
			else { //iOS 8
				[(UIView *)[[(FBScene *)[topMostApp mainScene] contextHostManager] valueForKey:@"_hostView"] setFrame:gestureFrame];
			}

		}

		return;
	}

	//limit how high the switcher can be pulled up
	if (location.y >= kSwitcherMaxY) {
		[switcher setFrame:CGRectMake(0, location.y, kScreenWidth, kSwitcherHeight)];
	}

	else if (location.y <= kSwitcherHeight + 100 && [stratosUserDefaults boolForKey:kCDTSPreferencesInvokeControlCenter]) {

		//hide switcher
		[switcher closeTray];

		//cancel gesture
		[self _suspendGestureChanged:0];

		if (!controlCenter) {

			//create the control center if its not already instantiated
			controlCenter = [NSClassFromString(@"SBControlCenterController") _sharedInstanceCreatingIfNeeded:YES];
		}

		//open the control center
		[controlCenter presentAnimated:YES];
		[[controlCenter _window] setWindowLevel:UIWindowLevelAlert]; 

	}
}

- (void)_showControlCenterGestureEndedWithLocation:(CGPoint)location velocity:(CGPoint)velocity {

	DebugLog(@"swipe gesture ended");

	//if tweak is disabled, run original method
	if (![stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {

		%orig;
		return;
	}

	//dont open the switcher while multitask view is open, REDUUUUUNDANt 
	if ([[[[NSClassFromString(@"SBUIController") sharedInstance] valueForKey:@"switcherController"] valueForKey:@"_visible"] boolValue]) {
		%orig;
		return;
	}
	
	//touches most likely to do with closing gesture
	if (location.x <= 30 || [gestureView frame].origin.y != 0) {

		//check for app or we get a blank springboard
		if (topMostApp && isSwipeToCloseEnabled) {

			[[SwitcherTrayView sharedInstance] closeTray];
			[UIView animateWithDuration:.3 animations:^{
	            
	        	CGRect gestureViewFrame = gestureView.frame;
	           	gestureViewFrame.origin.y = (location.y <= 350 && velocity.y<0 ? -[[UIScreen mainScreen]bounds].size.height : 0);
	            [gestureView setFrame:gestureViewFrame];

	        } completion:nil];	

			//mainScreenContextHostManager is iOS 7 only
			if ([topMostApp respondsToSelector:@selector(mainScreenContextHostManager)]) {
				[(SBWindowContextHostManager *)topMostApp.mainScreenContextHostManager disableHostingForRequester:@"LaunchSuspend"];
			}
			else { //iOS 8
				[[(SBWindowContextHostManager *)(FBScene *)[topMostApp mainScene] valueForKey:@"_contextHostManager"] disableHostingForRequester:@"LaunchSuspend"];
			}
			
			//[[NSClassFromString(@"SBUIController") sharedInstance] _clearInstalledSystemGestureViewForKey:topMostApp.bundleIdentifier];

			//close app 
			if (location.y <= 350 && velocity.y<0) {

				//close to springboard. iOS 7 uses SB, iOS 8 is FB (frontboard) 
				if (IS_OS_7_OR_UNDER) {
					SBWorkspaceEvent *event = [NSClassFromString(@"SBWorkspaceEvent") eventWithLabel:@"ActivateSpringBoard" handler:^{
		            	SBApplication *frontApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
		            	[frontApp setDeactivationSetting:20 flag:YES];
		            	[frontApp setDeactivationSetting:2 flag:NO];
		            	SBAppToAppWorkspaceTransaction *transaction = [[NSClassFromString(@"SBAppToAppWorkspaceTransaction") alloc] initWithWorkspace:((SBWorkspace *)mainWorkspace).bksWorkspace alertManager:nil from:frontApp to:nil activationHandler:nil];
		                [mainWorkspace setCurrentTransaction:transaction];

		            }];

		            [[NSClassFromString(@"SBWorkspaceEventQueue") sharedInstance] executeOrAppendEvent:event];
				}
				else {//iOS 8 (FrontBoard) 

					FBWorkspaceEvent *event = [NSClassFromString(@"FBWorkspaceEvent") eventWithName:@"ActivateSpringBoard" handler:^{
		            	SBApplication *frontApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
		            	SBDeactivationSettings *deactiveSets = [[NSClassFromString(@"SBDeactivationSettings") alloc] init];
		            	[deactiveSets setFlag:YES forDeactivationSetting:20];
		            	[deactiveSets setFlag:NO forDeactivationSetting:2];
		            	[frontApp _setDeactivationSettings:deactiveSets];
		            	SBAppToAppWorkspaceTransaction *transaction = [[NSClassFromString(@"SBAppToAppWorkspaceTransaction") alloc] initWithAlertManager:nil exitedApp:frontApp];
		                [transaction begin];

		            }];

		            [(FBWorkspaceEventQueue *)[NSClassFromString(@"FBWorkspaceEventQueue") sharedInstance] executeOrAppendEvent:event];
				}

	            

			}
			else { //open app

				//resume app. notifyAppResumeActive is iOS 7 only
				if ([[NSClassFromString(@"SBUIController") sharedInstance] respondsToSelector:@selector(notifyAppResumeActive:)]) {
					[[NSClassFromString(@"SBUIController") sharedInstance] notifyAppResumeActive:topMostApp];
				}
				else { //iOS 8
					//get topmost app
					SBApplication *frontApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];

					// create a transaction to open the application, which also activates it
					SBAppToAppWorkspaceTransaction *transaction = [[NSClassFromString(@"SBAppToAppWorkspaceTransaction") alloc] initWithAlertManager:nil toApplication:frontApp withResult:nil];
					[transaction begin];
				}

	            [[NSClassFromString(@"SBUIController") sharedInstance] stopRestoringIconList];
	            [[NSClassFromString(@"SBUIController") sharedInstance] tearDownIconListAndBar];
			}
			
			[trayWindow setUserInteractionEnabled:NO];

			return;
		}
	}

	//if the switcher is over halfway open when released, fully open it. otherwise dismiss it
	if (location.y > 445.0f) {
		[self animateObject:switcher toFrame:CGRectMake(0, kScreenHeight + kSwitcherHeight, kScreenWidth, kSwitcherHeight)];
		[trayWindow setUserInteractionEnabled:NO];
		[touchView removeFromSuperview];
	}
	else if (location.y <= kSwitcherHeight + 100) {

		//opening the cc, do nothing
		controlCenter = nil;
	}

	else {

		[self animateObject:switcher toFrame:CGRectMake(0, kSwitcherMaxY, kScreenWidth, kSwitcherHeight)];
		[switcher setIsOpen:YES];
	}
}

%new
- (void)animateObject:(id)view toFrame:(CGRect)frame {

	[UIView animateWithDuration:0.4f animations:^{
		[view setFrame:frame];
	}];
}

%end



//
// This hook is used to listen for home or lock button presses, and
// dismiss the switcher when they are pressed
//
%hook SBUIController
- (BOOL)clickedMenuButton {
	DebugLog0;
	
	if ([stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {
		//home button pressed, dismiss the tray if open
		DebugLog(@"closing switcher tray");
		[[SwitcherTrayView sharedInstance] closeTray];
	}
	return %orig;
}
- (BOOL)handleMenuDoubleTap {
	DebugLog0;
	
	if ([stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {
		//home button double tapped, dismiss the tray
		DebugLog(@"closing switcher tray");
		[[SwitcherTrayView sharedInstance] closeTray];
	}
	return %orig;
}
- (void)_deviceLockStateChanged:(id)changed {
	DebugLog0;
	
	if ([stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {
		//lock button pressed, dismiss the tray
		DebugLog(@"closing switcher tray");
		[[SwitcherTrayView sharedInstance] closeTray];
	}
	%orig;
}
- (void)_applicationActivationStateDidChange:(id)_applicationActivationState {
	%orig;
	if ([stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {
		//an app was opened, closed, or killed. tell the identifier daemon to reload.
		[[IdentifierDaemon sharedInstance] reloadApps];
	}
}

%new
+ (NSUserDefaults *)stratosUserDefaults {

	return stratosUserDefaults;
}

%end



//
// This hooks into the quicklaunch item. If any button besides the torch
// is tapped, the switcher will be dismissed (because its opening a quicklaunch app).
//
%hook SBCCQuickLaunchSectionController
- (void)buttonTapped:(id)tapped {
	%orig;

	if ([stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {
		//if its x origin isnt 0, its not the flashlight and we need to close the switcher
		if ([(UIButton *)tapped frame].origin.x != 0) {
			[[SwitcherTrayView sharedInstance] closeTray];
		}
	}
}
%end



//
// This is for the app switching animations. All apps will animate side to side opening, instead of the weird
// springboard zooming effect.
//
%hook SBAppToAppWorkspaceTransaction
- (id)_setupAnimationFrom:(SBApplication *)senderApp to:(SBApplication *)dest {
	if (![stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {
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


//
// Does something on iOS 7
//
%hook SBWorkspace
- (id)init {
    self = %orig;
    mainWorkspace = self;
    return self;
}
%end


%end //group:main



/*

//This is all the multiview stuff
%hook SBAppSliderController

- (id)init {

	//get return switcher
	SBAppSliderController *slider = %orig;

	//remove everything on it
	for (UIView *sub in [[slider view] subviews]) {

		[sub removeFromSuperview];
	}

	//return the modified controller
	return slider;
}

- (void)switcherWasPresented:(_Bool)arg1 {

	multiView = [[MultitaskView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
	[[self view] addSubview:multiView];

	//animate in
	//[UIView animateWithDuration:2 animations:^{

		[multiView setBackgroundColor:[UIColor colorWithRed:204/255.0f green:0/255.0f blue:153/255.0f alpha:0.4]];

	//}];

	[multiView setAlpha:0.5];
	multiView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
	[UIView animateWithDuration:0.25 animations:^{
		[multiView setAlpha:1.0];
		multiView.transform = CGAffineTransformIdentity;
	}];

	%orig;

}

- (void)forceDismissAnimated:(_Bool)arg1{
	[UIView animateWithDuration:0.25 animations:^{
		[multiView setAlpha:0.0];
		multiView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
	} completion:^(BOOL completed){
		//for some reason, the status bar wont come back, so force it to show
		[(SBAppStatusBarManager *)[NSClassFromString(@"SBAppStatusBarManager") sharedInstance] showStatusBar];

		//supa fast way to make switcher go away
		[(SBUIController *)[NSClassFromString(@"SBUIController") sharedInstance] getRidOfAppSwitcher];
		%orig(NO);
	}];
}

%end

*/



//
// Init
//
%ctor {
	@autoreleasepool {
		loadPrefs();
		
		if ([stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {
			NSLog(@"⚛ Stratos is enabled.");
		} else {
			NSLog(@"⚛ Stratos is disabled.");
		}
		
		//do that hacky iOS 8 stuff
		if (IS_OS_8_OR_LATER) {
			%init(iOS8);
		}

		// start hooks
		%init(main);
		
		// listen for notifications from Settings
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)prefsChanged,
										CFSTR("com.cortexdevteam.stratos.prefs-changed"),
										NULL,
										CFNotificationSuspensionBehaviorDeliverImmediately);
	}
}

