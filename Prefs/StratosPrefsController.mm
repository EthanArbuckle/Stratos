//
//  Stratos Prefs
//
//  Copyright (c)2014-2015 Cortex Dev Team. All rights reserved.
//
//

// Main Controller -------------------------------------------------------------
#import "StratosPrefsController.h"

@implementation StratosPrefsController
@synthesize backImageView = _backImageView;
@synthesize iconImageView = _iconImageView;
@synthesize stratosUserDefaults;
-(id)init {
    if (self = [super init]) {
        //initialize NSUserDefaults
        self.stratosUserDefaults = [[NSUserDefaults alloc] _initWithSuiteName:kCDTSPreferencesDomain container:[NSURL URLWithString:@"/var/mobile"]];
        [self.stratosUserDefaults registerDefaults:kCDTSPreferencesDefaults];
        [self.stratosUserDefaults synchronize];
    }
    return self;
}

- (id)specifiers
{
	if (_specifiers == nil)
    {
        NSMutableArray *specifiers = [NSMutableArray new];
        hiddenSpecs = [NSMutableArray new];
        PSSpecifier *spec;

        //Stratos Header Cell
        spec = [PSSpecifier emptyGroupSpecifier];
        [spec setProperty:@"StratosSpacerCell" forKey:@"headerCellClass"];
        [spec setProperty:@160.0f forKey:@"spacerHeight"];
        [specifiers addObject:spec];

        //Spacer
        spec = [PSSpecifier emptyGroupSpecifier];
        [spec setProperty:localized(@"ENABLED_FOOTER", @"A new multitasking experience is just the flip of a switch away") forKey:@"footerText"];
        [specifiers addObject:spec];

        //Main kill switch
        spec = [PSSpecifier preferenceSpecifierNamed:localized(@"ENABLED", @"Enabled")
                                                       target:self
                                                          set:@selector(setPreferenceValue:specifier:)
                                                          get:@selector(readPreferenceValue:)
                                                       detail:Nil
                                                         cell:PSSwitchCell
                                                         edit:Nil];
        [spec setProperty:@"isEnabled" forKey:@"key"];
        [spec setProperty:@NO forKey:@"default"];
        [spec setProperty:@YES forKey:@"isEnabledSpec"];
        [spec setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        [specifiers addObject:spec];

        //Appearance Group Cell
        spec = [PSSpecifier groupSpecifierWithName:localized(@"APPEARANCE_HEADER", @"Appearance")];
        [spec setProperty:localized(@"HEIGHT_SLIDER_FOOTER", @"Choose the height to which your switcher extends") forKey:@"footerText"];
        [hiddenSpecs addObject:spec];

        //Background Style Picker
        spec = [PSSpecifier preferenceSpecifierNamed:localized(@"BACKGROUND_STYLE", @"Background Style")
                                                             target:self
                                                                set:@selector(setPreferenceValue:specifier:)
                                                                get:@selector(readPreferenceValue:)
                                                             detail:objc_getClass("StratosListItemsController")
                                                               cell:PSLinkListCell
                                                               edit:Nil];
        [spec setProperty:NSStringFromSelector(@selector(backgroundStyleTitles)) forKey:@"titlesDataSource"];
        [spec setProperty:NSStringFromSelector(@selector(backgroundStyleValues)) forKey:@"valuesDataSource"];
        [spec setProperty:@"switcherBackgroundStyle" forKey:@"key"];
        [spec setProperty:@1 forKey:@"default"];
        [spec setProperty:NSClassFromString(@"StratosTintedCell") forKey:@"cellClass"];
        [hiddenSpecs addObject:spec];


        //Disable Grabber
        spec = [PSSpecifier preferenceSpecifierNamed:localized(@"SHOW_GRABBER", @"Show Grabber")
                                                       target:self
                                                          set:@selector(setPreferenceValue:specifier:)
                                                          get:@selector(readPreferenceValue:)
                                                       detail:Nil
                                                         cell:PSSwitchCell
                                                         edit:Nil];
        [spec setProperty:@"showGrabber" forKey:@"key"];
        [spec setProperty:@YES forKey:@"default"];
        [spec setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        [hiddenSpecs addObject:spec];

        //enable parallax
        spec = [PSSpecifier preferenceSpecifierNamed:localized(@"ENABLE_PARALLAX", @"Enable Parallax")
                                                       target:self
                                                          set:@selector(setPreferenceValue:specifier:)
                                                          get:@selector(readPreferenceValue:)
                                                       detail:Nil
                                                         cell:PSSwitchCell
                                                         edit:Nil];
        [spec setProperty:@"enableParallax" forKey:@"key"];
        [spec setProperty:@YES forKey:@"default"];
        [spec setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        [hiddenSpecs addObject:spec];



        //Height of switcher slider
        spec = [PSSpecifier preferenceSpecifierNamed:@"Switcher Height"
                                                      target:self
                                                         set:@selector(setPreferenceValue:specifier:)
                                                         get:@selector(readPreferenceValue:)
                                                      detail:Nil
                                                        cell:PSSliderCell
                                                        edit:Nil];
        [spec setProperty:[NSNumber numberWithDouble:kScreenHeight/3.4] forKey:@"min"];
        [spec setProperty:[NSNumber numberWithDouble:kScreenHeight/2.5] forKey:@"max"];
        [spec setProperty:@NO forKey:@"showValue"];
        [spec setProperty:@"switcherHeight" forKey:@"key"];
        [spec setProperty:NSClassFromString(@"StratosTintedSliderCell") forKey:@"cellClass"];
        [hiddenSpecs addObject:spec];

        for (int i=0; i<9; i++)
            [hiddenSpecs addObject:[PSSpecifier emptyGroupSpecifier]];
        //Add a lot of empty group cells to accomodate the phone view :/

        //Functionality group cell
        spec = [PSSpecifier groupSpecifierWithName:localized(@"FUNCTIONALITY_HEADER", @"Functionality")];
        [spec setProperty:localized(@"INVOKE_CC_FOOTER", @"Invoke the Control Center after swiping up beyond the Stratos switcher") forKey:@"footerText"];
        [hiddenSpecs addObject:spec];

        //Show currently running applications
        spec = [PSSpecifier preferenceSpecifierNamed:localized(@"SHOW_RUNNING_APP", @"Show Running App in Switcher")
                                                      target:self
                                                         set:@selector(setPreferenceValue:specifier:)
                                                         get:@selector(readPreferenceValue:)
                                                      detail:Nil
                                                        cell:PSSwitchCell
                                                        edit:Nil];
        [spec setProperty:@"showRunningApp" forKey:@"key"];
        [spec setProperty:@NO forKey:@"default"];
        [spec setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        [hiddenSpecs addObject:spec];

        //Activate via home button switch
        spec = [PSSpecifier preferenceSpecifierNamed:localized(@"ACTIVATE_VIA_HOME", @"Activate via home button")
                                                         target:self
                                                            set:@selector(setPreferenceValue:specifier:)
                                                            get:@selector(readPreferenceValue:)
                                                         detail:Nil
                                                           cell:PSSwitchCell
                                                           edit:Nil];
        [spec setProperty:@"activateViaHome" forKey:@"key"];
        [spec setProperty:@NO forKey:@"default"];
        [spec setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        [hiddenSpecs addObject:spec];

        //Enable control center being pulled up
        spec = [PSSpecifier preferenceSpecifierNamed:localized(@"INVOKE_CC", @"Invoke Control Center")
                                                      target:self
                                                         set:@selector(setPreferenceValue:specifier:)
                                                         get:@selector(readPreferenceValue:)
                                                      detail:Nil
                                                        cell:PSSwitchCell
                                                        edit:Nil];
        [spec setProperty:@"shouldInvokeCC" forKey:@"key"];
        [spec setProperty:@YES forKey:@"default"];
        [spec setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        [hiddenSpecs addObject:spec];

        //Paging group cell
        spec = [PSSpecifier groupSpecifierWithName:localized(@"PAGING_HEADER", @"Paging")];
        [spec setProperty:localized(@"PAGING_FOOTER", @"Open to media controls if audio is playing") forKey:@"footerText"];
        [hiddenSpecs addObject:spec];

        //Default page PSLinkListCell
        spec = [PSSpecifier preferenceSpecifierNamed:localized(@"DEFAULT_PAGE", @"Default Page")
                                                             target:self
                                                                set:@selector(setPreferenceValue:specifier:)
                                                                get:@selector(readPreferenceValue:)
                                                             detail:objc_getClass("StratosListItemsController")
                                                               cell:PSLinkListCell
                                                               edit:Nil];
        [spec setProperty:@"defaultPageTitles" forKey:@"titlesDataSource"];
        [spec setProperty:@"defaultPageValues" forKey:@"valuesDataSource"];
        [spec setProperty:@"defaultPage" forKey:@"key"];
        [spec setProperty:@1 forKey:@"default"];
        [spec setProperty:NSClassFromString(@"StratosTintedCell") forKey:@"cellClass"];
        [hiddenSpecs addObject:spec];

        //Page order PSLinkCell
        spec = [PSSpecifier preferenceSpecifierNamed:localized(@"PAGE_ORDER", @"Page Order")
                                                         target:self
                                                            set:@selector(setPreferenceValue:specifier:)
                                                            get:@selector(readPreferenceValue:)
                                                         detail:objc_getClass("StratosMovableItemsController")
                                                           cell:PSLinkListCell
                                                           edit:Nil];
        [spec setProperty:@"pageOrder" forKey:@"key"];
        [spec setProperty:@1 forKey:@"default"];
        [spec setProperty:NSClassFromString(@"StratosTintedCell") forKey:@"cellClass"];
        [hiddenSpecs addObject:spec];

        //Number of switcher pages PSLinkListCell
        spec = [PSSpecifier preferenceSpecifierNamed:localized(@"NUMBER_OF_SWITCHER_PAGES", @"Number of switcher pages")
                                                         target:self
                                                            set:@selector(setPreferenceValue:specifier:)
                                                            get:@selector(readPreferenceValue:)
                                                         detail:objc_getClass("StratosListItemsController")
                                                           cell:PSLinkListCell
                                                           edit:Nil];
        [spec setProperty:@"numberOfPagesTitles" forKey:@"titlesDataSource"];
        [spec setProperty:@"numberOfPagesValues" forKey:@"valuesDataSource"];
        [spec setProperty:@"numberOfPages" forKey:@"key"];
        [spec setProperty:@6 forKey:@"default"];
        [spec setProperty:localized(@"SWITCHER_PAGES_NUMBER_FOOTER", @"The number of pages to show for the switcher cards. Used when you have another page (i.e. the Control Center or Media Controls) to the right of the switcher cards") forKey:@"staticTextMessage"];
        [spec setProperty:NSClassFromString(@"StratosTintedCell") forKey:@"cellClass"];
        [hiddenSpecs addObject:spec];

        //open to media controls if a song is playing
        spec = [PSSpecifier preferenceSpecifierNamed:localized(@"ACTIVE_MEDIACONTROLS", @"Open to Media if Playing")
                                                      target:self
                                                         set:@selector(setPreferenceValue:specifier:)
                                                         get:@selector(readPreferenceValue:)
                                                      detail:Nil
                                                        cell:PSSwitchCell
                                                        edit:Nil];
        [spec setProperty:@"activeMediaEnabled" forKey:@"key"];
        [spec setProperty:@NO forKey:@"default"];
        [spec setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        [hiddenSpecs addObject:spec];
        /*
        //empty group cell
        [hiddenSpecs addObject:[PSSpecifier emptyGroupSpecifier]];
        
        //REMOVE THIS. THIS IS FOR TESTING
        spec = [PSSpecifier preferenceSpecifierNamed:@"Reset All Prefs"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSButtonCell
                                                edit:Nil];
        spec->action = @selector(resetPreferences);
        [hiddenSpecs addObject:spec];
        */
        //if we're enabled, show all of the "hidden" specifiers
        if ([self.stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {
            for (PSSpecifier *spec in hiddenSpecs) {
                [specifiers addObject:spec];
            }
        }

        //empty spacer
        [specifiers addObject:[PSSpecifier emptyGroupSpecifier]];

        //"More" button for credits
        spec = [PSSpecifier preferenceSpecifierNamed:localized(@"MORE", @"More")
                                                                 target:self
                                                                    set:NULL
                                                                    get:NULL
                                                                 detail:objc_getClass("StratosCreditsListController")
                                                                   cell:PSLinkCell
                                                                   edit:Nil];
        [spec setProperty:NSClassFromString(@"StratosTintedCell") forKey:@"cellClass"];
        [specifiers addObject:spec];

        _specifiers = [specifiers copy];
        DebugLogC(@"_specifiers: %@", _specifiers);
	}
	return _specifiers;
}

-(NSArray *)numberOfPagesTitles {
    return @[ @"1", @"2", @"3", @"4", @"5", localized(@"ALL", @"All") ];
}

-(NSArray *)numberOfPagesValues {
    return @[ @1, @2, @3, @4, @5, @6 ];
}

-(NSArray *)defaultPageTitles {
    //reorder the default page cells to match the user-defined order
    NSArray *pageOrder = [stratosUserDefaults stringArrayForKey:@"pageOrder"];
    NSDictionary *names = @{
            @"controlCenter" : localized(@"CONTROL_CENTER", @"Control Center"),
            @"mediaControls" : localized(@"MEDIA_CONTROLS", @"Media Controls"),
            @"switcherCards" : localized(@"SWITCHER_CARDS", @"Switcher Cards")
        };
    NSMutableArray *pageTitles = [NSMutableArray new];
    for (NSString *pageIdent in pageOrder) {
        [pageTitles addObject:names[pageIdent]];
    }
    return pageTitles;
}

-(NSArray *)defaultPageValues {
    //same thing, reorder the cells
    NSArray *pageOrder = [stratosUserDefaults stringArrayForKey:@"pageOrder"];
    NSDictionary *values = @{
            @"controlCenter" : @2,
            @"mediaControls" : @3,
            @"switcherCards" : @1
        };
    NSMutableArray *pageValues = [NSMutableArray new];
    for (NSString *pageIdent in pageOrder) {
      [pageValues addObject:values[pageIdent]];
    }
    return pageValues;
}

-(NSArray *)backgroundStyleTitles {
    return [NSArray arrayWithObjects:localized(@"DARK_BACKGROUND", @"Dark"), localized(@"DOCK_BLUR_BACKGROUND", @"Dock Blur"), localized(@"COMMON_BLUR_BACKGROUND", @"Common Blur"), localized(@"CC_STYLE_BACKGROUND", @"CC Style"), localized(@"LIGHT_BACKGROUND", @"Light"), nil];
}

-(NSArray *)backgroundStyleValues {
    return [NSArray arrayWithObjects:@1, @9999, @2, @2060, @2010, nil];
}

-(id) readPreferenceValue:(PSSpecifier*)specifier
{
    return [self.stratosUserDefaults objectForKey:specifier.properties[@"key"]];
}

-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier
{
    //set the setting in NSUserDefaults
    NSDictionary *properties = specifier.properties;
    NSString *key = properties[@"key"];
    [self.stratosUserDefaults setObject:value forKey:key];
    [self.stratosUserDefaults synchronize];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.cortexdevteam.stratos.prefs-changed"), NULL, NULL, YES);

    //if it's the enabled
    if ([key isEqualToString:@"isEnabled"]) {

        if (![value boolValue]) { //if they're switching it off, hide the specifiers
            [self removeContiguousSpecifiers:hiddenSpecs
                                    animated:YES];
            //phone view
            [UIView animateWithDuration:0.2f animations:^{
              [phoneView setAlpha:0];
            }];
            
        } else { //if they're switching it on, show the specifiers
            [self insertContiguousSpecifiers:hiddenSpecs
                                     atIndex:3
                                    animated:YES];
            //phone view
            [UIView animateWithDuration:0.3f animations:^{
              [phoneView setAlpha:1];
            }];
        }
    }
    //when the user changes the blur, reload the new blur
    if ([key isEqualToString:@"switcherBackgroundStyle"])
        [self reloadBlurView];

    //show/hide grabber
    if ([key isEqualToString:@"showGrabber"]) {
        if ([value boolValue])
            [switcherView addSubview:grabberView];
        else
            [grabberView removeFromSuperview];
    }

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.isMovingToParentViewController)
        [self reloadSpecifiers]; //do we still need this?

    //tint
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = kDarkerTintColor;

    //heart button with easter egg
    composeTweet = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(tweetSweetNothings:)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(sayBUTTons:)];
    UIImage *image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/heart.png"];
    CGRect frameimg = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(tweetSweetNothings) forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    [someButton addGestureRecognizer:longPress];
    UIBarButtonItem *tweetButton = [[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.rightBarButtonItem = tweetButton;


}

-(void)viewDidLoad {
    [super viewDidLoad];
    int width = [[UIScreen mainScreen] bounds].size.width;
    //header
    UIImage* headerImage = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/Header.png"];
    NSLog(@"headerImage size: %@", NSStringFromCGSize(headerImage.size));
    CGImageRef imageRef = CGImageCreateWithImageInRect([headerImage CGImage], CGRectMake((621-width), 0, width*2, 416*2));
    _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:imageRef scale:headerImage.scale orientation:headerImage.imageOrientation]];
    CGImageRelease(imageRef);
    _iconImageView.contentMode = UIViewContentModeCenter;
    [_iconImageView setCenter:CGPointMake( [[UIScreen mainScreen] bounds].size.width/2, -48 )];
    [[self table] addSubview:_iconImageView];

    //phone preview

    //phone base
    UIImage *phoneImage = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/iphone_small.png"];
    phoneView = [[UIImageView alloc] initWithImage:phoneImage];
    phoneView.frame = CGRectMake((width/2)-160, 560, phoneImage.size.width, phoneImage.size.height);

    //blur view
    if ([self.stratosUserDefaults integerForKey:kCDTSPreferencesTrayBackgroundStyle] == 9999) {

        switcherView = [[NSClassFromString(@"SBWallpaperEffectView") alloc] initWithWallpaperVariant:1];
        [(SBWallpaperEffectView *)switcherView setStyle:11];
    }
    else {

        switcherView = [[_UIBackdropView alloc] initWithStyle:[self.stratosUserDefaults integerForKey:kCDTSPreferencesTrayBackgroundStyle]];
    }
    [phoneView addSubview:switcherView];
        //SUMS: Y = 265
    [self setNewHeight:[stratosUserDefaults floatForKey:@"switcherHeight"]];

    //Grabber view
    CGRect frame = CGRectMake((width/2)-2.5, 1, 10, 10);

    //This is really weird stuff, but I couldn't just add the UIImageView to switcherView, so I created an "intermediary" UIView :/
    grabberView = [[UIView alloc] initWithFrame:frame];
    UIImageView *grabber = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/grabber.png"]];
    [grabber setUserInteractionEnabled:NO];
    [grabberView addSubview:grabber];
    [grabber setFrame:CGRectMake(98.5, 5, 20, 4)];
    if ([stratosUserDefaults boolForKey:@"showGrabber"])
        [switcherView addSubview:grabberView];

    //show/hide it based on if the tweak is enabled
    if ([stratosUserDefaults boolForKey:@"isEnabled"])
      [phoneView setAlpha:1];
    else
      [phoneView setAlpha:0];
    [self.table addSubview:phoneView];
}

-(void)reloadBlurView {
    [switcherView removeFromSuperview];
    if ([self.stratosUserDefaults integerForKey:kCDTSPreferencesTrayBackgroundStyle] == 9999) {

        switcherView = [[NSClassFromString(@"SBWallpaperEffectView") alloc] initWithWallpaperVariant:1];
        [(SBWallpaperEffectView *)switcherView setStyle:11];
    }
    else {

        switcherView = [[_UIBackdropView alloc] initWithStyle:[self.stratosUserDefaults integerForKey:kCDTSPreferencesTrayBackgroundStyle]];
    }
    [phoneView addSubview:switcherView];
    [self setNewHeight:[stratosUserDefaults floatForKey:@"switcherHeight"]];
    [switcherView addSubview:grabberView];
    //[switcherView setFrame:CGRectMake(10, 195, 130, 70)];
}

- (void)sliderMoved:(UISlider *)slider {
    //NSLog(@"Scaling %@ to %f", self.switcherPreview, slider.value);
    [self setNewHeight:slider.value];

}

-(void)setNewHeight:(float)height {
    float newHeight = (height/kScreenHeight)*(385.970666889);
    float newOrigin = 193-newHeight;
    [switcherView setFrame:CGRectMake(47.8, newOrigin, 217, newHeight)];
}

//remove title
-(void)setTitle:(id)title {
    [super setTitle:nil];
}

//remove tint
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    settingsView.tintColor = nil;
}

//tweet
-(void)tweetSweetNothings {
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [composeController setInitialText:@"I downloaded @CortexDevTeam's new tweak #Stratos by @its_not_herpes and it's lamo!"];
    [self presentViewController:composeController
                       animated:YES
                     completion:nil];
}

//REMOVE THIS. IT IS FOR TESTING
-(void)resetPreferences {
    for (NSString *key in kCDTSPreferencesDefaults) {
        [self.stratosUserDefaults removeObjectForKey:key];
    }
}

//easter egg
-(void)sayBUTTons:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        DebugLogC(@"BUTTons");
        NSError *soundError = nil;
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:kBUTTons options:0];
        audioPlayer = [[AVAudioPlayer alloc] initWithData:decodedData error:&soundError];
        if (soundError && !audioPlayer) {
            DebugLogC(@"sound error: %@", soundError);
        }
        [audioPlayer prepareToPlay];
        [audioPlayer play];
    }
}

@end
