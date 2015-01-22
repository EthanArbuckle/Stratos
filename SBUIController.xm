#import "Stratos.h"

static NSUserDefaults *stratosUserDefaults;
static SBApplication *topMostApp;
static SBControlCenterController *controlCenter;
static id mainWorkspace;
static UIView *gestureView;
static UIWindow *trayWindow;
static TouchHighjacker *touchView;
static BOOL isSwipeToCloseEnabled = NO;
//
// This is where the magic happens
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
	[SwitcherTrayView sharedInstance];

	//this method will check to see if the current running apps have changed, and update if need be
	[[SwitcherTrayView sharedInstance] reloadShouldForce:NO];

	[[SwitcherTrayView sharedInstance] setParentWindow:trayWindow];
	[trayWindow addSubview:[SwitcherTrayView sharedInstance]];

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

	//let the tray know its funna get opened
	[[SwitcherTrayView sharedInstance] prepareToOpen];

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

	//since tray is moving, change chevron to flat line (state 0)
	[(SBChevronView *)[(SBControlCenterGrabberView *)[[SwitcherTrayView sharedInstance] grabber] chevronView] setState:0 animated:YES];

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

	//user swiped fast as fuck, pop this hoe open super fast
	if (duration <= 0.03) {

		//animate it
		[UIView animateWithDuration:0.1f animations:^{
			[[SwitcherTrayView sharedInstance] setFrame:CGRectMake(0, location.y, kScreenWidth, kSwitcherHeight)];
		}];

		//cancel gesture
		[self _suspendGestureChanged:0];

		//safety measure
		return;

	}

	//limit how high the switcher can be pulled up
	if (location.y >= kSwitcherMaxY) {

		[[SwitcherTrayView sharedInstance] setFrame:CGRectMake(0, location.y, kScreenWidth, kSwitcherHeight)];
	}

	else if (location.y <= kSwitcherHeight + 100 && [stratosUserDefaults boolForKey:kCDTSPreferencesInvokeControlCenter]) {

		//hide switcher
		[[SwitcherTrayView sharedInstance] closeTray];

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
	if (location.y <= kScreenHeight - (kSwitcherHeight / 2)) { //opening switcher
		
		//set grabber view to down arrow now that tray is open
		[(SBChevronView *)[(SBControlCenterGrabberView *)[[SwitcherTrayView sharedInstance] grabber] chevronView] setState:1 animated:YES];

		[self animateObject:[SwitcherTrayView sharedInstance] toFrame:CGRectMake(0, kSwitcherMaxY + 1, kScreenWidth, kSwitcherHeight)];
		[[SwitcherTrayView sharedInstance] setIsOpen:YES];

	}
	else if (location.y <= kSwitcherHeight + 100) {

		//opening the cc, do nothing
		controlCenter = nil;
	}

	else {

		[self animateObject:[SwitcherTrayView sharedInstance] toFrame:CGRectMake(0, kScreenHeight + kSwitcherHeight, kScreenWidth, kSwitcherHeight)];
		[trayWindow setUserInteractionEnabled:NO];
		[touchView removeFromSuperview];
	}
}

%new
- (void)animateObject:(id)view toFrame:(CGRect)frame {

	[UIView animateWithDuration:0.4f animations:^{
		[view setFrame:frame];
	}];
}

- (BOOL)clickedMenuButton {
	DebugLog0;
	
	if ([stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey] && [[SwitcherTrayView sharedInstance] isOpen]) {
		//home button pressed, dismiss the tray if open
		DebugLog(@"closing switcher tray");
		[[SwitcherTrayView sharedInstance] closeTray];
	}
	return %orig;
}

- (BOOL)handleMenuDoubleTap {
	DebugLog0;

	if ([stratosUserDefaults boolForKey:kCDTSPreferencesActivateByDoubleHome] && ![[SwitcherTrayView sharedInstance] isOpen]) {

		[[SwitcherTrayView sharedInstance] openTray];

		return NO;
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

		//also reload them in the switcher tray
		[[SwitcherTrayView sharedInstance] reloadShouldForce:NO];
	}
}

%new
+ (NSUserDefaults *)stratosUserDefaults {

	if (!stratosUserDefaults) {

		//create user default instance
		stratosUserDefaults = [[NSUserDefaults alloc] _initWithSuiteName:kCDTSPreferencesDomain container:[NSURL URLWithString:@"/var/mobile"]];

		//set default values
		[stratosUserDefaults registerDefaults:kCDTSPreferencesDefaults];

		[stratosUserDefaults synchronize];

	}

	return stratosUserDefaults;
}

%end