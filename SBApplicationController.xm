#import "Stratos.h"


//iOS 8 compat stuff
%group iOS8

//iOS 8 no longer has applicationWithDisplayIdentifier, so create this method and
//return the bundlIdent method instead
%hook SBApplicationController

%new
- (id)applicationWithDisplayIdentifier:(NSString *)ident {
	
	if (self) {

		return [self applicationWithBundleIdentifier:ident];
	}

	return nil;
}

%end

%end

%ctor {

	@autoreleasepool {
		
		//do that hacky iOS 8 stuff
		if (IS_OS_8_OR_LATER) {
			%init(iOS8);
		}

	}

}