//
//  Stratos Prefs
//
//  Copyright (c)2014 Cortex Dev Team. All rights reserved.
//
//

#import "../Stratos.h"
#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>

#define DEBUG_PREFIX @"••• [Stratos Prefs]"
#import "../DebugLog.h"

#define STRATOS_COLOR		[UIColor colorWithRed:60/255.0 green:60/255.0 blue:69/255.0 alpha:1]
#define HEADER_HEIGHT		160.0f
#define HEADER_IMAGE_PATH_750	@"/Library/PreferenceBundles/StratosPrefs.bundle/Header-750w.png"
#define HEADER_IMAGE_PATH_640	@"/Library/PreferenceBundles/StratosPrefs.bundle/Header-640w.png"
#define HEADER_IMAGE_PATH	@"/Library/PreferenceBundles/StratosPrefs.bundle/Header-1242w.png"


@interface StratosPrefsController: PSListController {
    NSUserDefaults *stratosUserDefaults;
}
@end

@interface StratosHeaderCell : PSTableCell
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@end




// Main Controller -------------------------------------------------------------

@implementation StratosPrefsController

-(id)init {
    if (self = [super init]) {
        stratosUserDefaults = stratosUserDefaults = [[NSUserDefaults alloc] _initWithSuiteName:kCDTSPreferencesDomain container:[NSURL URLWithString:@"/var/mobile"]];
        [stratosUserDefaults registerDefaults:@{
                                                kCDTSPreferencesEnabledKey: @"YES",
                                                kCDTSPreferencesTrayBackgroundStyle : @1
                                                }];
        [stratosUserDefaults synchronize];
    }
    return self;
}

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"StratosPrefs" target:self];
	}
	return _specifiers;
}

-(id) readPreferenceValue:(PSSpecifier*)specifier
{
    return [stratosUserDefaults objectForKey:specifier.properties[@"key"]];
}
 
-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier
{
    [stratosUserDefaults setObject:value forKey:specifier.properties[@"key"]];
    [stratosUserDefaults synchronize];
    
	CFStringRef toPost = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if(toPost) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
}

@end



// Header Cell -----------------------------------------------------------------

@implementation StratosHeaderCell
@synthesize backImageView = _backImageView;
@synthesize iconImageView = _iconImageView;


- (id)initWithSpecifier:(id)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell" specifier:specifier];
	if (self) {
		DebugLog0;
		
		self.backgroundColor = STRATOS_COLOR;
		
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

