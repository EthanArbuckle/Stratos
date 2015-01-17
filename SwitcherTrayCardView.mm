#import "SwitcherTrayCardView.h"

@implementation SwitcherTrayCardView

- (id)initWithIdentifier:(NSString *)identifier {

	if (self = [super init]) {

		_identifier = identifier;

		//create the imageview that will hold the preview image of the app
		UIImageView *snapshotHolder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSwitcherCardWidth, kSwitcherCardHeight)];
		[snapshotHolder setContentMode:UIViewContentModeScaleAspectFit];

		dispatch_async(dispatch_get_main_queue(), ^{
			[self addSubview:snapshotHolder];

			//get the image from our ident daemon
			[snapshotHolder setImage:[[IdentifierDaemon sharedInstance] appSnapshotForIdentifier:_identifier]];
		});

		//create imageview that will hold the apps icon
		UIImageView *iconHolder = [[UIImageView alloc] initWithFrame:CGRectMake((kSwitcherCardWidth / 2) - 20, kSwitcherCardHeight - 38, 40, 40)];
		
		//get instance of the application
		_application = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:identifier];

		//create an icon for the application
		__block SBApplicationIcon *icon;

		//lets not deadlock if created on gcd thread
		dispatch_async(dispatch_get_main_queue(), ^{
			icon = [[NSClassFromString(@"SBApplicationIcon") alloc] initWithApplication:_application];
		});

		//add shadow to the view
		[[iconHolder layer] setShadowColor:[UIColor blackColor].CGColor];
		[[iconHolder layer] setShadowOffset:CGSizeMake(0, 2)];
		[[iconHolder layer] setShadowOpacity:1];
		[[iconHolder layer] setShadowRadius:4.0];
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

		//create the label that displays the name of the app
		UILabel *appName = [[UILabel alloc] initWithFrame:CGRectMake(0, kSwitcherCardHeight, kSwitcherCardWidth, 20)];


		dispatch_async(dispatch_get_main_queue(), ^{
			[appName setText:[(SBApplication *)_application displayName]];
			[appName setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
			[appName setTextColor:[UIColor whiteColor]];
			[appName setTextAlignment:NSTextAlignmentCenter];
			[self addSubview:appName];

		});

		//add tap recognizer so we can open the app when this card is touched
		UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openApp)];
		[tapGes setCancelsTouchesInView:YES];
		[self addGestureRecognizer:tapGes];

		//create pangesture recognizer so the cards can be flicked up
		UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panning:)];
		[self addGestureRecognizer:panGes];
		[panGes setDelegate:self];

	}

	return self;

}

- (void)openApp {

	//close the switcher
	if (_superSwitcher) {

		[(SwitcherTrayView *)_superSwitcher closeTray];
		
	}

	//open the app
	[[NSClassFromString(@"SBUIController") sharedInstance] activateApplicationAnimated:[[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:_identifier]];
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

			[UIView animateWithDuration:1.0f animations:^{

				//animate this card out
				CGRect frame = [self frame];
				frame.origin.y = -500;
				[self setFrame:frame];

			}];

			//tell the switcher to close this app
			[(SwitcherTrayView *)_superSwitcher cardRequestingToClose:self];
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

@end