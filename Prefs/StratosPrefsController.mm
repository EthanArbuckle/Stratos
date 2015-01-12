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
@synthesize backImageView = _backImageView;
@synthesize iconImageView = _iconImageView;

-(id)init {
    if (self = [super init]) {
        rootPrefsController = self;
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
            [self addSpecifiersFromArray:hiddenSpecs
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
/*
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
*/
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


- (id)initWithSpecifier:(id)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        DebugLog0;
    }
    
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    return HEADER_HEIGHT;
}

@end

@implementation StratosCreditsListController

-(id)specifiers {
    if (_specifiers==nil) {
        _specifiers = _specifiers = [self loadSpecifiersFromPlistName:@"credits" target:self];
    }
    return _specifiers;
}

-(void)openTwitter:(PSSpecifier *)specifier {
    NSString *screenName = [specifier.properties[@"handle"] substringFromIndex:1];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tweetbot:///user_profile/%@", screenName]]];
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitterrific:///profile?screen_name=%@", screenName]]];
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tweetings:///user?screen_name=%@", screenName]]];
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", screenName]]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://mobile.twitter.com/%@", screenName]]];
}

-(void)openReddit:(PSSpecifier *)specifier {
    NSString *screenName = specifier.properties[@"handle"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://www.reddit.com" stringByAppendingString:screenName]]];
}

@end

@implementation StratosMovableItemsController

- (id)initForContentSize:(CGSize)size
{
    self = [super init];
    if (self)
    {
        stratosUserDefaults = [[NSUserDefaults alloc] _initWithSuiteName:kCDTSPreferencesDomain container:[NSURL URLWithString:@"/var/mobile"]];
        [stratosUserDefaults registerDefaults:kCDTSPreferencesDefaults];
        [stratosUserDefaults synchronize];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
        
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self.tableView setEditing:YES];
        [self.tableView setAllowsSelection:NO];
        
        [self setView:self.tableView];
        
        [self setTitle:@"Page Order"];
    }
    
    return self;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Page order";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Top to bottom represents left to right";
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    NSInteger index = indexPath.row;
    DebugLogC(@"Cell Index: %ld", (long)index);
    NSArray *pageOrder = [stratosUserDefaults stringArrayForKey:@"pageOrder"];
    
    cell.textLabel.text = pageOrder[index];
    //cell.imageView.image = iconForDescription(desc);
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *pageOrder = [[stratosUserDefaults stringArrayForKey:@"pageOrder"] mutableCopy];
    NSInteger sourceIndex = sourceIndexPath.row;
    NSInteger destIndex = destinationIndexPath.row;
    if (sourceIndex>destIndex) {
        NSString *cellToMove = [pageOrder objectAtIndex:sourceIndex];
        for (int i=sourceIndex; i>destIndex; i--) {
            [pageOrder replaceObjectAtIndex:i withObject:pageOrder[i-1]];
        }
        [pageOrder replaceObjectAtIndex:destIndex withObject:cellToMove];
    } else if (sourceIndex<destIndex) {
        NSString *cellToMove = [pageOrder objectAtIndex:sourceIndex];
        for (int i=sourceIndex; i<destIndex; i++) {
            [pageOrder replaceObjectAtIndex:i withObject:pageOrder[i+1]];
        }
        [pageOrder replaceObjectAtIndex:destIndex withObject:cellToMove];
    }
    
    [stratosUserDefaults setObject:pageOrder forKey:@"pageOrder"];
    [stratosUserDefaults synchronize];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.cortexdevteam.stratos.prefs-changed"), NULL, NULL, YES);
    //[tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

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

@implementation StratosDevCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier])){
        NSDictionary *properties = specifier.properties;
        DebugLogC(@"Properties: %@", properties);
        UIImage *bkIm = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/StratosPrefs.bundle/%@.png", properties[@"imageName"]]];
        _background = [[UIImageView alloc] initWithImage:bkIm];
        _background.frame = CGRectMake(10, 15, 70, 70);
        [self addSubview:_background];
        
        CGRect frame = [self frame];
        
        devName = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 10, frame.size.width, frame.size.height)];
        [devName setText:properties[@"devName"]];
        [devName setBackgroundColor:[UIColor clearColor]];
        [devName setTextColor:[UIColor blackColor]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [devName setFont:[UIFont fontWithName:@"Helvetica Light" size:30]];
        else
            [devName setFont:[UIFont fontWithName:@"Helvetica Light" size:23]];
        
        [self addSubview:devName];
        
        devRealName = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 30, frame.size.width, frame.size.height)];
        [devRealName setText:properties[@"jobTitle"]];
        [devRealName setTextColor:[UIColor grayColor]];
        [devRealName setBackgroundColor:[UIColor clearColor]];
        [devRealName setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];
        
        [self addSubview:devRealName];
        
        jobSubtitle = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 50, frame.size.width, frame.size.height)];
        [jobSubtitle setText:properties[@"subtitle"]];
        [jobSubtitle setTextColor:[UIColor grayColor]];
        [jobSubtitle setBackgroundColor:[UIColor clearColor]];
        [jobSubtitle setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];
        
        [self addSubview:jobSubtitle];
    }
    return self;
}

@end

@implementation StratosSocialCell

-(void)layoutSubviews {
    [super layoutSubviews];
    //NSDictionary *properties = self.specifier.properties;
    self.textLabel.textColor = kDarkerTintColor;
    self.detailTextLabel.text = self.specifier.properties[@"handle"];
    self.detailTextLabel.textColor = [UIColor colorWithRed:151.0f/255.0f green:151.0f/255.0f blue:163.0f/255.0f alpha:1.0];
}

@end