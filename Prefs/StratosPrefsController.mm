//
//  Stratos Prefs
//
//  Copyright (c)2014-2015 Cortex Dev Team. All rights reserved.
//
//

// Main Controller -------------------------------------------------------------
#import "StratosPrefsController.h"
AVAudioPlayer *audioPlayer;
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
        NSMutableArray *specifiers = [[NSMutableArray alloc] init];
        
        //Stratos Header Cell
        stratosHeader = [PSSpecifier emptyGroupSpecifier];
        [stratosHeader setProperty:@"StratosSpacerCell" forKey:@"headerCellClass"];
        [stratosHeader setProperty:@160.0f forKey:@"spacerHeight"];
        [specifiers addObject:stratosHeader];
        
        //Spacer
        enabledFooter = [PSSpecifier emptyGroupSpecifier];
        [enabledFooter setProperty:localized(@"ENABLED_FOOTER", @"A new multitasking experience is just the flip of a switch away") forKey:@"footerText"];
        [specifiers addObject:enabledFooter];
        
        //Main kill switch
        enabledSwitch = [PSSpecifier preferenceSpecifierNamed:localized(@"ENABLED", @"Enabled")
                                                       target:self
                                                          set:@selector(setPreferenceValue:specifier:)
                                                          get:@selector(readPreferenceValue:)
                                                       detail:Nil
                                                         cell:PSSwitchCell
                                                         edit:Nil];
        [enabledSwitch setProperty:@"isEnabled" forKey:@"key"];
        [enabledSwitch setProperty:@NO forKey:@"default"];
        [enabledSwitch setProperty:@YES forKey:@"isEnabledSpec"];
        [enabledSwitch setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        [specifiers addObject:enabledSwitch];
        
        //"Tray Settings" Spacer
        //backgroundStyleFooter = [PSSpecifier emptyGroupSpecifier];
        //[backgroundStyleFooter setProperty:@"Choose the blur for your Stratos switcher tray" forKey:@"footerText"];
        
        heightSliderGroup = [PSSpecifier groupSpecifierWithName:localized(@"APPEARANCE_HEADER", @"Appearance")];
        [heightSliderGroup setProperty:localized(@"HEIGHT_SLIDER_FOOTER", @"Choose the height to which your switcher extends") forKey:@"footerText"];
        
        //Background Style Picker
        backgroundStyleCell = [PSSpecifier preferenceSpecifierNamed:localized(@"BACKGROUND_STYLE", @"Background Style")
                                                             target:self
                                                                set:@selector(setPreferenceValue:specifier:)
                                                                get:@selector(readPreferenceValue:)
                                                             detail:objc_getClass("StratosListItemsController")
                                                               cell:PSLinkListCell
                                                               edit:Nil];
        [backgroundStyleCell setProperty:NSStringFromSelector(@selector(backgroundStyleTitles)) forKey:@"titlesDataSource"];
        [backgroundStyleCell setProperty:NSStringFromSelector(@selector(backgroundStyleValues)) forKey:@"valuesDataSource"];
        [backgroundStyleCell setProperty:@"switcherBackgroundStyle" forKey:@"key"];
        [backgroundStyleCell setProperty:@1 forKey:@"default"];
        [backgroundStyleCell setProperty:NSClassFromString(@"StratosTintedCell") forKey:@"cellClass"];
        
        
        //Disable Grabber
        grabberSwitch = [PSSpecifier preferenceSpecifierNamed:localized(@"SHOW_GRABBER", @"Show Grabber")
                                                       target:self
                                                          set:@selector(setPreferenceValue:specifier:)
                                                          get:@selector(readPreferenceValue:)
                                                       detail:Nil
                                                         cell:PSSwitchCell
                                                         edit:Nil];
        [grabberSwitch setProperty:@"showGrabber" forKey:@"key"];
        [grabberSwitch setProperty:@YES forKey:@"default"];
        [grabberSwitch setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        
        
        //Height of switcher slider
        heightSlider = [PSSpecifier preferenceSpecifierNamed:@"Switcher Height"
                                                      target:self
                                                         set:@selector(setPreferenceValue:specifier:)
                                                         get:@selector(readPreferenceValue:)
                                                      detail:Nil
                                                        cell:PSSliderCell
                                                        edit:Nil];
        [heightSlider setProperty:@50 forKey:@"default"];
        [heightSlider setProperty:@0 forKey:@"min"];
        [heightSlider setProperty:@100 forKey:@"max"];
        [heightSlider setProperty:@NO forKey:@"showValue"];
        [heightSlider setProperty:@"switcherHeight" forKey:@"key"];
        [heightSlider setProperty:NSClassFromString(@"StratosTintedSliderCell") forKey:@"cellClass"];

        previewSpecifier = [PSSpecifier emptyGroupSpecifier];
        [previewSpecifier setProperty:@"StratosSpacerCell" forKey:@"footerCellClass"];
        [previewSpecifier setProperty:@300.0f forKey:@"spacerHeight"];
        
        
        //grabberSwitchFooter = [PSSpecifier emptyGroupSpecifier];
        //[grabberSwitchFooter setProperty:@"Show the grabber on your Stratos switcher" forKey:@"footerText"];
        
        
        //showCCSwitchFooter = [PSSpecifier emptyGroupSpecifier];
        //[showCCSwitchFooter setProperty:@"Invoke the Control Center after swiping up beyond the Stratos switcher" forKey:@"footerText"];
        
        
        
        //ADD A FOOTER WHEN REARRAGING: "Enabling this shows allows you to invoke the control center by swiping up past the Stratos switcher"
        
        //showRunningAppFooter = [PSSpecifier emptyGroupSpecifier];
        //[showRunningAppFooter setProperty:@"Show the application that you are currently using in the Stratos switcher" forKey:@"footerText"];
        
        showCCSwitchFooter = [PSSpecifier groupSpecifierWithName:localized(@"FUNCTIONALITY_HEADER", @"Functionality")];
        [showCCSwitch setProperty:localized(@"INVOKE_CC_FOOTER", @"Invoke the Control Center after swiping up beyond the Stratos switcher") forKey:@"footerText"];
        
        //Show currently running applications
        showRunningApp = [PSSpecifier preferenceSpecifierNamed:localized(@"SHOW_RUNNING_APP", @"Show Running App in Switcher")
                                                      target:self
                                                         set:@selector(setPreferenceValue:specifier:)
                                                         get:@selector(readPreferenceValue:)
                                                      detail:Nil
                                                        cell:PSSwitchCell
                                                        edit:Nil];
        [showRunningApp setProperty:@"showRunningApp" forKey:@"key"];
        [showRunningApp setProperty:@NO forKey:@"default"];
        [showRunningApp setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        
        doublePressHome = [PSSpecifier preferenceSpecifierNamed:localized(@"ACTIVATE_VIA_HOME", @"Activate via home button")
                                                         target:self
                                                            set:@selector(setPreferenceValue:specifier:)
                                                            get:@selector(readPreferenceValue:)
                                                         detail:Nil
                                                           cell:PSSwitchCell
                                                           edit:Nil];
        [doublePressHome setProperty:@"activateViaHome" forKey:@"key"];
        [doublePressHome setProperty:@NO forKey:@"default"];
        [doublePressHome setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        
        //Enable control center being pulled up
        showCCSwitch = [PSSpecifier preferenceSpecifierNamed:localized(@"INVOKE_CC", @"Invoke Control Center")
                                                      target:self
                                                         set:@selector(setPreferenceValue:specifier:)
                                                         get:@selector(readPreferenceValue:)
                                                      detail:Nil
                                                        cell:PSSwitchCell
                                                        edit:Nil];
        [showCCSwitch setProperty:@"shouldInvokeCC" forKey:@"key"];
        [showCCSwitch setProperty:@YES forKey:@"default"];
        [showCCSwitch setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        
        //defaultPageCellFooter = [PSSpecifier emptyGroupSpecifier];
        //[defaultPageCellFooter setProperty:@"The default page to show when you first invoke the Stratos switcher" forKey:@"footerText"];
        
        defaultPageCellFooter = [PSSpecifier groupSpecifierWithName:localized(@"PAGING_HEADER", @"Paging")];
        
        defaultPageCell = [PSSpecifier preferenceSpecifierNamed:localized(@"DEFAULT_PAGE", @"Default Page")
                                                             target:self
                                                                set:@selector(setPreferenceValue:specifier:)
                                                                get:@selector(readPreferenceValue:)
                                                             detail:objc_getClass("StratosListItemsController")
                                                               cell:PSLinkListCell
                                                               edit:Nil];
        [defaultPageCell setProperty:@"defaultPageTitles" forKey:@"titlesDataSource"];
        [defaultPageCell setProperty:@"defaultPageValues" forKey:@"valuesDataSource"];
        [defaultPageCell setProperty:@"defaultPage" forKey:@"key"];
        [defaultPageCell setProperty:@1 forKey:@"default"];
        [defaultPageCell setProperty:NSClassFromString(@"StratosTintedCell") forKey:@"cellClass"];
        
        
        pageOrderCell = [PSSpecifier preferenceSpecifierNamed:localized(@"PAGE_ORDER", @"Page Order")
                                                         target:self
                                                            set:@selector(setPreferenceValue:specifier:)
                                                            get:@selector(readPreferenceValue:)
                                                         detail:objc_getClass("StratosMovableItemsController")
                                                           cell:PSLinkListCell
                                                           edit:Nil];
        [pageOrderCell setProperty:@"pageOrder" forKey:@"key"];
        [pageOrderCell setProperty:@1 forKey:@"default"];
        [pageOrderCell setProperty:NSClassFromString(@"StratosTintedCell") forKey:@"cellClass"];
        
        
        numberOfPagesCell = [PSSpecifier preferenceSpecifierNamed:localized(@"NUMBER_OF_SWITCHER_PAGES", @"Number of switcer pages")
                                                         target:self
                                                            set:@selector(setPreferenceValue:specifier:)
                                                            get:@selector(readPreferenceValue:)
                                                         detail:objc_getClass("StratosListItemsController")
                                                           cell:PSLinkListCell
                                                           edit:Nil];
        [numberOfPagesCell setProperty:@"numberOfPagesTitles" forKey:@"titlesDataSource"];
        [numberOfPagesCell setProperty:@"numberOfPagesValues" forKey:@"valuesDataSource"];
        [numberOfPagesCell setProperty:@"numberOfPages" forKey:@"key"];
        [numberOfPagesCell setProperty:@6 forKey:@"default"];
        [numberOfPagesCell setProperty:localized(@"SWITCHER_PAGES_NUMBER_FOOTER", @"The number of pages to show for the switcher cards. Used when you have another page (i.e. the Control Center or Media Controls) to the right of the switcher cards") forKey:@"staticTextMessage"];
        [numberOfPagesCell setProperty:NSClassFromString(@"StratosTintedCell") forKey:@"cellClass"];

        
        //doublePressHomeFooter = [PSSpecifier emptyGroupSpecifier];
        //[doublePressHomeFooter setProperty:@"Allow the activation of Stratos via a double press of the home button" forKey:@"footerText"];
        
        PSSpecifier *removeAllPrefsButtonSpacer = [PSSpecifier emptyGroupSpecifier];
        
        PSSpecifier *removeAllPrefsButton = [PSSpecifier preferenceSpecifierNamed:@"Reset All Prefs"
                                                                           target:self
                                                                              set:NULL
                                                                              get:NULL
                                                                           detail:Nil
                                                                             cell:PSButtonCell
                                                                             edit:Nil];
        removeAllPrefsButton->action = @selector(resetPreferences);
        /*
        hiddenSpecs = @[ backgroundStyleFooter,
                         backgroundStyleCell,
                         heightSliderGroup,
                         heightSlider,
                         grabberSwitchFooter,
                         grabberSwitch,
                         showCCSwitchFooter,
                         showCCSwitch,
                         showRunningAppFooter,
                         showRunningApp,
                         defaultPageCellFooter,
                         defaultPageCell,
                         pageOrderCell,
                         doublePressHomeFooter,
                         doublePressHome,
                         removeAllPrefsButtonSpacer,
                         removeAllPrefsButton
                         ];
         */
        hiddenSpecs = @[ heightSliderGroup,
                         backgroundStyleCell,
                         grabberSwitch,
                         heightSlider,
                         previewSpecifier,
                         //grabberSwitchFooter,
                         
                         showCCSwitchFooter,
                         
                         //showRunningAppFooter,
                         showRunningApp,
                         doublePressHome,
                         showCCSwitch,
                         defaultPageCellFooter,
                         defaultPageCell,
                         pageOrderCell,
                         //doublePressHomeFooter,
                         numberOfPagesCell,
                         removeAllPrefsButtonSpacer,
                         removeAllPrefsButton
                         ];
        if ([self.stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {
            for (PSSpecifier *spec in hiddenSpecs) {
                [specifiers addObject:spec];
            }
        }
        
        [specifiers addObject:[PSSpecifier emptyGroupSpecifier]];
        PSSpecifier *moreButton = [PSSpecifier preferenceSpecifierNamed:localized(@"MORE", @"More")
                                                                 target:self
                                                                    set:NULL
                                                                    get:NULL
                                                                 detail:objc_getClass("StratosCreditsListController")
                                                                   cell:PSLinkCell
                                                                   edit:Nil];
        [moreButton setProperty:NSClassFromString(@"StratosTintedCell") forKey:@"cellClass"];
        [specifiers addObject:moreButton];
        
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
    return @[ localized(@"SWITCHER_CARDS", @"Switcher Cards"), localized(@"CONTROL_CENTER", @"Control Center"), localized(@"MEDIA_CONTROLS", @"Media Controls") ];
}

-(NSArray *)defaultPageValues {
    return @[ @1, @2, @3 ];
}

-(NSArray *)backgroundStyleTitles {
    return [NSArray arrayWithObjects:localized(@"DARK_BACKGROUND", @"Dark"), localized(@"COMMON_BLUR_BACKGROUND", @"Common Blur"), localized(@"CC_STYLE_BACKGROUND", @"CC Style"), localized(@"LIGHT_BACKGROUND", @"Light"), nil];
}

-(NSArray *)backgroundStyleValues {
    return [NSArray arrayWithObjects:@1, @2, @2060, @2010, nil];
}

-(id) readPreferenceValue:(PSSpecifier*)specifier
{
    return [self.stratosUserDefaults objectForKey:specifier.properties[@"key"]];
}
 
-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier
{
    NSDictionary *properties = specifier.properties;
    NSString *key = properties[@"key"];
    [self.stratosUserDefaults setObject:value forKey:key];
    [self.stratosUserDefaults synchronize];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.cortexdevteam.stratos.prefs-changed"), NULL, NULL, YES);
    if ([properties[@"isEnabledSpec"] boolValue]) {
        if (![value boolValue]) {
            [self removeContiguousSpecifiers:hiddenSpecs
                                    animated:YES];
            [phoneView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.1f];
        } else {
            [self insertContiguousSpecifiers:hiddenSpecs
                                     atIndex:3
                                    animated:YES];
            [self.table performSelector:@selector(addSubview:) withObject:phoneView afterDelay:0.15f];
        }
    }
    if ([key isEqualToString:@"switcherBackgroundStyle"])
        [self reloadBlurView];
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
        [self reloadSpecifiers];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = kDarkerTintColor;
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
    UIImage* headerImage = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/Header.png"];
    _iconImageView = [[UIImageView alloc] initWithImage:headerImage];
    _iconImageView.contentMode = UIViewContentModeCenter;
    [_iconImageView setCenter:CGPointMake( [[UIScreen mainScreen] bounds].size.width/2, headerImage.size.height/2 )];
    [[self table] addSubview:_iconImageView];
    int width = [[UIScreen mainScreen] bounds].size.width;
    
    UIImage *phoneImage = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/iphone.png"];
    phoneView = [[UIImageView alloc] initWithImage:phoneImage];
    phoneView.frame = CGRectMake((width/2)-544/6, 510, 544/3, 965/3);
    //phoneView.center = CGPointMake(, 650);

    switcherView = [[_UIBackdropView alloc] initWithStyle:[[self.stratosUserDefaults valueForKey:kCDTSPreferencesTrayBackgroundStyle] intValue]];
    [phoneView addSubview:switcherView];

        //SUMS: Y = 265
    [self setNewHeight:[stratosUserDefaults floatForKey:@"switcherHeight"]];
    CGRect frame = CGRectMake((width/2)-2.5, 1, 10, 10);

    //This is really weird stuff, but I couldn't just add the UIImageView to switcherView, so I created an "intermediary" UIView :/
    grabberView = [[UIView alloc] initWithFrame:frame];
    UIImageView *grabber = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/grabber.png"]];
    [grabber setUserInteractionEnabled:NO];
    [grabberView addSubview:grabber];
    [grabber setFrame:CGRectMake(57, 3, 10, 2)];
    if ([stratosUserDefaults boolForKey:@"showGrabber"])
        [switcherView addSubview:grabberView];

    //[switcherView setFrame:CGRectMake(10, 195, 130, 70)];
    if ([stratosUserDefaults boolForKey:@"isEnabled"])
        [self.table addSubview:phoneView];
}

-(void)reloadBlurView {
    [switcherView removeFromSuperview];
    switcherView = [[_UIBackdropView alloc] initWithStyle:[[self.stratosUserDefaults valueForKey:kCDTSPreferencesTrayBackgroundStyle] intValue]];
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
    float newHeight = 50+(30*height)/100;
    float newOrigin = 258-newHeight;
    [switcherView setFrame:CGRectMake(163/6, newOrigin, 123, newHeight)];
}

-(void)setTitle:(id)title {
    [super setTitle:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    settingsView.tintColor = nil;
}

-(void)tweetSweetNothings {
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [composeController setInitialText:@"I downloaded @CortexDevTeam's new tweak #Stratos by @its_not_herpes and it's lamo!"];
    [self presentViewController:composeController
                       animated:YES
                     completion:nil];
}

-(void)resetPreferences {
    for (NSString *key in kCDTSPreferencesDefaults) {
        [self.stratosUserDefaults removeObjectForKey:key];
    }
}

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