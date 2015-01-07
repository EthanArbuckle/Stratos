#import "SwitcherTrayView.h"


//make these objects global so arc doesnt release them
SBCCQuickLaunchSectionController *quicklaunch;
SBCCBrightnessSectionController *brightness;
SBCCSettingsSectionController *settings;
MPUSystemMediaControlsViewController *mediaView;

//this is subject to change
_UIBackdropView *blurView;
NSUserDefaults *stratosUserDefaults;

@implementation SwitcherTrayView

+ (id)sharedInstance {
	static dispatch_once_t p = 0;
	__strong static id _sharedObject = nil;
	 
	dispatch_once(&p, ^{
		_sharedObject = [[self alloc] initWithFrame:CGRectMake(0, kScreenHeight - kSwitcherHeight, kScreenWidth, kSwitcherHeight)];
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
		stratosUserDefaults = [[NSUserDefaults alloc] _initWithSuiteName:kCDTSPreferencesDomain container:[NSURL URLWithString:@"/var/mobile"]];

		//create the blur view
	//    if ([[UIScreen mainScreen] bounds].size.height > 568) {

			blurView = [[_UIBackdropView alloc] initWithStyle:[[stratosUserDefaults valueForKey:kCDTSPreferencesTrayBackgroundStyle] intValue]];
			[blurView setFrame:CGRectMake(0, 0, kScreenWidth, kSwitcherHeight)];
			[self addSubview:blurView];

   //     }
   //     else {

	//        [self setBackgroundColor:[UIColor colorWithRed:65/255.0 green:63/255.0 blue:63/255.0 alpha:1]];

	  //  }

		//create small view that will hold the pan gesture recognizer. This is placed at the top of the tray
		UIView *gestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
		UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
		[gestureView addGestureRecognizer:panGes];
		UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTray)];
		[gestureView addGestureRecognizer:tapGes];
		[self addSubview:gestureView];

		//create grabber view 
		SBControlCenterGrabberView *grabber = [[NSClassFromString(@"SBControlCenterGrabberView") alloc] initWithFrame:CGRectMake((kScreenWidth / 2) - 25, 0, 50, 20)];
		[grabber setUserInteractionEnabled:NO]; //let touches pass through to the gestureview
		[gestureView addSubview:grabber];

		//instantiate switcher cards array
		_switcherCards = [[NSMutableArray alloc] init];

		//create the scroll view that will hold everything
		_trayScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, kSwitcherHeight - 20)]; //create 40px buffer above and below it
		[_trayScrollView setScrollEnabled:YES];
		[_trayScrollView setPagingEnabled:YES];
		[_trayScrollView setShowsHorizontalScrollIndicator:NO];
		[self addSubview:_trayScrollView];        

		//add the media controls
		[self addMediaControls];

		//add the settings controls
		[self addSettingControls];

	}

	//resize the contentsize of the scrollview
	[self updateTrayContentSize];

	return self;
}

- (void)updateTrayContentSize {

	//get total number of running apps
	float runningAppsCount = [[[IdentifierDaemon sharedInstance] identifiers] count];

	//get number of pages the cards will take up
	int numberOfPagesForCards = ceil(runningAppsCount / 4);

	//the number of "pages" in the tray
	int numberOfPagesNotCards = 2;

	//get total width of everything
	int totalContentSize = (numberOfPagesNotCards + numberOfPagesForCards) * kScreenWidth;

	//set scroll view content size to that number
	[_trayScrollView setContentSize:CGSizeMake(totalContentSize, kSwitcherHeight - 80)];

}

- (void)addMediaControls {

	//create a media controls controller
	mediaView = [(MPUSystemMediaControlsViewController *)[NSClassFromString(@"MPUSystemMediaControlsViewController") alloc] initWithStyle:2];
	[[mediaView view] setFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, kSwitcherHeight - 25)];
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
	[[settings view] setFrame:CGRectMake(10, 10, kScreenWidth - 20, 50)];
	[_trayScrollView addSubview:[settings view]];

	//create the brightness slider
	brightness = [[NSClassFromString(@"SBCCBrightnessSectionController") alloc] init];
	[[brightness view] setFrame:CGRectMake(0, 60, kScreenWidth, 50)];
	[_trayScrollView addSubview:[brightness view]];

	//create the quicklaunch buttons
	quicklaunch = [[NSClassFromString(@"SBCCQuickLaunchSectionController") alloc] init];
	[[quicklaunch view] setFrame:CGRectMake(10, 115, kScreenWidth - 20, 50)];
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

- (void)reloadIfNecessary {

	//if our cached idents arent equal to th current running ones, we need to reload everything
	//(for some reason, this shit aint working.)
	//if yes -- wat.jpg
	// ---  gosh fine then ill fix it :)

	BOOL needsReload = NO;
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
		//start at gapspacing + screenwidth so these are on "page 2"
		int xOrigin = (kScreenWidth * 2) + kSwitcherCardSpacing;

		//every 4 cards, we are going to double the gap spacing since the apps are starting on a new page. this lets us keep a count
		int appIndex = 1;

		//fetch and store the running apps
		_localIdentifiers = [[IdentifierDaemon sharedInstance] identifiers];

		//cycle through each identifier of all the current running apps. idents are taken from the app switcher class
		for (NSString *identifier in _localIdentifiers) {

			//create the switcher card for the app
			SwitcherTrayCardView *currentApp = [[SwitcherTrayCardView alloc] initWithIdentifier:identifier];

			//add that card view to the array of cards
			[_switcherCards addObject:currentApp];

			//pass instance of this view (switchertrayview) to each card so they can call the 'closeTray' method
			[currentApp setSuperSwitcher:self];

			//add the card view to the scroll view, after adjusting the views frame
			[currentApp setFrame:CGRectMake(xOrigin, 0, kSwitcherCardWidth, kSwitcherCardHeight)];
			
			[_trayScrollView addSubview:currentApp];

			//step up the x origin to provide a gap between cards
			xOrigin += kSwitcherCardSpacing + kSwitcherCardWidth;

			//again, double the gap every 4 cards
			if ((appIndex % 4) == 0) {

				//xOrigin += kSwitcherCardSpacing;
				xOrigin = (((appIndex / 4) + 2) * kScreenWidth) + kSwitcherCardSpacing;

			}

			//step up app index
			appIndex++;

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
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {

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
	}
}

- (void)reloadBlurView {
	[blurView removeFromSuperview];
	blurView = [[_UIBackdropView alloc] initWithStyle:[[stratosUserDefaults valueForKey:kCDTSPreferencesTrayBackgroundStyle] intValue]];
	[blurView setFrame:CGRectMake(0, 0, kScreenWidth, kSwitcherHeight)];
	[self insertSubview:blurView atIndex:0];
}

@end
