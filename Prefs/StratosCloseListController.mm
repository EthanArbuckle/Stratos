#import "StratosCloseListController.h"
@implementation StratosCloseListController

-(id)specifiers {
	if (!_specifiers) {
		NSMutableArray *specifiers = [NSMutableArray new];
		PSSpecifier *spec;

		[specifiers addObject:[PSSpecifier emptyGroupSpecifier]];
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

        _specifiers = [specifiers copy];
	}
	return _specifiers;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    int width = [self rootController].view.frame.size.width;

    //phone base
    UIImage *phoneImage = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/StratosPrefs.bundle/iphone_small.png"];
    phoneView = [[UIImageView alloc] initWithImage:phoneImage];
    phoneView.frame = CGRectMake((width/2)-160, 100, phoneImage.size.width, phoneImage.size.height);

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