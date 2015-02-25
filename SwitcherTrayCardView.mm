#import "SwitcherTrayCardView.h"

static CDTSPreferences *prefs;

@implementation SwitcherTrayCardView

- (id)initWithIdentifier:(NSString *)identifier {

	if (self = [super init]) {

		prefs = [CDTSPreferences sharedInstance];

		_identifier = identifier;

		//create the imageview that will hold the preview image of the app
		_snapshotHolder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSwitcherCardWidth, kSwitcherCardHeight)];
		[_snapshotHolder setContentMode:UIViewContentModeScaleAspectFit];

		//create imageview that will hold the apps icon
		UIImageView *iconHolder = [[UIImageView alloc] initWithFrame:CGRectMake((kSwitcherCardWidth / 2) - 20, kSwitcherCardHeight - 30, 40, 40)];
		
		[self addSubview:_snapshotHolder];

		//get instance of the application
		_application = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:identifier];

		//create an icon for the application
		__block SBApplicationIcon *icon;

		//lets not deadlock if created on gcd thread
		dispatch_async(dispatch_get_main_queue(), ^{

			if ([_identifier isEqualToString:@"com.apple.mobilecal"]) {
				icon = [[NSClassFromString(@"SBCalendarApplicationIcon") alloc] initWithApplication:_application];
			}

			else if ([_identifier isEqualToString:@"com.apple.mobiletimer"]) {
				icon = [[NSClassFromString(@"SBClockApplicationIcon") alloc] initWithApplication:_application];
			}

			else {
				icon = [[NSClassFromString(@"SBApplicationIcon") alloc] initWithApplication:_application];
			}
			
		});

		//add shadow to the view
		[[iconHolder layer] setShadowColor:[UIColor blackColor].CGColor];
		[[iconHolder layer] setShadowOffset:CGSizeMake(0, 2)];
		[[iconHolder layer] setShadowOpacity:.2];
		[[iconHolder layer] setShadowRadius:8.0];
		[[iconHolder layer] setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:iconHolder.bounds cornerRadius:4.0] CGPath]];
		[iconHolder setClipsToBounds:NO];

		//let touches pass through to the card
		[iconHolder setUserInteractionEnabled:NO];

		//add it to the card
		dispatch_async(dispatch_get_main_queue(), ^{
			[self addSubview:iconHolder];

			//set iconholders image to the image from the sbapplicationicon class
			[iconHolder setImage:[icon generateIconImage:2]];

		});

		dispatch_async(dispatch_get_main_queue(), ^{

			//get the image from our ident daemon
			if ([identifier isEqualToString:@"com.apple.SpringBoard"]) {

				[_snapshotHolder setImage:[(SBUIController *)[NSClassFromString(@"SBUIController") sharedInstance] homeScreenImage]];
				[iconHolder removeFromSuperview];
				[_appName removeFromSuperview];
			}

			else {

				[_snapshotHolder setImage:[[IdentifierDaemon sharedInstance] appSnapshotForIdentifier:_identifier]];
			}

		});

		//create the label that displays the name of the app
		_appName = [[UILabel alloc] initWithFrame:CGRectMake(0, kSwitcherCardHeight + 8, kSwitcherCardWidth, 20)];


		dispatch_async(dispatch_get_main_queue(), ^{
			[_appName setText:[(SBApplication *)_application displayName]];
			[_appName setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
			[_appName setTextAlignment:NSTextAlignmentCenter];
			if (prefs.switcherBackgroundStyle == 2060 || prefs.switcherBackgroundStyle == 2010) {
				[_appName setTextColor:[UIColor darkGrayColor]];
			} else {
				[_appName setTextColor:[UIColor whiteColor]];
			}
			[self addSubview:_appName];

		});

		//add tap recognizer so we can open the app when this card is touched
		UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openApp)];
		[tapGes setCancelsTouchesInView:YES];
		[self addGestureRecognizer:tapGes];

		//create pangesture recognizer so the cards can be flicked up
		UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panning:)];
		[self addGestureRecognizer:panGes];
		[panGes setDelegate:self];


		//add parallax effect to card
		if (prefs.enableParallax) {

			UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
			verticalMotionEffect.minimumRelativeValue = @(-15);
			verticalMotionEffect.maximumRelativeValue = @(15);

			// Set horizontal effect 
			UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
			horizontalMotionEffect.minimumRelativeValue = @(-15);
			horizontalMotionEffect.maximumRelativeValue = @(15);

			// Create group to combine both
			UIMotionEffectGroup *group = [UIMotionEffectGroup new];
			group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];

			// Add both effects to your view
			[self addMotionEffect:group];
		}

	}

	return self;

}

- (void)openApp {

	//only continue if our y origin is 0, meaning we arent being panned
	if ([self frame].origin.y != 0) {

		return;
	}

	//sim home button press if this is the homescreen card
	if ([_identifier isEqualToString:@"com.apple.SpringBoard"]) {

		[(SBUIController *)[NSClassFromString(@"SBUIController") sharedInstance] clickedMenuButton];
		[(SwitcherTrayView *)_superSwitcher closeTray];

		//dont need to do fancy animations
		return;
	}
/*
	//calculate x origin
	int index = [[(SwitcherTrayView *)_superSwitcher switcherCards] indexOfObject:self] % 4;
	float x = kSwitcherCardSpacing;
	x += (kSwitcherCardWidth * index) + (kSwitcherCardSpacing * index); 

	//calculate y origin
	float y = [_superSwitcher convertPoint:[(SwitcherTrayView *)_superSwitcher trayScrollView].frame.origin toView:[(SwitcherTrayView *)_superSwitcher parentWindow]].y;

	UIImageView *appOpenAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, kSwitcherCardWidth, kSwitcherCardHeight)];
	[appOpenAnimation setImage:[_snapshotHolder image]];
	[_superSwitcher.superview addSubview:appOpenAnimation];
	SBApplication *app = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:_identifier];
	[UIView animateWithDuration:0.2f animations:^{

		[appOpenAnimation setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
		[[NSClassFromString(@"SBUIController") sharedInstance] activateApplicationAnimated:app];

	} completion:^(BOOL completed){

		//close the switcher
		if (_superSwitcher) {

			[(SwitcherTrayView *)_superSwitcher closeTray];
			[appOpenAnimation removeFromSuperview];
		
		}

	}];	
*/
	SBApplication *app = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:_identifier];
	[[NSClassFromString(@"SBUIController") sharedInstance] activateApplicationAnimated:app];

	//close the switcher
	if (_superSwitcher) {

		[(SwitcherTrayView *)_superSwitcher closeTray];
		
	}

}

- (void)panning:(UIPanGestureRecognizer *)pan {

	//get location of touch in switcher tray
	CGPoint point = [pan locationInView:_superSwitcher];

	if ([pan state] == UIGestureRecognizerStateBegan) {

		//disable scrolling of tray so gestures dont get mixed up
		[[(SwitcherTrayView *)_superSwitcher trayScrollView].panGestureRecognizer setEnabled:NO];
	}

	if ([pan state] == UIGestureRecognizerStateChanged) {
		
		//make sure we arent just trying to scroll
		CGPoint velocity = [pan velocityInView:_superSwitcher];
		CGPoint offset = [self center].y - [pan locationInView:self].y;
		if (velocity.y > 20 || velocity.y < -20) {

			//move this card with the touches. Using center point makes it flow with the finger better
			[self setCenter:CGPointMake([self center].x, point.y)];
		}
	}

	if ([pan state] == UIGestureRecognizerStateEnded) {

		//reenable switchers pan gesture
		[[(SwitcherTrayView *)_superSwitcher trayScrollView].panGestureRecognizer setEnabled:YES];

		//decide if card is pushed up enough to close
		if (point.y <= 30.0f) {

			[UIView animateWithDuration:0.4f animations:^{

				//animate this card out
				CGRect frame = [self frame];
				frame.origin.y = -500;
				[self setFrame:frame];

			} completion:^(BOOL completed) {

				//tell the switcher to close this app or trigger respring prompt
				if (![_identifier isEqualToString:@"com.apple.SpringBoard"]) { 
					//opening normal card
					[(SwitcherTrayView *)_superSwitcher cardRequestingToClose:self];
				}
				else {
					//homescreen card
					[(SwitcherTrayView *)_superSwitcher closeTray];

					UIAlertView *respring = [[UIAlertView alloc] initWithTitle:@"Respring" message:@"Would you like to respring your device now?" delegate:self
																 cancelButtonTitle:@"No" otherButtonTitles:@"Respring", nil];
					[respring show];
				}

			}];

		}
		else {

			if (point.y >= 180.0) {

				//open velox view! WOOT WOOT 

				//actually lets check if its installed first
				if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/Application Support/Velox/" isDirectory:nil]) {

					DebugLog(@"Activating Velox view with frame %@", NSStringFromCGRect([(SwitcherTrayView *)_superSwitcher frame]));

					//FUCK YEAH! WOOT WOOT BITCH
					[[objc_getClass("VeloxNotificationController") sharedController] displayStratosViewForBundleIdentifier:_identifier withFrame:[(SwitcherTrayView *)_superSwitcher frame]];

				}
				
			}

			//animate this card back to the normal spot
			[UIView animateWithDuration:.08f animations:^{

				//animate this card out
				CGRect frame = [self frame];
				frame.origin.y = 0;
				[self setFrame:frame];

			}];

		}
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
	return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {

	//card isnt as y0, assume its being swiped
	if ([self frame].origin.y != 0) {
		return NO;
	}

	if ([panGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
		CGPoint velocity = [panGestureRecognizer velocityInView:_superSwitcher];
		return (fabs(velocity.y) > fabs(velocity.x) || [[panGestureRecognizer view] isKindOfClass:[UIScrollView class]]);
	}

	return YES;
}

- (void)cardNeedsUpdating {
	
	//get the image from our ident daemon
	if ([_identifier isEqualToString:@"com.apple.SpringBoard"]) {

		[_snapshotHolder setImage:[(SBUIController *)[NSClassFromString(@"SBUIController") sharedInstance] homeScreenImage]];
	}
	else {

		[_snapshotHolder setImage:[[IdentifierDaemon sharedInstance] appSnapshotForIdentifier:_identifier]];
	}

	//change the app label text color if needed
	if (prefs.switcherBackgroundStyle == 2060 || prefs.switcherBackgroundStyle == 2010) {

		[_appName setTextColor:[UIColor darkGrayColor]];

	} else {

		[_appName setTextColor:[UIColor whiteColor]];

	}
	
}

- (void)zeroOutYOrigin {

	[UIView animateWithDuration:0.3f animations:^{
		CGRect frame = [self frame];
		frame.origin.y = 0;
		[self setFrame:frame];
	}];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(int)buttonIndex {

	[self zeroOutYOrigin];

	if (buttonIndex == 0) {

		//cancel, reopen the tray
		[(SwitcherTrayView *)_superSwitcher openTray];
	}
	else if (buttonIndex == 1) {

		//respring
		[[UIApplication sharedApplication] _relaunchSpringBoardNow];
	}

}

@end