#import <Foundation/Foundation.h>
#import "Common/Common.h"

@interface FBSystemServiceOpenApplicationRequest : NSObject
@property (nonatomic, copy) NSURL *URL;
@end

static NSString *const kSafariBundleID = @"com.apple.mobilesafari";
static NSString *const kReynardBundleID = @"com.minh-ton.Reynard";
static NSString *const kReynardURLScheme = @"reynard";

static BOOL enabled = NO;

static void loadPrefs(void) {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    enabled = [prefs objectForKey:kEnabledKey] ? [prefs boolForKey:kEnabledKey] : NO;
}

// Wrap http(s) URLs as reynard://open?url=<encoded> so iOS routes them via
// the scheme Reynard actually claims. Reynard's SceneDelegate decodes this
// form back to the original URL. Without this, iOS 14 LaunchServices drops
// the http(s) URL after ReynardDefault swaps the bundle ID, because Reynard
// doesn't register http/https handlers in its Info.plist.
static NSURL *wrapHTTPURLForReynard(NSURL *original) {
    NSString *scheme = original.scheme.lowercaseString;
    if (![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"]) {
        return nil;
    }
    NSCharacterSet *allowed = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encoded = [original.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    if (!encoded) return nil;
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://open?url=%@", kReynardURLScheme, encoded]];
}

%hook FBSystemServiceOpenApplicationRequest

- (void)setBundleIdentifier:(NSString *)bundleIdentifier {
    loadPrefs();
    if (enabled && [bundleIdentifier isEqualToString:kSafariBundleID]) {
        if ([self respondsToSelector:@selector(URL)] && [self respondsToSelector:@selector(setURL:)]) {
            NSURL *wrapped = wrapHTTPURLForReynard(self.URL);
            if (wrapped) self.URL = wrapped;
        }
        %orig(kReynardBundleID);
    } else {
        %orig;
    }
}

%end
