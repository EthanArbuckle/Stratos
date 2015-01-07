#import "Stratos.h"

@interface IdentifierDaemon : NSObject

@property (nonatomic, retain) NSMutableArray *appIdentifiers;
@property (nonatomic, retain) NSMutableArray *appSnapshots;

+ (id)sharedInstance;
- (UIImage *)appSnapshotForIdentifier:(NSString *)ident;
- (void)reloadApps;
- (NSArray *)identifiers;

@end