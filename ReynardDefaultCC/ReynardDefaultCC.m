#import "ReynardDefaultCC.h"

@implementation ReynardDefaultCC {
    BOOL _selected;
}

- (BOOL)isSelected {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    _selected = [prefs objectForKey:kEnabledKey] ? [prefs boolForKey:kEnabledKey] : NO;
    return _selected;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    [prefs setBool:selected forKey:kEnabledKey];
    [prefs synchronize];
    [super refreshState];
}

- (UIImage *)iconGlyph {
    return [UIImage imageNamed:@"icon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

- (UIColor *)selectedColor {
    return [UIColor systemOrangeColor];
}

@end
