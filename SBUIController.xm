#import "Stratos.h"

static NSUserDefaults *stratosUserDefaults;
static SBControlCenterController *controlCenter;
static UIWindow *trayWindow;
static NSMutableArray *hotCards;
static TouchHighjacker *touchView;
static int pageToOpen;

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

	//Dismiss the tray when tapped outside of it
	touchView = [[TouchHighjacker alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kSwitcherHeight)];
	[trayWindow addSubview:touchView];

	//this method will check to see if the current running apps have changed, and update if need be
	[[SwitcherTrayView sharedInstance] reloadShouldForce:NO];

	[[SwitcherTrayView sharedInstance] setParentWindow:trayWindow];
	[trayWindow addSubview:[SwitcherTrayView sharedInstance]];

	//this makes everything under the traywindow not recieve our touches, but enables interaction with the switcher view.
	[trayWindow setUserInteractionEnabled:YES];

	if ([stratosUserDefaults boolForKey:kCDTSPreferencesThirdSplit]) {
		int pageIndex;
		NSString *pageName;

		//get the index of the page order array we want to acceess, based on which third of the screen they access
		if (location.x < kScreenWidth/3) { // 0 - 1/3
			pageIndex = 0;
		} else if (location.x < (2*kScreenWidth)/3) { // 1/3 - 2/3
			pageIndex = 1;
		} else { //2/3 - 3/3
			pageIndex = 2;
		}
		pageName = [[stratosUserDefaults stringArrayForKey:kCDTSPreferencesPageOrder] objectAtIndex:pageIndex];

		//get pageToOpen
		//1=switcher, 2=toggles, 3=music
		if ([pageName isEqualToString:@"switcherCards"])
			pageToOpen = 1;
		else if ([pageName isEqualToString:@"controlCenter"])
			pageToOpen = 2;
		else //pageName is @"mediaControls"
			pageToOpen = 3;
	} else {
		pageToOpen = [[stratosUserDefaults valueForKey:kCDTSPreferencesDefaultPage] intValue];
	}

	if ([stratosUserDefaults boolForKey:kCDTSPreferencesActiveMediaEnabled]) {

		//see if music is playing
		if (((SBMediaController *)[NSClassFromString(@"SBMediaController") sharedInstance]).nowPlayingApplication) {

			//something is playing, change default page to 3 (media controls)
			pageToOpen = 3;  
		}
	}
	//let the tray know its funna get opened
	[[SwitcherTrayView sharedInstance] prepareToOpenWithDefaultPage:pageToOpen];

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
		[hotCards makeObjectsPerformSelector:@selector(zeroOutYOrigin)];
	}

	//in the 'panning' zone, user can swipe left/right to quicklaunch an app
	else if (location.y <= (kScreenHeight - kSwitcherHeight) - kQuickLaunchTouchOffset && pageToOpen == 1 && [stratosUserDefaults boolForKey:kCDTSPreferencesEnableQuickLaunch]) {

		//only continue if we have at least 4 cards in the switcher
		if ([[[SwitcherTrayView sharedInstance] switcherCards] count] > 3) {

			/*if (location.x >= kScreenWidth - 4) {
				int currentPage = [[[SwitcherTrayView sharedInstance] trayScrollView] contentOffset] / kScreenWidth;
				//int switcherStartPage = [stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"switcherCards"] + 1;
				if (currentPage > switcherStartPage) {

				}

			} */

			//the card our finger is over
			int selectedIndex = ceil(location.x / (kSwitcherCardWidth + kSwitcherCardSpacing)) - 1;

			//make sure its first 4
			if (selectedIndex > 3) {
				selectedIndex = 3;
			}

			//get hot cards
			hotCards = [[NSMutableArray alloc] initWithCapacity:4];
			for (int index = 0; index <= 3; index++)
				[hotCards addObject:[[[SwitcherTrayView sharedInstance] switcherCards] objectAtIndex:index]];

			//lift the current card and reset all others
			for (UIView *card in hotCards) {

				//get index of card
				int cardIndex = [hotCards indexOfObject:card];

				//get frame of card
				CGRect frame = [card frame];

				//reset frame if it isnt selected one
				if (cardIndex != selectedIndex) {

					frame.origin.y = 0;
				}

				else {

					frame.origin.y = -50;
				}

				//set the new frame
				[self animateObject:card toFrame:frame withDuration:0.2f];

			}
		}

	}
	/*
	else if (location.y <= (kScreenHeight - kSwitcherHeight) - 200 && [stratosUserDefaults boolForKey:kCDTSPreferencesInvokeControlCenter]) {

		[hotCards makeObjectsPerformSelector:@selector(zeroOutYOrigin)];
		[self removeHotArea];

		//hide switcher
		[[SwitcherTrayView sharedInstance] closeTray];

		//cancel gesture
		[self _showControlCenterGestureEndedWithLocation:CGPointMake(0, 0) velocity:CGPointMake(0, 0)];
		[self _suspendGestureChanged:0];

		if (!controlCenter) {

			//create the control center if its not already instantiated
			controlCenter = [NSClassFromString(@"SBControlCenterController") _sharedInstanceCreatingIfNeeded:YES];
		}

		//open the control center
		[controlCenter presentAnimated:YES];
		[[controlCenter _window] setWindowLevel:UIWindowLevelAlert]; 

	}
	*/
	else {

		[hotCards makeObjectsPerformSelector:@selector(zeroOutYOrigin)];
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

	//see if we need to open a hot card
	if (location.y <= (kScreenHeight - kSwitcherHeight) - kQuickLaunchTouchOffset && pageToOpen == 1 && [stratosUserDefaults boolForKey:kCDTSPreferencesEnableQuickLaunch]) {

		//make sure we have cards
		if ([hotCards count] > 0) {

			//open the card with a non-zero y origin
			for (UIView *card in hotCards) {

				if ([card frame].origin.y != 0) {

					//close the tray
					[[SwitcherTrayView sharedInstance] closeTray];
					[hotCards makeObjectsPerformSelector:@selector(zeroOutYOrigin)];

					//open the app
					[[NSClassFromString(@"SBUIController") sharedInstance] activateApplicationAnimated:[[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:[(SwitcherTrayCardView *)card identifier]]];

					[self _suspendGestureCancelled];

					return;
				}
			}
		}

	}

	[hotCards makeObjectsPerformSelector:@selector(zeroOutYOrigin)];

	//use velocity and height to decide whether to open it or not
	if (location.y <= kScreenHeight - (kSwitcherHeight / 3) || velocity.y < 0) { //opening switcher

		CGFloat animationDuration = ((kSwitcherHeight - location.y)/velocity.y < 0.4f) ? (kSwitcherHeight - location.y)/velocity.y : 0.4f;
		DebugLog(@"Velocity: %f, time to animate: %f", velocity.y, animationDuration);
		
		//set grabber view to down arrow now that tray is open
		[(SBChevronView *)[(SBControlCenterGrabberView *)[[SwitcherTrayView sharedInstance] grabber] chevronView] setState:1 animated:YES];

		[self animateObject:[SwitcherTrayView sharedInstance] toFrame:CGRectMake(0, kSwitcherMaxY + 1, kScreenWidth, kSwitcherHeight) withDuration:animationDuration];
		[[SwitcherTrayView sharedInstance] setIsOpen:YES];

	}
	/*
	else if (location.y <= kSwitcherHeight + 100) {

		//opening the cc, do nothing
		controlCenter = nil;
	}
	*/
	else {

		[self animateObject:[SwitcherTrayView sharedInstance] toFrame:CGRectMake(0, kScreenHeight + kSwitcherHeight, kScreenWidth, kSwitcherHeight) withDuration:0.4f];
		[[SwitcherTrayView sharedInstance] setIsOpen:NO];
		[trayWindow setUserInteractionEnabled:NO];
		[touchView removeFromSuperview];
	}
}

%new
- (void)animateObject:(id)view toFrame:(CGRect)frame withDuration:(CGFloat)duration {

	[UIView animateWithDuration:duration animations:^{
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

		double delayInSeconds = 1.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

			//an app was opened, closed, or killed. tell the identifier daemon to reload.
			[[IdentifierDaemon sharedInstance] reloadApps];

			//also reload them in the switcher tray
			[[SwitcherTrayView sharedInstance] reloadShouldForce:NO];

		});
		
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