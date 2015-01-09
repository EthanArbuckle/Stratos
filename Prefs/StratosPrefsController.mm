//
//  Stratos Prefs
//
//  Copyright (c)2014-2015 Cortex Dev Team. All rights reserved.
//
//
#import "StratosPrefs.h"

StratosPrefsController *rootPrefsController;
AVAudioPlayer *audioPlayer;

// Main Controller -------------------------------------------------------------

@implementation StratosPrefsController

-(id)init {
    if (self = [super init]) {
        rootPrefsController = self;
        //initialize NSUserDefaults
        stratosUserDefaults = [[NSUserDefaults alloc] _initWithSuiteName:kCDTSPreferencesDomain container:[NSURL URLWithString:@"/var/mobile"]];
        [stratosUserDefaults registerDefaults:@{
                                                kCDTSPreferencesEnabledKey: @YES,
                                                kCDTSPreferencesTrayBackgroundStyle : @1,
                                                @"switcherHeight" : @50,
                                                @"showGrabber"    : @YES,
                                                @"shouldInvokeCC" : @YES,
                                                @"showRunningApp" : @NO,
                                                @"defaultPage"    : @1,
                                                @"activateViaHome" : @NO
                                                }];
        [stratosUserDefaults synchronize];
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
        [stratosHeader setProperty:@"StratosHeaderCell" forKey:@"headerCellClass"];
        [specifiers addObject:stratosHeader];
        
        //Spacer
        enabledFooter = [PSSpecifier emptyGroupSpecifier];
        [enabledFooter setProperty:@"Shit's about to get real lamo up in this iDevice" forKey:@"footerText"];
        [specifiers addObject:enabledFooter];
        
        //Main kill switch
        enabledSwitch = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                                       target:self
                                                          set:@selector(setPreferenceValue:specifier:)
                                                          get:@selector(readPreferenceValue:)
                                                       detail:Nil
                                                         cell:PSSwitchCell
                                                         edit:Nil];
        [enabledSwitch setProperty:@"isEnabled" forKey:@"key"];
        [enabledSwitch setProperty:@YES forKey:@"default"];
        [enabledSwitch setProperty:@YES forKey:@"isEnabledSpec"];
        [enabledSwitch setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        [specifiers addObject:enabledSwitch];
        
        //"Tray Settings" Spacer
        backgroundStyleFooter = [PSSpecifier emptyGroupSpecifier];
        [backgroundStyleFooter setProperty:@"Choose the blur for your Stratos switcher tray" forKey:@"footerText"];
        
        //Background Style Picker
        backgroundStyleCell = [PSSpecifier preferenceSpecifierNamed:@"Background Style"
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
        
        heightSliderGroup = [PSSpecifier groupSpecifierWithHeader:@"Switcher Height" footer:@"Choose the height to which your switcher extends"];
        
        
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
        
        
        grabberSwitchFooter = [PSSpecifier emptyGroupSpecifier];
        [grabberSwitchFooter setProperty:@"Show the grabber on your Stratos switcher" forKey:@"footerText"];
        
        
        //Disable Grabber
        grabberSwitch = [PSSpecifier preferenceSpecifierNamed:@"Show Grabber"
                                                       target:self
                                                          set:@selector(setPreferenceValue:specifier:)
                                                          get:@selector(readPreferenceValue:)
                                                       detail:Nil
                                                         cell:PSSwitchCell
                                                         edit:Nil];
        [grabberSwitch setProperty:@"showGrabber" forKey:@"key"];
        [grabberSwitch setProperty:@YES forKey:@"default"];
        [grabberSwitch setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        
        
        showCCSwitchFooter = [PSSpecifier emptyGroupSpecifier];
        [showCCSwitchFooter setProperty:@"Invoke the Control Center after swping up beyond the Stratos switcher" forKey:@"footerText"];
        
        
        //Enable control center being pulled up
        showCCSwitch = [PSSpecifier preferenceSpecifierNamed:@"Invoke Control Center"
                                                       target:self
                                                          set:@selector(setPreferenceValue:specifier:)
                                                          get:@selector(readPreferenceValue:)
                                                       detail:Nil
                                                         cell:PSSwitchCell
                                                         edit:Nil];
        [showCCSwitch setProperty:@"shouldInvokeCC" forKey:@"key"];
        [showCCSwitch setProperty:@YES forKey:@"default"];
        [showCCSwitch setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        //ADD A FOOTER WHEN REARRAGING: "Enabling this shows allows you to invoke the control center by swiping up past the Stratos switcher"
        
        showRunningAppFooter = [PSSpecifier emptyGroupSpecifier];
        [showRunningAppFooter setProperty:@"Show the application that you are currently using in the Stratos switcher" forKey:@"footerText"];
        
        //Show currently running applications
        showRunningApp = [PSSpecifier preferenceSpecifierNamed:@"Running App in Switcher"
                                                      target:self
                                                         set:@selector(setPreferenceValue:specifier:)
                                                         get:@selector(readPreferenceValue:)
                                                      detail:Nil
                                                        cell:PSSwitchCell
                                                        edit:Nil];
        [showRunningApp setProperty:@"showRunningApp" forKey:@"key"];
        [showRunningApp setProperty:@NO forKey:@"default"];
        [showRunningApp setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        
        defaultPageCellFooter = [PSSpecifier emptyGroupSpecifier];
        [defaultPageCellFooter setProperty:@"The default page to show when you first invoke the Stratos switcher" forKey:@"footerText"];
        
        defaultPageCell = [PSSpecifier preferenceSpecifierNamed:@"Default Page"
                                                             target:self
                                                                set:@selector(setPreferenceValue:specifier:)
                                                                get:@selector(readPreferenceValue:)
                                                             detail:objc_getClass("StratosMovableListItemsController")
                                                               cell:PSLinkListCell
                                                               edit:Nil];
        [defaultPageCell setProperty:@"defaultPageTitles" forKey:@"titlesDataSource"];
        [defaultPageCell setProperty:@"defaultPageValues" forKey:@"valuesDataSource"];
        [defaultPageCell setProperty:@"defaultPage" forKey:@"key"];
        [defaultPageCell setProperty:@1 forKey:@"default"];
        [defaultPageCell setProperty:NSClassFromString(@"StratosTintedCell") forKey:@"cellClass"];
        
        doublePressHomeFooter = [PSSpecifier emptyGroupSpecifier];
        [doublePressHomeFooter setProperty:@"Allow the activation of Stratos via a double press of the home button" forKey:@"footerText"];
        
        doublePressHome = [PSSpecifier preferenceSpecifierNamed:@"Activate via home button"
                                                         target:self
                                                            set:@selector(setPreferenceValue:specifier:)
                                                            get:@selector(readPreferenceValue:)
                                                         detail:Nil
                                                           cell:PSSwitchCell
                                                           edit:Nil];
        [doublePressHome setProperty:@"activateViaHome" forKey:@"key"];
        [doublePressHome setProperty:@NO forKey:@"default"];
        [doublePressHome setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        //NEEDS BETTER EXPLANATION, ADD FOOTER
        
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
                         doublePressHomeFooter,
                         doublePressHome
                         ];
        if ([stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {
            for (PSSpecifier *spec in hiddenSpecs) {
                [specifiers addObject:spec];
            }
        }
        /*
         SPECIFIERS LEFT
         ---------------
         * default page to open to -- waiting on desicion for switcher complications
         * ordering of pages (media controls and quick launch stuff) -- see above
         
        */
        
        _specifiers = [specifiers copy];
        DebugLogC(@"_specifiers: %@", _specifiers);
	}
	return _specifiers;
}

-(NSArray *)defaultPageTitles {
    return @[ @"Switcher Cards", @"Control Center", @"Media Player" ];
}

-(NSArray *)defaultPageValues {
    return @[ @1, @2, @3 ];
}

-(NSArray *)backgroundStyleTitles {
    return [NSArray arrayWithObjects:@"Dark", @"Common Blur", @"CC Style", @"Light", nil];
}

-(NSArray *)backgroundStyleValues {
    return [NSArray arrayWithObjects:@1, @2, @2060, @2010, nil];
}

-(id) readPreferenceValue:(PSSpecifier*)specifier
{
    return [stratosUserDefaults objectForKey:specifier.properties[@"key"]];
}
 
-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier
{
    NSDictionary *properties = specifier.properties;
    [stratosUserDefaults setObject:value forKey:properties[@"key"]];
    [stratosUserDefaults synchronize];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.cortexdevteam.stratos.prefs-changed"), NULL, NULL, YES);
    if ([properties[@"isEnabledSpec"] boolValue]) {
        if (![value boolValue]) {
            [self removeContiguousSpecifiers:hiddenSpecs
                                    animated:YES];
        } else {
            [self addSpecifiersFromArray:hiddenSpecs
                                animated:YES];
        }
        [self performSelector:@selector(reloadSpecifiers) withObject:nil afterDelay:0.2f];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
/*
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:(BOOL)animated];
    UIImage *cortexLogo = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/Icon.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:cortexLogo];
}
*/
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

@implementation StratosListItemsController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = kDarkerTintColor;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    settingsView.tintColor = nil;
}

@end

@implementation StratosMovableListItemsController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = kDarkerTintColor;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    settingsView.tintColor = nil;
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end

//Tinted Cells ------------------------------------------------------------------
@implementation StratosTintedSwitchCell

-(id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
    self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
    if (self) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Eclipse.dylib"] && [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("com.gmoran.eclipse"))) boolValue]) //Eclipse Compatibility
            [((UISwitch *)[self control]) setTintColor:kTintColor];
        [((UISwitch *)[self control]) setOnTintColor:kTintColor]; //change the switch color
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.textColor = kDarkerTintColor;
}

@end

@implementation StratosTintedSliderCell

-(id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
    self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
    if (self) {
        UISlider *slider = (UISlider *)[self control];
        [slider setMinimumTrackTintColor:kDarkerTintColor]; //change the slider color
        [slider setMaximumTrackTintColor:[UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:228.0f/255.0f alpha:1.0]]; //change the right side color to something lighter so they contrast better
    }
    return self;
}

@end

@implementation StratosTintedCell

-(void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.textColor = kDarkerTintColor;
    self.detailTextLabel.textColor = [UIColor colorWithRed:151.0f/255.0f green:151.0f/255.0f blue:163.0f/255.0f alpha:1.0];
}

@end

// Header Cell -----------------------------------------------------------------

@implementation StratosHeaderCell
@synthesize backImageView = _backImageView;
@synthesize iconImageView = _iconImageView;


- (id)initWithSpecifier:(id)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        DebugLog0;
        
        //		self.backgroundColor = STRATOS_COLOR;
        
        // TODO: replace with a graphic
        //		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, HEADER_HEIGHT)];
        //		label.textColor = UIColor.whiteColor;
        //		label.font = [UIFont boldSystemFontOfSize:20];
        //		label.text = @"< graphic >";
        //		label.textAlignment = NSTextAlignmentCenter;
        //		[self addSubview:label];
        UIImage *backImage = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/Header-back.png"];
        _backImageView = [[UIImageView alloc] initWithImage:backImage];
        [self addSubview:_backImageView];
        UIImage* iconImage = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/Header-icon.png"];
        _iconImageView = [[UIImageView alloc] initWithImage:iconImage];
        _iconImageView.contentMode = UIViewContentModeCenter;
        _iconImageView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2, iconImage.size.height/2, 0, 0);
        [self addSubview:_iconImageView];
        //}
    }
    
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    return HEADER_HEIGHT;
}

@end



