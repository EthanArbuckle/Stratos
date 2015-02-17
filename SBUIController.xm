#import "Stratos.h"

//static HBPreferences *stratosPrefs;
static SBControlCenterController *controlCenter;
static UIWindow *trayWindow;
static NSMutableArray *hotCards;
static TouchHighjacker *touchView;
static int pageToOpen;
static UIImage *homeScreenImage;

//preferences
static CDTSPreferences *prefs;
static void loadPrefs() {
	[prefs loadPrefs:YES];
}
//
// This is where the magic happens
//
%hook SBUIController

- (void)_showControlCenterGestureBeganWithLocation:(CGPoint)location {

	DebugLog(@"swipe up gesture started at %f : %f", location.x, location.y);

	//if tweak is disabled, run original method
	if (!prefs.isEnabled) {
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
	touchView = [[TouchHighjacker alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - prefs.switcherHeight)];
	[trayWindow addSubview:touchView];

	//this method will check to see if the current running apps have changed, and update if need be
	[[SwitcherTrayView sharedInstance] reloadShouldForce:NO];

	[[SwitcherTrayView sharedInstance] setParentWindow:trayWindow];
	[trayWindow addSubview:[SwitcherTrayView sharedInstance]];

	//this makes everything under the traywindow not recieve our touches, but enables interaction with the switcher view.
	[trayWindow setUserInteractionEnabled:YES];

	if (prefs.thirdSplit) {
		int pageIndex;

		//get the index of the page order array we want to acceess, based on which third of the screen they access
		if (location.x < kScreenWidth/3) { // 0 - 1/3
			pageIndex = 0;
		} else if (location.x < (2*kScreenWidth)/3) { // 1/3 - 2/3
			pageIndex = 1;
		} else { //2/3 - 3/3
			pageIndex = 2;
		}
		pageToOpen = [[prefs.pageOrder objectAtIndex:pageIndex] intValue];

	} else {
		pageToOpen = prefs.defaultPage;
	}

	if (prefs.activeMediaEnabled) {

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
	if (!prefs.isEnabled) {

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
			[[SwitcherTrayView sharedInstance] setFrame:CGRectMake(0, location.y, kScreenWidth, prefs.switcherHeight)];
		}];

		//cancel gesture
		[self _suspendGestureChanged:0];

		//safety measure
		return;

	}

	//limit how high the switcher can be pulled up
	if (location.y >= kSwitcherMaxY) {

		[[SwitcherTrayView sharedInstance] setFrame:CGRectMake(0, location.y, kScreenWidth, prefs.switcherHeight)];
		[hotCards makeObjectsPerformSelector:@selector(zeroOutYOrigin)];
	}

	//in the 'panning' zone, user can swipe left/right to quicklaunch an app
	else if (location.y <= (kScreenHeight - prefs.switcherHeight) - kQuickLaunchTouchOffset && pageToOpen == 1 && prefs.enableQuickLaunch) {

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
	else if (location.y <= (kScreenHeight - switcherHeight) - 200 && [stratosUserDefaults boolForKey:kCDTSPreferencesInvokeControlCenter]) {

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
	if (!prefs.isEnabled) {

		%orig;
		return;
	}

	//dont open the switcher while multitask view is open, REDUUUUUNDANt 
	if ([[[[NSClassFromString(@"SBUIController") sharedInstance] valueForKey:@"switcherController"] valueForKey:@"_visible"] boolValue]) {
		%orig;
		return;
	}

	//see if we need to open a hot card
	if (location.y <= (kScreenHeight - prefs.switcherHeight) - kQuickLaunchTouchOffset && pageToOpen == 1 && prefs.enableQuickLaunch) {

		//make sure we have cards
		if ([hotCards count] > 0) {

			//open the card with a non-zero y origin
			for (UIView *card in hotCards) {

				if ([card frame].origin.y != 0) {

					//close the tray
					[[SwitcherTrayView sharedInstance] closeTray];
					[hotCards makeObjectsPerformSelector:@selector(zeroOutYOrigin)];

					//open the app
					[(SwitcherTrayCardView *)card openApp];

					[self _suspendGestureCancelled];

					return;
				}
			}
		}

	}

	[hotCards makeObjectsPerformSelector:@selector(zeroOutYOrigin)];

	//use velocity and height to decide whether to open it or not
	if (location.y <= kScreenHeight - (prefs.switcherHeight / 3) || velocity.y < 0) { //opening switcher

		CGFloat animationDuration = ((prefs.switcherHeight - location.y)/velocity.y < 0.4f) ? (prefs.switcherHeight - location.y)/velocity.y : 0.4f;
		DebugLog(@"Velocity: %f, time to animate: %f", velocity.y, animationDuration);
		
		//set grabber view to down arrow now that tray is open
		[(SBChevronView *)[(SBControlCenterGrabberView *)[[SwitcherTrayView sharedInstance] grabber] chevronView] setState:1 animated:YES];

		[self animateObject:[SwitcherTrayView sharedInstance] toFrame:CGRectMake(0, kSwitcherMaxY + 1, kScreenWidth, prefs.switcherHeight) withDuration:animationDuration];
		[[SwitcherTrayView sharedInstance] setIsOpen:YES];

	}
	/*
	else if (location.y <= switcherHeight + 100) {

		//opening the cc, do nothing
		controlCenter = nil;
	}
	*/
	else {

		[self animateObject:[SwitcherTrayView sharedInstance] toFrame:CGRectMake(0, kScreenHeight + prefs.switcherHeight, kScreenWidth, prefs.switcherHeight) withDuration:0.4f];
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
	
	if (prefs.isEnabled && [[SwitcherTrayView sharedInstance] isOpen]) {
		//home button pressed, dismiss the tray if open
		DebugLog(@"closing switcher tray");
		[[SwitcherTrayView sharedInstance] closeTray];
	}
	return %orig;
}

- (BOOL)handleMenuDoubleTap {
	DebugLog0;

	if (prefs.activateViaHome && ![[SwitcherTrayView sharedInstance] isOpen]) {

		[[SwitcherTrayView sharedInstance] openTray];

		return NO;
	}

	return %orig;
}

- (void)_deviceLockStateChanged:(id)changed {
	DebugLog0;

	if (prefs.isEnabled) {

		//get homescreen snapshot
		SBViewSnapshotProvider *provider = [[NSClassFromString(@"SBViewSnapshotProvider") alloc] initWithView:[NSClassFromString(@"SBHomeScreenPreviewView") preview]];
		[provider snapshotAsynchronously:YES withImageBlock:^void(id snapshot) {
			homeScreenImage = snapshot;
		}];

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
	if (prefs.isEnabled) {	

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

- (void)finishLaunching {

	%orig;

	//springboard has finished launching, load all the initial stuff
	//so there is no lag on the first pullup
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)loadPrefs,
										(CFStringRef)[kCDTSPreferencesDomain stringByAppendingPathComponent:@"ReloadPrefs"],
										NULL,
										YES);
	loadPrefs();
	[[IdentifierDaemon sharedInstance] reloadApps];
	[[SwitcherTrayView sharedInstance] reloadShouldForce:YES];
	if (prefs.isEnabled)
		[self _showControlCenterGestureBeganWithLocation:CGPointMake(0,0)];
	[trayWindow setUserInteractionEnabled:NO];
	[touchView removeFromSuperview];

}

%new
- (UIImage *)homeScreenImage {

	if (homeScreenImage)
		return homeScreenImage;
	return [[UIImage alloc] init];
}

%end

%ctor {
	prefs = [CDTSPreferences sharedInstance];
}