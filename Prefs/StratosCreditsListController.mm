#import "StratosCreditsListController.h"

@implementation StratosCreditsListController

-(id)specifiers {
    if (_specifiers==nil) {
        _specifiers = [self loadSpecifiersFromPlistName:@"credits" target:self];
    }
    _specifiers = [self localizeSpecifiers:_specifiers];
    return _specifiers;
}

-(NSArray *)localizeSpecifiers:(NSArray *)specifiers {
    NSMutableArray *result = [NSMutableArray new];
    for (PSSpecifier *spec in specifiers) {
        if (spec.cellType == PSGroupCell) {
            NSDictionary *properties = spec.properties;
            if (spec.name)
                [spec setName:localized(spec.name, properties[@"labelEnglish"])];
            if (properties[@"footerText"])
                [spec setProperty:localized(properties[@"footerText"], properties[@"footerTextEnglish"]) forKey:@"footerText"];
        }
        [result addObject:spec];
    }
    return result;
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = kDarkerTintColor;
    [self setTitle:localized(@"CREDITS", @"Credits")];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    settingsView.tintColor = nil;
}

@end