#import "StratosDevCell.h"

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
        [devRealName setText:localized(properties[@"jobTitle"], properties[@"jobTitleEnglish"])];
        [devRealName setTextColor:[UIColor grayColor]];
        [devRealName setBackgroundColor:[UIColor clearColor]];
        [devRealName setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];
        
        [self addSubview:devRealName];
        
        jobSubtitle = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 95, frame.origin.y + 50, frame.size.width, frame.size.height)];
        [jobSubtitle setText:localized(properties[@"subtitle"], properties[@"subtitleEnglish"])];
        [jobSubtitle setTextColor:[UIColor grayColor]];
        [jobSubtitle setBackgroundColor:[UIColor clearColor]];
        [jobSubtitle setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];
        
        [self addSubview:jobSubtitle];
    }
    return self;
}

@end