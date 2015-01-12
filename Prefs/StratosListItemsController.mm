#import <UIKit/UIKit.h>
#import <Preferences/PSListItemsController.h>
#import "StratosPrefs.h"

@interface StratosListItemsController : PSListItemsController {
    UIWindow *settingsView;
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