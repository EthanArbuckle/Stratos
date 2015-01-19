#import "StratosTintedSliderCell.h"

@implementation StratosTintedSliderCell

-(id)initWithStyle:(UITableViewCellStyle)arg1 reuseIdentifier:(id)arg2 specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:specifier];
    if (self) {
        UISlider *slider = (UISlider *)[self control];
        NSLog(@"Target: %@", specifier.target);
        [slider addTarget:specifier.target action:@selector(sliderMoved:) forControlEvents:UIControlEventAllTouchEvents];
        [slider setMinimumTrackTintColor:kDarkerTintColor]; //change the slider color
        [slider setMaximumTrackTintColor:[UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:228.0f/255.0f alpha:1.0]];
    }
    return self;
}

@end
