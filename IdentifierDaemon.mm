#import "IdentifierDaemon.h"

static CDTSPreferences *prefs;

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
		prefs = [CDTSPreferences sharedInstance];
		//init the arrays
		_appIdentifiers = [[NSMutableArray alloc] init];
		_appSnapshots = [[NSMutableArray alloc] init];

		//app card holder
		_appCards = [[NSMutableDictionary alloc] init];

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
	DebugLog(@"No snapshot found, returning blank image");
	return [[UIImage alloc] init];
}

- (void)reloadApps {

	//just stop the method if we dont actually need to reload
	if (![self doesRequireReload]) {

		return;
	}

	//get the running app identifiers
	_appIdentifiers = [[NSMutableArray alloc] initWithArray:[self identifiers]];

	//get the existing instance of SBAppSliderController from sbuicontroller
	SBAppSliderController *sliderController = [(SBUIController *)[NSClassFromString(@"SBUIController") sharedInstance] valueForKey:@"_switcherController"];

	//clear existing snapshots
	[_appSnapshots removeAllObjects];

	//cycle through them all
	for (NSString *ident in _appIdentifiers) {

		//add snapshot for ident to preview array
		[_appSnapshots addObject:[self preheatSnapshotForIndentifier:ident withController:sliderController]];

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

	//manually create homescreen card if needed
	if ([self shouldShowHomescreenCard]) {

		[_appIdentifiers insertObject:@"com.apple.SpringBoard" atIndex:0];	

		//add blank image here to keep indexes synced up
		[_appSnapshots insertObject:[[UIImage alloc] init] atIndex:0];
		SwitcherTrayCardView *homeScreenCard = [[SwitcherTrayCardView alloc] initWithIdentifier:@"com.apple.SpringBoard"];
		[_appCards setObject:homeScreenCard forKey:@"com.apple.SpringBoard"];

	}

}

- (UIImage *)preheatSnapshotForIndentifier:(NSString *)ident withController:(SBAppSliderController *)sliderController {

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

		//return the uiimage
		return [[snapshotView valueForKey:@"_snapshotImageView"] image]; //get the image
		
	}
	else {

		//couldnt get the preview, now we have to do a bunch of work to get the splashscreen -_-
		id application = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:ident];
		NSString *splashPath = [NSString stringWithFormat:@"%@/Default.png", [(SBApplication *)application path]];
		UIImage *splashImage = [UIImage imageWithContentsOfFile:splashPath];

		//not all apps have a default image, so create nil object to avoid crash
		if (!splashImage) {
			splashImage = [[UIImage alloc] init];
		}	

		return splashImage;
	}

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
	if (![prefs showRunningApp]) {

		//if an app is open
		if ([(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication]) {

			NSMutableArray *newIdentifiers = [[NSMutableArray alloc] initWithArray:identifiers copyItems:YES];

			//remove first identifier (running app)
			if ([newIdentifiers count] > 0) {
				[newIdentifiers removeObjectAtIndex:0];
			}

			//return nonmutable array with or without homescreen
			if ([self shouldShowHomescreenCard]) {

				[newIdentifiers insertObject:@"com.apple.SpringBoard" atIndex:0];
			}

			return [newIdentifiers copy];

		}
	}

	if ([self shouldShowHomescreenCard]) {
				
		NSMutableArray *swipSwap = [identifiers mutableCopy];
		[swipSwap insertObject:@"com.apple.SpringBoard" atIndex:0];
		return [swipSwap copy];
	}

	return identifiers;
}

- (void)purgeCardCache {

	l(@"Purging card cache");

	//just recreate the dictionary, which will clear it of everything
	_appCards = [[NSMutableDictionary alloc] init];

}

- (BOOL)doesRequireReload {

	//get current running idents
	NSArray *systemRunningIdentifiers = [self identifiers];

	//if our array doesnt have the same amount as the system, we need to reload
	if ([_appIdentifiers count] != [systemRunningIdentifiers count]) {

		return YES;

	}

	//cycle through each index comparing identifiers, return YES if one of them doesnt match
	for (NSString *identifierToCompare in _appIdentifiers) {

		int index = [_appIdentifiers indexOfObject:identifierToCompare];

		if (identifierToCompare != systemRunningIdentifiers[index]) {

			return YES;

		}

	}

	DebugLog(@"No reload required");
	return NO;
}

- (BOOL)shouldShowHomescreenCard {

	//only show homescreen card if its enable AND we're not on the homescreen
	return ([prefs enableHomescreen] && [[UIApplication sharedApplication] _accessibilityFrontMostApplication]);
}

- (UIView *)enableHostingAndReturnViewForID:(NSString *)bundleID {

	//create sbapplication
	SBApplication *appToHost = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleID];

	//make sure its running
	[[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:YES];

	//get context manager and app scene
	FBScene *appScene = [appToHost mainScene];
	FBWindowContextHostManager *appContextManager = [appScene contextHostManager];

	//update local reference to springboard window
	_sbWindow = [(UIView *)[appContextManager valueForKey:@"_hostView"] window];

	//get scene settings
	FBSMutableSceneSettings *sceneSettings = [[appScene mutableSettings] mutableCopy];

	//force backgrounding to NO
	[sceneSettings setBackgrounded:NO];

	//reapply new settings to scene
	[appScene _applyMutableSettings:sceneSettings withTransitionContext:nil completion:nil];

	//allow hosting of our new hostview
	[appContextManager enableHostingForRequester:bundleID orderFront:YES];

	//get our fancy new hosting view
	UIView *hostingView = [appContextManager hostViewForRequester:bundleID enableAndOrderFront:YES];

	//return it
	return hostingView;

}

- (void)disableContextHostingForIdentifier:(NSString *)bundleID {

	//create sbapplication
	SBApplication *appToHost = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleID];

	//get context manager and app scene
	FBScene *appScene = [appToHost mainScene];
	FBWindowContextHostManager *appContextManager = [appScene contextHostManager];

	//disable hosting
	[appContextManager disableHostingForRequester:bundleID];

}

@end