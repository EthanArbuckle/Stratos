#import "SwitcherTrayView.h"


//make these objects global so arc doesnt release them
SBCCQuickLaunchSectionController *quicklaunch;
SBCCBrightnessSectionController *brightness;
SBCCSettingsSectionController *settings;
MPUSystemMediaControlsViewController *mediaView;

//this is subject to change
NSUserDefaults *_stratosUserDefaults;

@implementation SwitcherTrayView

+ (id)sharedInstance {
	static dispatch_once_t p = 0;
	__strong static id _sharedObject = nil;
	 
	dispatch_once(&p, ^{
		_sharedObject = [[self alloc] initWithFrame:CGRectMake(0, kScreenHeight - kSwitcherHeight, kScreenWidth, kScreenHeight /*just to be safe and ensure its never short */)];
	});

	return _sharedObject;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
 
		UILongPressGestureRecognizer* killAllRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(killAllApps)];
		[killAllRec setMinimumPressDuration:.3];
		[self addGestureRecognizer:killAllRec];
		
		//[self setBackgroundColor:[UIColor colorWithRed:65/255.0 green:63/255.0 blue:63/255.0 alpha:0.8]];
		[self setUserInteractionEnabled:YES];

		//create settings
		_stratosUserDefaults = [[NSUserDefaults alloc] _initWithSuiteName:kCDTSPreferencesDomain container:[NSURL URLWithString:@"/var/mobile"]];
        
        [_stratosUserDefaults registerDefaults:kCDTSPreferencesDefaults];

		//create the blur view
	//    if ([[UIScreen mainScreen] bounds].size.height > 568) {

			_blurView = [[_UIBackdropView alloc] initWithStyle:[[_stratosUserDefaults valueForKey:kCDTSPreferencesTrayBackgroundStyle] intValue]];
			[_blurView setFrame:CGRectMake(0, 0, kScreenWidth, kSwitcherHeight)];
			[self addSubview:_blurView];

   //     }
   //     else {

	//        [self setBackgroundColor:[UIColor colorWithRed:65/255.0 green:63/255.0 blue:63/255.0 alpha:1]];

	  //  }

		//create small view that will hold the pan gesture recognizer. This is placed at the top of the tray
		_gestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
		UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
		[_gestureView addGestureRecognizer:panGes];
		UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTray)];
		[_gestureView addGestureRecognizer:tapGes];
		[self addSubview:_gestureView];

		//create grabber view
		_grabber = [[NSClassFromString(@"SBControlCenterGrabberView") alloc] initWithFrame:CGRectMake(0, 0, 50, 22)];
		[_grabber setCenter:CGPointMake(kScreenWidth / 2, 12)];
		[_grabber setUserInteractionEnabled:NO]; //let touches pass through to the gestureview
		[self refreshGrabber];

		//instantiate switcher cards array
		_switcherCards = [[NSMutableArray alloc] init];

		//create the scroll view that will hold everything
		_trayScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, (kSwitcherHeight / 2) - (kSwitcherCardHeight / 2), kScreenWidth, kSwitcherHeight - 20)]; //create 40px buffer above and below it
		[_trayScrollView setScrollEnabled:YES];
		[_trayScrollView setPagingEnabled:YES];
		[_trayScrollView setShowsHorizontalScrollIndicator:NO];
		[self addSubview:_trayScrollView];        

		//save local copy of numberofpages to render so we can compare it later to know if settings have been changed
		_localPageCount = [_stratosUserDefaults integerForKey:kCDTSPreferencesNumberOfPages];

		//same idea for enabling parallax
		_enableParallax = [_stratosUserDefaults boolForKey:kCDTSPreferencesEnableParallax];

		//add the media controls
		[self addMediaControls];

		//add the settings controls
		[self addSettingControls];

	}

	//resize the contentsize of the scrollview
	[self updateTrayContentSize];

	[self trayHeightDidChange];

	return self;
}

- (void)updateTrayContentSize {

	//get total number of running apps
	float runningAppsCount = [[[IdentifierDaemon sharedInstance] identifiers] count];

	//get number of pages the cards will take up
	int numberOfPagesForCards = ceil(runningAppsCount / 4);

	//user can decide how many pages to show, 6 means all
	if (numberOfPagesForCards > [_stratosUserDefaults integerForKey:kCDTSPreferencesNumberOfPages] && [_stratosUserDefaults integerForKey:kCDTSPreferencesNumberOfPages] != 6) {

		numberOfPagesForCards = [_stratosUserDefaults integerForKey:kCDTSPreferencesNumberOfPages];
	}

	//the number of "pages" in the tray
	int numberOfPagesNotCards = 2;

	//get total width of everything
	int totalContentSize = (numberOfPagesNotCards + numberOfPagesForCards) * kScreenWidth;

	//set scroll view content size to that number
	[_trayScrollView setContentSize:CGSizeMake(totalContentSize, kSwitcherHeight - 80)];

}

- (void)addMediaControls {

	//create a media controls controller
	mediaView = [(MPUSystemMediaControlsViewController *)[NSClassFromString(@"MPUSystemMediaControlsViewController") alloc] initWithStyle:1];
	[[mediaView view] setFrame:CGRectMake([[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"mediaControls"] * kScreenWidth, 0, kScreenWidth, kSwitcherHeight - 25)];
	[_trayScrollView addSubview:[mediaView view]];

	//add tap gesture to media controls to open now playing app
	UITapGestureRecognizer *playingNow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mediaTapped)];
	[[mediaView view] addGestureRecognizer:playingNow];
}

- (void)mediaTapped {

	//get current app playing sound
	SBApplication *nowPlayingApp = ((SBMediaController *)[NSClassFromString(@"SBMediaController") sharedInstance]).nowPlayingApplication;

	//open it if it exists
	if (nowPlayingApp) {

		//close switcher first
		[self closeTray];

		//and then open the app
		[[NSClassFromString(@"SBUIController") sharedInstance] activateApplicationAnimated:nowPlayingApp];
	}
}

- (void)addSettingControls {

	//create the settings buttons
	settings = [[NSClassFromString(@"SBCCSettingsSectionController") alloc] init];
	[[settings view] setFrame:CGRectMake(([[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"controlCenter"] * kScreenWidth) + 10, 10, kScreenWidth - 20, 50)];
	[_trayScrollView addSubview:[settings view]];

	//create the brightness slider
	brightness = [[NSClassFromString(@"SBCCBrightnessSectionController") alloc] init];
	[[brightness view] setFrame:CGRectMake([[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"controlCenter"] * kScreenWidth, 60, kScreenWidth, 50)];
	[_trayScrollView addSubview:[brightness view]];

	//create the quicklaunch buttons
	quicklaunch = [[NSClassFromString(@"SBCCQuickLaunchSectionController") alloc] init];
	[[quicklaunch view] setFrame:CGRectMake(([[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"controlCenter"] * kScreenWidth) + 10, 115, kScreenWidth - 20, 50)];
	[_trayScrollView addSubview:[quicklaunch view]];

}

- (void)killAllApps {

	//only clear if we are on the cards page
	if ([_trayScrollView contentOffset].x >= kScreenWidth * 2) {

		//remove all cards from array
		[_switcherCards removeAllObjects];

		//get sbsynccontroller and kill all apps
		[(SBSyncController *)[NSClassFromString(@"SBSyncController") sharedInstance] _killApplications];

		//remove the identifiers from sbappswitchermodel
		if (IS_OS_7_OR_UNDER) {
			[[[NSClassFromString(@"SBAppSwitcherModel") sharedInstance] valueForKey:@"_recentDisplayIdentifiers"] removeAllObjects];
		}
		else { //iOS 8
			[[[NSClassFromString(@"SBAppSwitcherModel") sharedInstance] valueForKey:@"_recentDisplayLayouts"] removeAllObjects];
		}

		for (UIView *card in [_trayScrollView subviews]) {

			//only the cards
			if ([card isKindOfClass:[SwitcherTrayCardView class]]) {

				[card removeFromSuperview];
			}
		}

		//reset content sizes
		[self updateTrayContentSize];

		//move to quicklaunch
		[_trayScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
			  
	}

}

//this is called right before the tray is presented
- (void)prepareToOpen {

	//set grabber state to 0 (flat)
	[[(SBControlCenterGrabberView *)_grabber chevronView] setState:0 animated:NO];

	//get default page we need to open to
	int defaultPage = [[_stratosUserDefaults valueForKey:kCDTSPreferencesDefaultPage] intValue];

	//i think 1->Cards 2->Settings 3->Media

	//open to media controls if music is playing
	if ([_stratosUserDefaults boolForKey:kCDTSPreferencesActiveMediaEnabled]) {

		//see if music is playing
		if (((SBMediaController *)[NSClassFromString(@"SBMediaController") sharedInstance]).nowPlayingApplication) {

			//something is playing, change default page to 3 (media controls)
			defaultPage = 3;
		}
	}

	//make sure we dont open to no cards
	if (defaultPage == 1 && [[[IdentifierDaemon sharedInstance] identifiers] count] == 0) {
		defaultPage = 2;
	}

	if (defaultPage == 1) {

		//open to cards
		[_trayScrollView setContentOffset:CGPointMake([[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"switcherCards"] * kScreenWidth, 0) animated:NO];
	}
	else if (defaultPage == 2) {

		//open to quicklaunch
		[_trayScrollView setContentOffset:CGPointMake([[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"controlCenter"] * kScreenWidth, 0) animated:NO];
	}
	else {

		//open to media controls
		[_trayScrollView setContentOffset:CGPointMake([[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"mediaControls"] * kScreenWidth, 0) animated:NO];
	}

}

- (void)reloadShouldForce:(BOOL)force {

	//if our cached idents arent equal to th current running ones, we need to reload everything
	//(for some reason, this shit aint working.)
	//if yes -- wat.jpg
	// ---  gosh fine then ill fix it :)

	BOOL needsReload = force;
	NSArray *currentRunning = [[IdentifierDaemon sharedInstance] identifiers];
	
	if ([currentRunning count] != [_localIdentifiers count]) {

		needsReload = YES;
	}

	for (int index = 0; index < [_localIdentifiers count]; index++) {

		if ([currentRunning count] > index) {

			if (currentRunning[index] != _localIdentifiers[index]) {

				needsReload = YES;
			}
		}
		else {

			needsReload = YES;
		}
	}

	if (needsReload) {
NSLog(@"reloading");
		//clear stored cards
		[_switcherCards removeAllObjects];

		//remove everthing in the scrollview
		for (UIView *subview in [_trayScrollView subviews]) {

			//remove only the app cards (which respond to that method)
			if ([subview respondsToSelector:@selector(initWithIdentifier:)]) {

				[subview removeFromSuperview];

			}

		}

		//the X origin for each view will step up for each app, so keep track of it
		//start at gapspacing + starting page 
		int xOrigin = ([[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"switcherCards"] * kScreenWidth) + kSwitcherCardSpacing;

		//every 4 cards, we are going to double the gap spacing since the apps are starting on a new page. this lets us keep a count
		int appIndex = 1;

		//fetch and store the running apps
		_localIdentifiers = [[IdentifierDaemon sharedInstance] identifiers];

		//cycle through each identifier of all the current running apps. idents are taken from the app switcher class
		for (NSString *identifier in _localIdentifiers) {

			//only create first page of cards on main thread
			if ([_localIdentifiers indexOfObject:identifier] <= 3) {

				[self createCardForIdentifier:identifier atXOrigin:xOrigin onGCDThread:NO];
			}
			else {

				//not first page, lets outsource it to a different thread
				dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {

					[self createCardForIdentifier:identifier atXOrigin:xOrigin onGCDThread:YES];

				});
			}


			//step up the x origin to provide a gap between cards
			xOrigin += kSwitcherCardSpacing + kSwitcherCardWidth;

			//again, double the gap every 4 cards
			if ((appIndex % 4) == 0) {

				//xOrigin += kSwitcherCardSpacing;
				xOrigin = (((appIndex / 4) + [[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"switcherCards"]) * kScreenWidth) + kSwitcherCardSpacing;

			}

			//step up app index
			appIndex++;

			//only generate the amount the user wants to
			if (appIndex-1 >= [_stratosUserDefaults integerForKey:kCDTSPreferencesNumberOfPages]*4 && [_stratosUserDefaults integerForKey:kCDTSPreferencesNumberOfPages] != 6) {
				break;
			}

		}

	}

	//start the tray at the first of the card pages
	if ([[[IdentifierDaemon sharedInstance] identifiers] count] > 0) {

		[_trayScrollView setContentOffset:CGPointMake(kScreenWidth * 2, 0) animated:NO];
	}
	else {

		//if no apps are running, default to the quicklaunch page
		[_trayScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
	}

	[self updateTrayContentSize];

	//update setting stuff
	_localPageCount = [_stratosUserDefaults integerForKey:kCDTSPreferencesNumberOfPages];
	_enableParallax = [_stratosUserDefaults boolForKey:kCDTSPreferencesEnableParallax];
	
}

- (void)createCardForIdentifier:(NSString *)ident atXOrigin:(int)xOrigin onGCDThread:(BOOL)threading {

	//get the switcher card for the app
	SwitcherTrayCardView *currentApp = (SwitcherTrayCardView *)[[IdentifierDaemon sharedInstance] switcherCardForIdentifier:ident];

	//add that card view to the array of cards
	[_switcherCards addObject:currentApp];

	//pass instance of this view (switchertrayview) to each card so they can call the 'closeTray' method
	[currentApp setSuperSwitcher:self];

	//add the card view to the scroll view, after adjusting the views frame
	[currentApp setFrame:CGRectMake(xOrigin, 0, kSwitcherCardWidth, kSwitcherCardHeight)];
	
	//if card is being created on gcd thread, switch to main thread before adding card
	if (threading) {

		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[_trayScrollView addSubview:currentApp];
		});
	}

	else {

		//do it like normal
		[_trayScrollView addSubview:currentApp];
	}

}

- (void)handlePan:(UIPanGestureRecognizer *)pan {

	//since tray is moving, change chevron to flat line (state 0)
	[(SBChevronView *)[(SBControlCenterGrabberView *)[[SwitcherTrayView sharedInstance] grabber] chevronView] setState:0 animated:YES];

	//location of touch
	CGPoint point = [pan locationInView:_parentWindow];

	if ([pan state] == UIGestureRecognizerStateChanged) {

		//dont open the tray too far
		if (point.y >= kSwitcherMaxY) {
			[self setFrame:CGRectMake(0, point.y, kScreenWidth, kSwitcherHeight)];
		}

	}

	else if ([pan state] == UIGestureRecognizerStateEnded) {

		if (point.y > 445.0f) {

			[self closeTray];
			[_parentWindow setUserInteractionEnabled:NO];
		}

		else {

			[self openTray];

			//tray is open, change chevron to down arrow (state 1)
			[(SBChevronView *)[(SBControlCenterGrabberView *)[[SwitcherTrayView sharedInstance] grabber] chevronView] setState:1 animated:YES];
		}

	}
}

- (void)closeTray {

	[UIView animateWithDuration:0.4f animations:^{
		[self setFrame:CGRectMake(0, kScreenHeight + kSwitcherHeight, kScreenWidth, kSwitcherHeight)];
	} completion:^(BOOL finished) {

		//remove everything from tray window
		for (id subview in [_parentWindow subviews]) {

			//remove it 
			[subview removeFromSuperview];
		}

	}];

	[_parentWindow setUserInteractionEnabled:NO];

	_isOpen = NO;
}

- (void)openTray {

	//init all the window stuff by faking a gesture starting
	[(SBUIController *)[NSClassFromString(@"SBUIController") sharedInstance] _showControlCenterGestureBeganWithLocation:CGPointMake(0, 0)];

	[self animateObject:self toFrame:CGRectMake(0, kSwitcherMaxY, kScreenWidth, kSwitcherHeight)];
	_isOpen = YES;
}

- (void)animateObject:(id)view toFrame:(CGRect)frame {

	[UIView animateWithDuration:0.4f animations:^{
		[view setFrame:frame];
	}];
}

- (void)cardRequestingToClose:(UIView *)card {

	if ([_switcherCards containsObject:card]) {

		//end the card
		int pid = [(SBApplication *)[(SwitcherTrayCardView *)card application] pid];
		if (pid > 0) {

			kill(pid, SIGUSR1);
		}

		//get the position of card, used when we animate the other cards over
		int cardIndex = [_switcherCards indexOfObject:card];

		//remove the card from the array
		[_switcherCards removeObject:card];

		//remove the card from the tray
		[card removeFromSuperview];

		//remove the identifier from sbappswitchermodel. This doesnt close the app, just removes it from the tray and appswitcher
		//iOS 7 uses _recentDisplayIdentifiers, which doesnt exist on iOS 8. 
		if (IS_OS_7_OR_UNDER) {
			[[[NSClassFromString(@"SBAppSwitcherModel") sharedInstance] valueForKey:@"_recentDisplayIdentifiers"] removeObjectAtIndex:cardIndex];
		}
		else { //iOS 8
			[[[NSClassFromString(@"SBAppSwitcherModel") sharedInstance] valueForKey:@"_recentDisplayLayouts"] removeObjectAtIndex:cardIndex];
		}

		//cycle through other cards and move them over
		for (UIView *possibleCard in [_trayScrollView subviews]) {

			//make sure its a card
			if ([possibleCard isKindOfClass:[SwitcherTrayCardView class]]) {

				//only continue if index is after the card closing
				if ([_switcherCards indexOfObject:possibleCard] < cardIndex) 
					continue;

				//step up index
				cardIndex++;
				
				//get its frame
				CGRect frame = [possibleCard frame];

				//substract a cards width + gap
				frame.origin.x -= kSwitcherCardWidth + kSwitcherCardSpacing;

				//use card index to decide if it needs to remove a double spaced gap
				if ((cardIndex % 4) == 0) {

					frame.origin.x -= kSwitcherCardSpacing;
				}

				//give card its new frame
				[self animateObject:possibleCard toFrame:frame];
			}
		}

		//if user has limited amount of pages to show, lets grab the next app
		//that would normally be showing and add it, since we're going to be 1 short
		if ([_stratosUserDefaults integerForKey:kCDTSPreferencesNumberOfPages] != 6) {

			int pagesToShow = [_stratosUserDefaults integerForKey:kCDTSPreferencesNumberOfPages];

			//make sure there is even another app to show
			if ([[[IdentifierDaemon sharedInstance] identifiers] count] > (pagesToShow * 4)) {

				//get the app, index should be (pagesToShow X 4) - 1 (to account for 0 index)
				int indexOfNext = (pagesToShow * 4) - 1;
				NSString *identifier = [[[IdentifierDaemon sharedInstance] identifiers] objectAtIndex:indexOfNext];
				SwitcherTrayCardView *newApp = (SwitcherTrayCardView *)[[IdentifierDaemon sharedInstance] switcherCardForIdentifier:identifier];

				//calculate x origin for it
				int xOrigin = [[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"switcherCards"] * kScreenWidth;
				xOrigin += ((pagesToShow * 3) * kSwitcherCardWidth) + ((pagesToShow * 4) * kSwitcherCardSpacing);

				//set the new apps frame
				[newApp setFrame:CGRectMake(xOrigin, 0, kSwitcherCardWidth, kSwitcherCardHeight)];

				//add it to card array
				[_switcherCards addObject:newApp];

				//and add it to the switcher
				[_trayScrollView addSubview:newApp];

			}
		}
	}
}

- (void)reloadBlurView {
	[_blurView removeFromSuperview];
	_blurView = [[_UIBackdropView alloc] initWithStyle:[[_stratosUserDefaults valueForKey:kCDTSPreferencesTrayBackgroundStyle] intValue]];
	[_blurView setFrame:CGRectMake(0, 0, kScreenWidth, kSwitcherHeight)];
	[self insertSubview:_blurView atIndex:0];

	[_switcherCards makeObjectsPerformSelector:@selector(cardNeedsUpdating)];

}

- (void)refreshGrabber {
	
	[_grabber removeFromSuperview];

	if ([_stratosUserDefaults boolForKey:kCDTSPreferencesShowGrabber]) {
		[_gestureView addSubview:_grabber];
	}

}

- (void)trayHeightDidChange {

	//update placement of cards
	[_trayScrollView setFrame:CGRectMake(0, (kSwitcherHeight / 2) - (kSwitcherCardHeight / 2), kScreenWidth, kSwitcherHeight - 20)];

	//update order of pages (reset the frames)
	int mediaControlXOrigin = [[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"mediaControls"] * kScreenWidth;
	int controlCenterXOrigin = [[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"controlCenter"] * kScreenWidth;
	
	//if switcher cards are before this, we need to factor in the pages for the cards
	if ([[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"switcherCards"] < [[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"mediaControls"]) {
		mediaControlXOrigin = ([[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"mediaControls"] + [_stratosUserDefaults integerForKey:kCDTSPreferencesNumberOfPages]) * kScreenWidth;

		//if all pages is enabled, we need to get total pages for running apps
		if ([_stratosUserDefaults integerForKey:kCDTSPreferencesNumberOfPages] == 6) {

			//get total number of running apps
			float runningAppsCount = [[[IdentifierDaemon sharedInstance] identifiers] count];

			//get number of pages the cards will take up
			int numberOfPagesForCards = ceil(runningAppsCount / 4);

			//add it all up
			mediaControlXOrigin = ([[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"mediaControls"] + numberOfPagesForCards) * kScreenWidth;
		}

		//I dont know why this needs to be here, but fuck it it works
		mediaControlXOrigin -= kScreenWidth;
	}

	if ([[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"switcherCards"] < [[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"controlCenter"]) {
		controlCenterXOrigin = ([[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"controlCenter"] + [_stratosUserDefaults integerForKey:kCDTSPreferencesNumberOfPages]) * kScreenWidth;

		//if all pages is enabled, we need to get total pages for running apps
		if ([_stratosUserDefaults integerForKey:kCDTSPreferencesNumberOfPages] == 6) {

			//get total number of running apps
			float runningAppsCount = [[[IdentifierDaemon sharedInstance] identifiers] count];

			//get number of pages the cards will take up
			int numberOfPagesForCards = ceil(runningAppsCount / 4);

			//add it all up
			controlCenterXOrigin = ([[_stratosUserDefaults arrayForKey:kCDTSPreferencesPageOrder] indexOfObject:@"controlCenter"] + numberOfPagesForCards) * kScreenWidth;
		}

		//I dont know why this needs to be here, but fuck it it works
		controlCenterXOrigin -= kScreenWidth;
	}

	[[mediaView view] setFrame:CGRectMake(mediaControlXOrigin, 0, kScreenWidth, kSwitcherHeight - 25)];
	[[settings view] setFrame:CGRectMake(controlCenterXOrigin + 10, 0, kScreenWidth - 20, 50)];
	[[brightness view] setFrame:CGRectMake(controlCenterXOrigin, 50, kScreenWidth, 50)];
	[[quicklaunch view] setFrame:CGRectMake(controlCenterXOrigin + 10, 103, kScreenWidth - 20, 65)];

} 

@end
