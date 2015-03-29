#import "Stratos.h"

//iOS 8 no longer has applicationWithDisplayIdentifier, so create this method and
//return the bundlIdent method instead

//iOS 8 no longer uses -displayIdent, so replace it with bundleIdent
%hook SBApplication

%new
- (id)stratos_displayIdentifier {

	return [self respondsToSelector:@selector(displayIdentifier)] ? [self displayIdentifier] : [self bundleIdentifier];
}

%end
