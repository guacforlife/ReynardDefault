# ReynardDefault

A jailbreak tweak that redirects web links to [Reynard](https://github.com/minh-ton/reynard-browser), a Firefox-based browser for iOS, so it can be used as the default browser.

When enabled, every http(s) link an app hands to a browser is opened in Reynard instead, while the browsers themselves stay launchable.

## Features

- **Global web-link redirect** — every http(s) link opened by any app goes to Reynard (`Redirect All Web Links` switch, on by default)
- **Browsers stay launchable** — plain browser launches (icon taps) are detected via the open request's options payload (no `__PayloadURL` entry) and restored to the original browser
- **Per-app redirect sources** — `redirect.<bundle id>` keys in the `com.guacforlife.reynarddefaultprefs` suite add redirect sources for any app (Safari is the default source; our Reynard fork ships a picker UI for these keys)
- **Settings toggles** — inline switches in the main Settings list via PreferenceLoader (no preference bundle, so nothing to load and crash when the entry is tapped)
- **Control Centre toggle** — quick toggle via CCSupport module

### How the redirect works

`FBSystemServiceOpenApplicationRequest` (FrontBoard) has no URL property; the web link of an open travels in the options payload under the literal key `__PayloadURL` (`FBSOpenApplicationOptionKeyPayloadURL`). The tweak swaps the requested bundle identifier for Reynard's and leaves the payload untouched, so Reynard receives the original URL directly. When the payload turns out to carry no web link (a plain launch), the original target is restored.

## Requirements

- A jailbroken iOS device — supports **rootless** (Dopamine/Roothide) and **rootful** (unc0ver, palera1n rootful)
- [Reynard](https://github.com/minh-ton/reynard-browser) browser installed
- [CCSupport](https://moreinfo.thebigboss.org/moreinfo/depiction.php?file=ccsupportDp) (for Control Centre toggle)
- [PreferenceLoader](https://github.com/PoomSmart/PreferenceLoader) (for Settings pane)

## Building

Requires [Theos](https://theos.dev/).

```bash
export THEOS=~/theos
cd ReynardDefault
make rootless   # Dopamine / Roothide
make rootful    # unc0ver / palera1n rootful
make both       # builds both variants side-by-side
```

Builds land in `packages/` as `*_iphoneos-arm64.deb` (rootless) and `*_iphoneos-arm.deb` (rootful). Rootless debs installed via Sileo on Roothide are auto-patched; manual installs need the Roothide Patcher app first.

GitHub Actions builds both variants on every push and attaches the debs to tag releases.

## Supported iOS versions

The tweak targets iOS 14.0+ (`TARGET = iphone:clang:14.5:14.0`) in both rootless and rootful variants, on arm64 and arm64e. The hooked API (`FBSystemServiceOpenApplicationRequest` in FrontBoard/SpringBoard) exists on iOS 13 through 16, and the inline Settings switch renders on every iOS version PreferenceLoader supports — including the iPadOS split-view Settings, where a preference-bundle-based pane can crash the Settings app on load.

> **Tip:** Reynard's jailbroken/TrollStore builds embed the `com.apple.developer.web-browser` entitlement, so on some iOS versions Reynard already appears natively under *Settings → Safari → Default Browser App* — check there first; this tweak is only needed when it doesn't.

## Tested Environments

| Device | iOS | Jailbreak | Variant | Status |
|--------|-----|-----------|---------|--------|
| iPad Pro (2021) | iPadOS 15.1 | rootless | rootless (`iphoneos-arm64`) | Working — Settings switch renders and toggles, Safari links open in Reynard (previously crashed with the preference bundle) |
| iPhone 14 Pro Max | 16.3.1 | Dopamine (Roothide) | rootless (`iphoneos-arm64`) | Working |
| iPhone 7 | 15.7.7 | Dopamine | rootless (`iphoneos-arm64`) | Working |
| iPhone 7 Plus | 14.8.1 | Taurine 1.1.7-3 | rootful (`iphoneos-arm`) | Working |

Tweak injection via ElleKit (rootless) or substrate (rootful) on arm64 / arm64e.

## License

This project is licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.
