#import <UIKit/UIKit.h>
#import "../Stratos.h"
#import <Preferences/PSViewController.h>
#import "StratosPrefs.h"

@interface StratosMovableItemsController : PSViewController <UITableViewDataSource, UITableViewDelegate> {
    NSUserDefaults *stratosUserDefaults;
    UIWindow *settingsView;
}
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation StratosMovableItemsController

- (id)initForContentSize:(CGSize)size
{
    self = [super init];
    if (self)
    {
        stratosUserDefaults = [[NSUserDefaults alloc] _initWithSuiteName:kCDTSPreferencesDomain container:[NSURL URLWithString:@"/var/mobile"]];
        [stratosUserDefaults registerDefaults:kCDTSPreferencesDefaults];
        [stratosUserDefaults synchronize];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
        
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self.tableView setEditing:YES];
        [self.tableView setAllowsSelection:NO];
        
        [self setView:self.tableView];
        
        [self setTitle:@"Page Order"];
    }
    
    return self;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Page order";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Top to bottom represents left to right";
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    NSInteger index = indexPath.row;
    DebugLogC(@"Cell Index: %ld", (long)index);
    NSArray *pageOrder = [stratosUserDefaults stringArrayForKey:@"pageOrder"];
    
    cell.textLabel.text = pageOrder[index];
    //cell.imageView.image = iconForDescription(desc);
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *pageOrder = [[stratosUserDefaults stringArrayForKey:@"pageOrder"] mutableCopy];
    NSInteger sourceIndex = sourceIndexPath.row;
    NSInteger destIndex = destinationIndexPath.row;
    if (sourceIndex>destIndex) {
        NSString *cellToMove = [pageOrder objectAtIndex:sourceIndex];
        for (int i=sourceIndex; i>destIndex; i--) {
            [pageOrder replaceObjectAtIndex:i withObject:pageOrder[i-1]];
        }
        [pageOrder replaceObjectAtIndex:destIndex withObject:cellToMove];
    } else if (sourceIndex<destIndex) {
        NSString *cellToMove = [pageOrder objectAtIndex:sourceIndex];
        for (int i=sourceIndex; i<destIndex; i++) {
            [pageOrder replaceObjectAtIndex:i withObject:pageOrder[i+1]];
        }
        [pageOrder replaceObjectAtIndex:destIndex withObject:cellToMove];
    }
    
    [stratosUserDefaults setObject:pageOrder forKey:@"pageOrder"];
    [stratosUserDefaults synchronize];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.cortexdevteam.stratos.prefs-changed"), NULL, NULL, YES);
    //[tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

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