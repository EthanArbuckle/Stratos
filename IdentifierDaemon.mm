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

		}
	//});


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

@end