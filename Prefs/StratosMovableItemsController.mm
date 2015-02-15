#import "StratosMovableItemsController.h"
@implementation StratosMovableItemsController

- (id)initForContentSize:(CGSize)size
{
    self = [super init];
    if (self)
    {
        preferences = [[HBPreferences alloc] initWithIdentifier:kCDTSPreferencesDomain];
        [preferences registerDefaults:kCDTSPreferencesDefaults];
        [preferences synchronize];


        names = @[
            localized(@"SWITCHER_CARDS", @"Switcher Cards"),
            localized(@"CONTROL_CENTER", @"Control Center"),
            localized(@"MEDIA_CONTROLS", @"Media Controls"),
        ];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
        
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self.tableView setEditing:YES];
        [self.tableView setAllowsSelection:NO];
        
        [self setView:self.tableView];
        
        [self setTitle:localized(@"PAGE_ORDER", @"Page order")];
    }
    
    return self;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return localized(@"PAGE_ORDER", @"Page order");
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return localized(@"TOP_TO_BOTTOM", @"Top to bottom represents left to right");
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier] ?: [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    NSInteger index = indexPath.row;
    DebugLogC(@"Cell Index: %ld", (long)index);
    NSArray *pageOrder = (NSArray *)[preferences objectForKey:@"pageOrder"];
    
    cell.textLabel.text = [names objectAtIndex:([pageOrder[index] intValue]-1)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"hi");
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
    NSMutableArray *pageOrder = [((NSArray *)[preferences objectForKey:@"pageOrder"]) mutableCopy];
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
    
    [preferences setObject:pageOrder forKey:@"pageOrder"];
    [preferences synchronize];
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        (CFStringRef)[kCDTSPreferencesDomain stringByAppendingPathComponent:@"ReloadPrefs"],
        NULL,
        NULL,
        YES
    );
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