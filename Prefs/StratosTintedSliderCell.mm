#import <UIKit/UIKit.h>
#import <Preferences/PSSliderTableCell.h>
#import "StratosPrefs.h"

@interface StratosTintedSliderCell : PSSliderTableCell { }
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