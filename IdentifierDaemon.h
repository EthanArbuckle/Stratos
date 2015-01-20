#import "Stratos.h"

@interface IdentifierDaemon : NSObject

@property (nonatomic, retain) NSMutableArray *appIdentifiers;
@property (nonatomic, retain) NSMutableArray *appSnapshots;
@property (nonatomic, retain) NSMutableDictionary *appCards;

+ (id)sharedInstance;
- (UIImage *)appSnapshotForIdentifier:(NSString *)ident;
- (void)reloadApps;
- (UIView *)switcherCardForIdentifier:(NSString *)identifier;
- (NSArray *)identifiers;
- (void)purgeCardCache;

@end