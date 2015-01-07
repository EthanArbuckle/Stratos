//
//  DebugLog.h
//  NSLog-ing my way.
//
//  DebugLog()			print Class, Selector, Comment				(ObjC only)
//  DebugLog0			print Class, Selector						(ObjC only)
//  DebugLogMore()		print Filename, Line, Signature, Comment	(ObjC only)
//  DebugLogC(s, ...)	print Comment								(C, ObjC)
//
//  Sticktron 2014
//
#define DEBUG

#ifdef DEBUG

// Default Prefix
#ifndef DEBUG_PREFIX
	#define DEBUG_PREFIX @"🌎 [nighthawke 0.01]"
#endif


// Print styles

#define DebugLog(s, ...) \
	NSLog(@"%@ %@::%@ >> %@", DEBUG_PREFIX, \
		NSStringFromClass([self class]), \
		NSStringFromSelector(_cmd), \
		[NSString stringWithFormat:(s), ##__VA_ARGS__] \
	)

#define DebugLog0 \
	NSLog(@"%@ %@::%@", DEBUG_PREFIX, \
		NSStringFromClass([self class]), \
		NSStringFromSelector(_cmd) \
	)

#define DebugLogC(s, ...) \
	NSLog(@"%@ >> %@", DEBUG_PREFIX, \
		[NSString stringWithFormat:(s), ##__VA_ARGS__] \
	)

/*
#define DebugLogMore(s, ...) \
	NSLog(@"%@ %s:(%d) >> %s >> %@", \
		DEBUG_PREFIX, \
		[[NSString stringWithUTF8String:__FILE__] lastPathComponent], \
		__LINE__, \
		__PRETTY_FUNCTION__, \
		[NSString stringWithFormat:(s), \
		##__VA_ARGS__] \
	)
*/

#else

// Ignore macros
#define DebugLog(s, ...)
#define DebugLog0
#define DebugLogC(s, ...)
//#define DebugLogMore(s, ...)

#endif


//#define UA_SHOW_VIEW_BORDERS YES
//#define UA_showDebugBorderForViewColor(view, color) if (UA_SHOW_VIEW_BORDERS) { view.layer.borderColor = color.CGColor; view.layer.borderWidth = 1.0; }
//#define UA_showDebugBorderForView(view) UA_showDebugBorderForViewColor(view, [UIColor colorWithWhite:0.0 alpha:0.25])

