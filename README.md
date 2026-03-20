# ReynardDefault

A jailbreak tweak that redirects Safari URL opens to [Reynard](https://github.com/minh-ton/reynard-browser), a Firefox-based browser for iOS.

When enabled, any link that would normally open in Safari is intercepted at the SpringBoard level and opened in Reynard instead.

## Features

- **Safari redirect** — hooks `FBSystemServiceOpenApplicationRequest` in SpringBoard to swap the bundle identifier
- **Settings toggle** — enable/disable from Settings via PreferenceLoader
- **Control Centre toggle** — quick toggle via CCSupport module

## Requirements

- iOS 16.x with [Dopamine](https://ellekit.space/dopamine/) jailbreak (Roothide)
- [Reynard](https://github.com/minh-ton/reynard-browser) browser installed
- [CCSupport](https://moreinfo.thebigboss.org/moreinfo/depiction.php?file=ccsupportDp) (for Control Centre toggle)
- [PreferenceLoader](https://github.com/PoomSmart/PreferenceLoader) (for Settings pane)

## Building

Requires [Theos](https://theos.dev/) with rootless SDK.

```bash
export THEOS=~/theos
cd ReynardDefault
make clean && make package
```

The resulting `.deb` must be processed through the Roothide Patcher app before installation.

## Tested Environment

| Component | Version |
|-----------|---------|
| iOS | 16.3.1 |
| Jailbreak | Dopamine (Roothide) |
| Tweak injection | ElleKit |
| Architecture | arm64 / arm64e |
| Package scheme | rootless (`iphoneos-arm64`) |

## License

This project is licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.
