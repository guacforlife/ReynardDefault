#import <Foundation/Foundation.h>
#import "Common/Common.h"

// FrontBoardServices ground truth (iOS 14–16 runtime headers + the payload
// key confirmed by LorenzoPane/browserdefault): FBSystemServiceOpenApplication
// Request carries only bundleIdentifier/options/clientProcess/trusted, and a
// web link shows up in the options payload under the literal key
// "__PayloadURL" (= FBSOpenApplicationOptionKeyPayloadURL). Swapping the
// bundle identifier leaves the payload untouched, so the opened app receives
// the original URL directly — Reynard's SceneDelegate handles plain http(s).
@interface FBSOpenApplicationOptions : NSObject
@property (nonatomic, copy) NSDictionary *dictionary;
@end

@interface FBSystemServiceOpenApplicationRequest : NSObject
@property (nonatomic, copy) NSString *bundleIdentifier;
@property (nonatomic, copy) FBSOpenApplicationOptions *options;
@end

static NSString *const kReynardBundleID = @"com.minh-ton.Reynard";
static NSString *const kDefaultRedirectBundleID = @"com.apple.mobilesafari";
static NSString *const kPayloadURLKey = @"__PayloadURL";
static NSString *const kGlobalKey = @"global";

// The proven v1.5.1 swap list: browsers that links are normally handed to.
static NSString *const kBrowserBundleIDs[] = {
	@"com.apple.mobilesafari",
	@"org.mozilla.ios.Firefox",
	@"com.google.chrome.ios",
	@"com.brave.ios.browser"
};

static BOOL enabled = NO;
static BOOL globalRedirect = YES;
static NSString *pendingOriginalBundleID = nil;
static BOOL restoringBundleID = NO;

static void loadPrefs(void) {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    enabled = [prefs objectForKey:kEnabledKey] ? [prefs boolForKey:kEnabledKey] : NO;
    id globalValue = [prefs objectForKey:kGlobalKey];
    globalRedirect = globalValue ? [globalValue boolValue] : YES;
}

static BOOL isBrowserTarget(NSString *bundleIdentifier) {
	for (size_t i = 0; i < sizeof(kBrowserBundleIDs) / sizeof(kBrowserBundleIDs[0]); i++) {
		if ([kBrowserBundleIDs[i] isEqualToString:bundleIdentifier]) return YES;
	}
	return NO;
}

// Per-app redirect sources ("redirect.<bundle id>" keys, written by Reynard's
// "Default Browser Redirect" screen). Only consulted when the global switch
// is off. With nothing configured, Safari is the default source.
static BOOL shouldRedirectBundle(NSString *bundleIdentifier) {
	NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
	id value = [prefs objectForKey:[@"redirect." stringByAppendingString:bundleIdentifier]];
	if (value != nil) return [value boolValue];
	return [bundleIdentifier isEqualToString:kDefaultRedirectBundleID];
}

// A plain browser launch (icon tap) is only skipped when the options payload
// is already populated and carries no URL entry. Anything inconclusive falls
// back to the proven v1.5.1 swap so the redirect never silently dies again.
static BOOL isConfirmedPlainLaunch(FBSystemServiceOpenApplicationRequest *self) {
	if (![self respondsToSelector:@selector(options)]) return NO;
	FBSOpenApplicationOptions *options = [self options];
	if (options == nil || ![options respondsToSelector:@selector(dictionary)]) return NO;
	NSDictionary *payload = [options dictionary];
	if (payload == nil) return NO;
	return [payload objectForKey:kPayloadURLKey] == nil;
}

%hook FBSystemServiceOpenApplicationRequest

- (void)setBundleIdentifier:(NSString *)bundleIdentifier {
	loadPrefs();
	if (restoringBundleID) {
		%orig;
		return;
	}

	pendingOriginalBundleID = nil;
	if (enabled
		&& bundleIdentifier != nil
		&& ![bundleIdentifier isEqualToString:kReynardBundleID]
		&& (globalRedirect || shouldRedirectBundle(bundleIdentifier))
		&& (isBrowserTarget(bundleIdentifier) || shouldRedirectBundle(bundleIdentifier))
		&& !isConfirmedPlainLaunch(self)) {
		// Swap now (the v1.5.1-proven behavior) but remember the original:
		// if the options payload later turns out to carry no web link, the
		// setOptions: hook below undoes this so plain browser launches open
		// the real browser.
		pendingOriginalBundleID = bundleIdentifier;
		bundleIdentifier = kReynardBundleID;
	}
	%orig;
}

- (void)setOptions:(FBSOpenApplicationOptions *)options {
	%orig;
	if (pendingOriginalBundleID == nil) return;

	NSString *original = [pendingOriginalBundleID copy];
	pendingOriginalBundleID = nil;

	NSDictionary *payload = nil;
	if ([options respondsToSelector:@selector(dictionary)]) {
		payload = [options dictionary];
	}

	// No URL entry in the payload: this open is a plain launch, so hand it
	// back to the originally requested browser. Web-link opens keep the swap
	// and receive the original URL through the untouched payload.
	if (payload != nil && [payload objectForKey:kPayloadURLKey] == nil) {
		restoringBundleID = YES;
		[self setBundleIdentifier:original];
		restoringBundleID = NO;
	}
}

%end
