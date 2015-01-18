#import "StratosThanksController.h"
@implementation StratosThanksController

-(id)specifiers {
	if (_specifiers == nil) {
		NSMutableArray *specifiers = [NSMutableArray new];
		PSSpecifier *spec;

		spec = [PSSpecifier groupSpecifierWithName:@"Translators"];
		[specifiers addObject:spec];
		
		thanksCell(@"thapublicMan", @"@delia_stefan", @selector(openTwitter:));
		thanksCell(@"Niko", @"/u/TeamArrow", @selector(openReddit:));
		thanksCell(@"Carlos Israel Ortiz Garza", @"/u/carlos_ortiz", @selector(openReddit:));
		thanksCell(@"Florent Le Moël", @"/u/phlooo", @selector(openReddit:));
		thanksCell(@"Costee", @"@costee", @selector(openTwitter:));
		//thanksCell() Italian?
		PlainCell(@"TiVo444");
		thanksCell(@"Zarko", @"@nicifor0vic", @selector(openTwitter:));
		thanksCell(@"Muhammad Redza", @"@redzrex", @selector(openTwitter));
		PlainCell(@"gertab");
		PlainCell(@"mrkssntr");
		thanksCell(@"Bruno Silva", @"@iMaNi_aC", @selector(openTwitter:));
		thanksCell(@"Andreas Henriksson", @"/u/andreashenriksson", @selector(openReddit:));
		thanksCell(@"iOS-LoveU", @"@you_0816", @selector(openTwitter:));

		_specifiers = [specifiers copy];
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