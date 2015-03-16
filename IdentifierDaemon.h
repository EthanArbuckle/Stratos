#import "Stratos.h"
#import "CDTSPreferences.h"

@interface IdentifierDaemon : NSObject 

@property (nonatomic, retain) NSMutableArray *appIdentifiers;
@property (nonatomic, retain) NSMutableArray *appSnapshots;
@property (nonatomic, retain) NSMutableDictionary *appCards;
@property UIWindow *sbWindow;

+ (id)sharedInstance;
- (UIImage *)appSnapshotForIdentifier:(NSString *)ident;
- (void)reloadApps;
- (UIImage *)preheatSnapshotForIndentifier:(NSString *)ident withController:(id)sliderController;
- (UIView *)switcherCardForIdentifier:(NSString *)identifier;
- (NSArray *)identifiers;
- (void)purgeCardCache;
- (BOOL)doesRequireReload;
- (BOOL)shouldShowHomescreenCard;
- (UIView *)enableHostingAndReturnViewForID:(NSString *)bundleID;
- (void)disableContextHostingForIdentifier:(NSString *)bundleID;

@end