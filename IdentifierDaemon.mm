#import "IdentifierDaemon.h"

@implementation IdentifierDaemon

+ (id)sharedInstance {
	static dispatch_once_t p = 0;
	__strong static id _sharedObject = nil;
	 
	dispatch_once(&p, ^{
		_sharedObject = [[self alloc] init];
	});

	return _sharedObject;
}

- (id)init {

	if (self = [super init]) {

		//init the arrays
		_appIdentifiers = [[NSMutableArray alloc] init];
		_appSnapshots = [[NSMutableArray alloc] init];

		//app card holder
		_appCards = [[NSMutableDictionary alloc] init];

		//reload apps
		[self reloadApps];

	}

	return self;
}

- (UIImage *)appSnapshotForIdentifier:(NSString *)ident {

	//make sure we have the identifier. 
	if ([_appIdentifiers containsObject:ident]) {

		//get index of it
		int index = [_appIdentifiers indexOfObject:ident];

		//return the image
		return [_appSnapshots objectAtIndex:index];

	}

	//if we get here, then something went wrong. return a empty image to avoid crashes
	return [[UIImage alloc] init];
}

- (void)reloadApps {

	//get the running app identifiers
	_appIdentifiers = [[NSMutableArray alloc] initWithArray:[self identifiers]];

	//get the instance of sbuicontroller
	SBUIController *sharedController = [NSClassFromString(@"SBUIController") sharedInstance];

	//get the existing instance of SBAppSliderController from sharedController
	SBAppSliderController *sliderController = [sharedController valueForKey:@"_switcherController"];

	//do all this in a gcd thread cuz dat lag
  //  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {

		//clear the snapshots by reiniting the array
		_appSnapshots = [[NSMutableArray alloc] init];

		//cycle through them all
		for (NSString *ident in _appIdentifiers) {

			//get SBAppSliderSnapshotView from appslidercontroller
			SBAppSliderSnapshotView *snapshotView;
			if ([sliderController respondsToSelector:@selector(_snapshotViewForDisplayIdentifier:)]) {
				snapshotView = [sliderController _snapshotViewForDisplayIdentifier:ident];
			}
			else {
				//sliderController is an sbappslidercontroller on iOS 7, but sbappswitchercontroller on iOS 8 (so cast it)
				snapshotView = [(SBAppSwitcherController *)sliderController _snapshotViewForDisplayItem:(SBDisplayItem *)[NSClassFromString(@"SBDisplayItem") displayItemWithType:@"App" displayIdentifier:ident]];
			}

			//tell snapshot view to load a new snapshot
			[snapshotView _loadSnapshotSync];
			if ([snapshotView valueForKey:@"_snapshotImageView"]) { //if it succeeded and a image view is present

				UIImage *realImage = [[snapshotView valueForKey:@"_snapshotImageView"] image]; //get the image
				[_appSnapshots addObject:realImage];
			}
			else {

				//couldnt get the preview, now we have to do a bunch of work to get the splashscreen -_-
				id application = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:ident];
				NSString *splashPath = [NSString stringWithFormat:@"%@/Default.png", [(SBApplication *)application path]];
				UIImage *splashImage = [UIImage imageWithContentsOfFile:splashPath];

				//not all apps have a defual image, so create nil obejct to avoid crash
				if (!splashImage) {
					splashImage = [[UIImage alloc] init];
				}

				[_appSnapshots addObject:splashImage];

			}

			//see if card for this ident exists. if not, create it
			if ([_appCards objectForKey:ident] == nil) {

				//there is no card for this identifier, create it
				SwitcherTrayCardView *currentApp = [[SwitcherTrayCardView alloc] initWithIdentifier:ident];

				//add it to dictionary with key as its identifier
				[_appCards setObject:currentApp forKey:ident];
			}
			else {

				//the app exists, lets tell it to refresh
				[(SwitcherTrayCardView *)[_appCards objectForKey:ident] cardNeedsUpdating];
			}

		}
	//});


}

- (UIView *)switcherCardForIdentifier:(NSString *)identifier {

	//make sure it exists
	if ([_appCards objectForKey:identifier] != nil) {

		//return it
		return (UIView *)[_appCards objectForKey:identifier];
	}

	//card doesnt exist, go ahead and create it
	DebugLog(@"tried to access card that didnt exist, creating it");
	SwitcherTrayCardView *currentApp = [[SwitcherTrayCardView alloc] initWithIdentifier:identifier];

	//add it to dictionary with key as its identifier
	[_appCards setObject:currentApp forKey:identifier];

	//and return it
	return (UIView *)currentApp;
}

- (NSArray *)identifiers {

	//get SBAppSwitcherModel instance
	SBAppSwitcherModel *appSwitcherModel = (SBAppSwitcherModel *)[NSClassFromString(@"SBAppSwitcherModel") sharedInstance];
	
	NSArray *identifiers;

	//iOS 7
	if ([appSwitcherModel respondsToSelector:@selector(identifiers)]) {
		identifiers = [appSwitcherModel identifiers];
	}
	else {
		//iOS 8
		identifiers = [appSwitcherModel snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary];
	}

	//if we need to remove the topmost app
	if (![[(SBUIController *)NSClassFromString(@"SBUIController") stratosUserDefaults] boolForKey:kCDTSPreferencesShowRunningApp]) {

		//if an app is open
		if ([(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication]) {

			NSMutableArray *newIdentifiers = [[NSMutableArray alloc] initWithArray:identifiers copyItems:YES];

			//remove first identifier (running app)
			if ([newIdentifiers count] > 0) {
				[newIdentifiers removeObjectAtIndex:0];
			}

			//return nonmutable array
			return [newIdentifiers copy];

		}
	}

	return identifiers;
}

- (void)purgeCardCache {

	l(@"Purging card cache");
	
	//just recreate the dictionary, which will clear it of everything
	_appCards = [[NSMutableDictionary alloc] init];

}

@end