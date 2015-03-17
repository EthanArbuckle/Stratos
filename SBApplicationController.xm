#import "Stratos.h"

//iOS 8 no longer has applicationWithDisplayIdentifier, so create this method and
//return the bundlIdent method instead
%hook SBApplicationController

%new
- (id)stratos_applicationWithDisplayIdentifier:(NSString *)ident {

	if (self) {

		return [self respondsToSelector:@selector(applicationWithDisplayIdentifier:)] ? [self applicationWithDisplayIdentifier:ident] : [self applicationWithBundleIdentifier:ident];
	}

	return nil;
}

%end
