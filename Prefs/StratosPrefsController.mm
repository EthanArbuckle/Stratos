//
//  Stratos Prefs
//
//  Copyright (c)2014-2015 Cortex Dev Team. All rights reserved.
//
//
#import "StratosPrefs.h"
#import <Preferences/PSListController.h>
#import <Preferences/PSTableCellType.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "buttons.h"

AVAudioPlayer *audioPlayer;

@interface StratosPrefsController : PSListController {
    UIView *stratosHeightView;
    UIWindow *settingsView;
    UIBarButtonItem *composeTweet;
    NSUserDefaults *stratosUserDefaults;
    PSSpecifier *stratosHeader;
    PSSpecifier *enabledFooter;
    PSSpecifier *enabledSwitch;
    PSSpecifier *backgroundStyleFooter;
    PSSpecifier *backgroundStyleCell;
    PSSpecifier *heightSliderGroup;
    PSSpecifier *heightSlider;
    PSSpecifier *grabberSwitchFooter;
    PSSpecifier *grabberSwitch;
    PSSpecifier *showCCSwitchFooter;
    PSSpecifier *showCCSwitch;
    PSSpecifier *showRunningAppFooter;
    PSSpecifier *showRunningApp;
    PSSpecifier *defaultPageCellFooter;
    PSSpecifier *defaultPageCell;
    PSSpecifier *pageOrderCell;
    PSSpecifier *doublePressHomeFooter;
    PSSpecifier *doublePressHome;
    PSSpecifier *numberOfPagesCell;
    NSArray *hiddenSpecs;
}
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@end

// Main Controller -------------------------------------------------------------

@implementation StratosPrefsController
@synthesize backImageView = _backImageView;
@synthesize iconImageView = _iconImageView;

-(id)init {
    if (self = [super init]) {
        //initialize NSUserDefaults
        stratosUserDefaults = [[NSUserDefaults alloc] _initWithSuiteName:kCDTSPreferencesDomain container:[NSURL URLWithString:@"/var/mobile"]];
        [stratosUserDefaults registerDefaults:kCDTSPreferencesDefaults];
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
        [enabledFooter setProperty:@"A new multitasking experience is just the flip of a switch away" forKey:@"footerText"];
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
        [enabledSwitch setProperty:@NO forKey:@"default"];
        [enabledSwitch setProperty:@YES forKey:@"isEnabledSpec"];
        [enabledSwitch setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        [specifiers addObject:enabledSwitch];
        
        //"Tray Settings" Spacer
        //backgroundStyleFooter = [PSSpecifier emptyGroupSpecifier];
        //[backgroundStyleFooter setProperty:@"Choose the blur for your Stratos switcher tray" forKey:@"footerText"];
        
        
        heightSliderGroup = [PSSpecifier groupSpecifierWithHeader:@"Appearance" footer:@"Choose the height to which your switcher extends"];
        
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
        
        
        //grabberSwitchFooter = [PSSpecifier emptyGroupSpecifier];
        //[grabberSwitchFooter setProperty:@"Show the grabber on your Stratos switcher" forKey:@"footerText"];
        
        
        //showCCSwitchFooter = [PSSpecifier emptyGroupSpecifier];
        //[showCCSwitchFooter setProperty:@"Invoke the Control Center after swiping up beyond the Stratos switcher" forKey:@"footerText"];
        
        
        
        //ADD A FOOTER WHEN REARRAGING: "Enabling this shows allows you to invoke the control center by swiping up past the Stratos switcher"
        
        //showRunningAppFooter = [PSSpecifier emptyGroupSpecifier];
        //[showRunningAppFooter setProperty:@"Show the application that you are currently using in the Stratos switcher" forKey:@"footerText"];
        
        showCCSwitchFooter = [PSSpecifier groupSpecifierWithHeader:@"Functionality" footer:@"Invoke the Control Center after swiping up beyond the Stratos switcher"];
        
        //Show currently running applications
        showRunningApp = [PSSpecifier preferenceSpecifierNamed:@"Show Running App in Switcher"
                                                      target:self
                                                         set:@selector(setPreferenceValue:specifier:)
                                                         get:@selector(readPreferenceValue:)
                                                      detail:Nil
                                                        cell:PSSwitchCell
                                                        edit:Nil];
        [showRunningApp setProperty:@"showRunningApp" forKey:@"key"];
        [showRunningApp setProperty:@NO forKey:@"default"];
        [showRunningApp setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        
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
        
        //defaultPageCellFooter = [PSSpecifier emptyGroupSpecifier];
        //[defaultPageCellFooter setProperty:@"The default page to show when you first invoke the Stratos switcher" forKey:@"footerText"];
        
        defaultPageCellFooter = [PSSpecifier groupSpecifierWithName:@"Paging"];
        
        defaultPageCell = [PSSpecifier preferenceSpecifierNamed:@"Default Page"
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
        
        
        pageOrderCell = [PSSpecifier preferenceSpecifierNamed:@"Page Order"
                                                         target:self
                                                            set:@selector(setPreferenceValue:specifier:)
                                                            get:@selector(readPreferenceValue:)
                                                         detail:objc_getClass("StratosMovableItemsController")
                                                           cell:PSLinkListCell
                                                           edit:Nil];
        [pageOrderCell setProperty:@"pageOrder" forKey:@"key"];
        [pageOrderCell setProperty:@1 forKey:@"default"];
        [pageOrderCell setProperty:NSClassFromString(@"StratosTintedCell") forKey:@"cellClass"];
        
        
        numberOfPagesCell = [PSSpecifier preferenceSpecifierNamed:@"Number of switcer pages"
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
        [numberOfPagesCell setProperty:@"The number of pages to show for the switcher cards. Used when you have another page (i.e. the Control Center or Media Controls) to the right of the switcher cards" forKey:@"staticTextMessage"];
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
        if ([stratosUserDefaults boolForKey:kCDTSPreferencesEnabledKey]) {
            for (PSSpecifier *spec in hiddenSpecs) {
                [specifiers addObject:spec];
            }
        }
        
        [specifiers addObject:[PSSpecifier emptyGroupSpecifier]];
        PSSpecifier *moreButton = [PSSpecifier preferenceSpecifierNamed:@"More"
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
    return @[ @"1", @"2", @"3", @"4", @"5", @"All" ];
}

-(NSArray *)numberOfPagesValues {
    return @[ @1, @2, @3, @4, @5, @6 ];
}

-(NSArray *)defaultPageTitles {
    return @[ @"Switcher Cards", @"Control Center", @"Media Controls" ];
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
            [self insertContiguousSpecifiers:hiddenSpecs
                                     atIndex:3
                                    animated:YES];
        }
        //[self performSelector:@selector(reloadSpecifiers) withObject:nil afterDelay:0.2f];
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

/*
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:(BOOL)animated];
    UIImage *cortexLogo = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/Icon.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:cortexLogo];
}
*/

-(void)viewDidLoad {
    [super viewDidLoad];
    UIImage* headerImage = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/Header.png"];
    _iconImageView = [[UIImageView alloc] initWithImage:headerImage];
    _iconImageView.contentMode = UIViewContentModeCenter;
    [_iconImageView setCenter:CGPointMake( [[UIScreen mainScreen] bounds].size.width/2, headerImage.size.height/2 )];
    [[self table] addSubview:_iconImageView];
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
        [stratosUserDefaults removeObjectForKey:key];
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