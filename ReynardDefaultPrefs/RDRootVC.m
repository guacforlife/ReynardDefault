#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "../Common/Common.h"

@interface RDRootVC : PSListController
@end

@implementation RDRootVC

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    [prefs setObject:value forKey:specifier.properties[@"key"]];
    [super setPreferenceValue:value specifier:specifier];
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    id value = [prefs objectForKey:specifier.properties[@"key"]];
    if (!value) {
        return specifier.properties[@"default"];
    }
    return value;
}

@end
