#import "Stratos.h"

@interface IdentifierDaemon : NSObject

@property (nonatomic, retain) NSMutableArray *appIdentifiers;
@property (nonatomic, retain) NSMutableArray *appSnapshots;
@property (nonatomic, retain) NSMutableDictionary *appCards;

+ (id)sharedInstance;
- (UIImage *)appSnapshotForIdentifier:(NSString *)ident;
- (void)reloadApps;
- (UIImage *)preheatSnapshotForIndentifier:(NSString *)ident withController:(id)sliderController;
- (UIView *)switcherCardForIdentifier:(NSString *)identifier;
- (NSArray *)identifiers;
- (void)purgeCardCache;

@end