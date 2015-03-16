#import "StratosCloseListController.h"
@implementation StratosCloseListController

-(id)specifiers {
	if (!_specifiers) {
		NSMutableArray *specifiers = [NSMutableArray new];
		PSSpecifier *spec;

        spec = [PSSpecifier emptyGroupSpecifier];
        [spec setProperty:@"For those with the third split feature enabled, the third split regions are split up among the region to the right of the close region." forKey:@"footerText"];
		[specifiers addObject:spec];
        //Main kill switch
        spec = [PSSpecifier preferenceSpecifierNamed:localized(@"ENABLED", @"Enabled")
                                                       target:self
                                                          set:@selector(setPreferenceValue:specifier:)
                                                          get:@selector(readPreferenceValue:)
                                                       detail:Nil
                                                         cell:PSSwitchCell
                                                         edit:Nil];
        [spec setProperty:kCDTSPreferencesSwipeToClose forKey:@"key"];
        [spec setProperty:@NO forKey:@"default"];
        [spec setProperty:@YES forKey:@"isEnabledSpec"];
        [spec setProperty:NSClassFromString(@"StratosTintedSwitchCell") forKey:@"cellClass"];
        [specifiers addObject:spec];
        //Height of switcher slider
        spec = [PSSpecifier preferenceSpecifierNamed:@"Switcher Height"
                                                      target:self
                                                         set:@selector(setPreferenceValue:specifier:)
                                                         get:@selector(readPreferenceValue:)
                                                      detail:Nil
                                                        cell:PSSliderCell
                                                        edit:Nil];
        [spec setProperty:[NSNumber numberWithDouble:kScreenWidth/5] forKey:@"min"];
        [spec setProperty:[NSNumber numberWithDouble:kScreenWidth/2] forKey:@"max"];
        NSLog(@"min: %f, max: %f", kScreenWidth/5, kScreenWidth/2);
        [spec setProperty:@NO forKey:@"showValue"];
        [spec setProperty:kCDTSPreferencesSwipeToCloseWidth forKey:@"key"];
        [spec setProperty:NSClassFromString(@"StratosTintedSliderCell") forKey:@"cellClass"];
        [specifiers addObject:spec];

        _specifiers = [specifiers copy];
	}
	return _specifiers;
}

-(id) readPreferenceValue:(PSSpecifier*)specifier
{
    NSString *key = specifier.properties[@"key"];
    id obj = [[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] objectForKey:key];
    NSLog(@"obj: %@", obj);
    NSLog(@"Current preference: %@, %@", obj ?: kCDTSPreferencesDefaults[key], obj ? @"(default)" : @"(user-set)");
    return obj ?: kCDTSPreferencesDefaults[key];
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier
{
    //set the setting in NSUserDefaults
    NSDictionary *properties = specifier.properties;
    NSString *key = properties[@"key"];
    NSMutableDictionary *prefsDict = [NSMutableDictionary dictionary];
    [prefsDict addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH]];
    [prefsDict setObject:value forKey:key];
    [prefsDict writeToFile:PLIST_PATH atomically:YES];
  CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        (CFStringRef)[kCDTSPreferencesDomain stringByAppendingPathComponent:@"ReloadPrefs"],
        NULL,
        NULL,
        YES
    );

    //show/hide glowy thingy
    if ([key isEqualToString:kCDTSPreferencesSwipeToClose]) {
        if ([value boolValue])
            [phoneView addSubview:glowyThingy];
        else
            [glowyThingy removeFromSuperview];
    }

}

- (void)sliderMoved:(UISlider *)slider {
    //NSLog(@"Scaling %@ to %f", self.switcherPreview, slider.value);
    [self setNewWidth:slider.value];

}

-(void)setNewWidth:(CGFloat)width {
    CGFloat newWidth = (width/kScreenWidth)*(217);
    [glowyThingy setFrame:CGRectMake(47.8, 188, newWidth, 5)];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    int width = [self rootController].view.frame.size.width;

    //phone base
    UIImage *phoneImage = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/iphone_small.png"];
    phoneView = [[UIImageView alloc] initWithImage:phoneImage];
    phoneView.frame = CGRectMake((width/2)-160, 188, phoneImage.size.width, phoneImage.size.height);

    UIImage *glowImage = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/glowythingy.png"];
    glowyThingy = [[UIImageView alloc] initWithImage:glowImage];
    CGFloat sliderWidth;
    floatPreference(kCDTSPreferencesSwipeToCloseWidth, sliderWidth);
    [self setNewWidth:sliderWidth];
    [phoneView addSubview:glowyThingy];

    [self.table addSubview:phoneView];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //tint
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = kDarkerTintColor;

}

//remove tint
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    settingsView.tintColor = nil;
}

@end