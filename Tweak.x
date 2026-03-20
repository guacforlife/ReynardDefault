#import <Foundation/Foundation.h>
#import "Common/Common.h"

static NSString *const kSafariBundleID = @"com.apple.mobilesafari";
static NSString *const kReynardBundleID = @"com.minh-ton.Reynard";

static BOOL enabled = NO;

static void loadPrefs(void) {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    enabled = [prefs objectForKey:kEnabledKey] ? [prefs boolForKey:kEnabledKey] : NO;
}

%hook FBSystemServiceOpenApplicationRequest

- (void)setBundleIdentifier:(NSString *)bundleIdentifier {
    loadPrefs();
    if (enabled && [bundleIdentifier isEqualToString:kSafariBundleID]) {
        %orig(kReynardBundleID);
    } else {
        %orig;
    }
}

%end
