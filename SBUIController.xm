#import "Stratos.h"

static NSUserDefaults *stratosUserDefaults;
static SBControlCenterController *controlCenter;
static UIWindow *trayWindow;
static TouchHighjacker *touchView;

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
		[[SwitcherTrayView sharedInstance] closeTray];

		//reload in daemon
		[[IdentifierDaemon sharedInstance] reloadApps];

		//also reload them in the switcher tray
		[[SwitcherTrayView sharedInstance] reloadShouldForce:NO];
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

- (void)finishLaunching {

	%orig;

	//springboard has finished launching, load all the initial stuff
	//so there is no lag on the first pullup
	[[IdentifierDaemon sharedInstance] reloadApps];
	[[SwitcherTrayView sharedInstance] reloadShouldForce:YES];
	[self _showControlCenterGestureBeganWithLocation:CGPointMake(0,0)];
	[trayWindow setUserInteractionEnabled:NO];
	[touchView removeFromSuperview];

}

%end