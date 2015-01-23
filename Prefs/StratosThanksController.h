#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCellType.h>
#import <objc/runtime.h>
#import "StratosPrefs.h"

#define thanksCell(a, b, c) spec = [PSSpecifier preferenceSpecifierNamed:(a) \
                                              target:self \
                                                 set:NULL \
                                                 get:NULL \
                                              detail:Nil \
                                                cell:PSButtonCell \
                                                edit:Nil]; \
						[spec setProperty:(b) forKey:@"handle"]; \
            [spec setProperty:NSClassFromString(@"StratosSocialCell") forKey:@"cellClass"]; \
						spec->action = (c); \
						[specifiers addObject:spec]; \
						spec = nil

#define PlainCell(a) spec = [PSSpecifier preferenceSpecifierNamed:(a) \
                                              target:self \
                                                 set:NULL \
                                                 get:NULL \
                                              detail:objc_getClass("StratosCreditsController") \
                                                cell:PSStaticTextCell \
                                                edit:Nil]; \
                     [spec setProperty:NSClassFromString(@"StratosTintedCell") forKey:@"cellClass"]; \
						         [specifiers addObject:spec]; \
						         spec = nil

@interface StratosThanksController : PSListController {
  UIWindow *settingsView;
}
@end
