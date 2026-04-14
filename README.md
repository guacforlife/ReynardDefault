# ReynardDefault

A jailbreak tweak that redirects Safari URL opens to [Reynard](https://github.com/minh-ton/reynard-browser), a Firefox-based browser for iOS.

When enabled, any link that would normally open in Safari is intercepted at the SpringBoard level and opened in Reynard instead.

## Features

- **Safari redirect** — hooks `FBSystemServiceOpenApplicationRequest` in SpringBoard to swap the bundle identifier
- **Settings toggle** — enable/disable from Settings via PreferenceLoader
- **Control Centre toggle** — quick toggle via CCSupport module

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

## Tested Environments

| iOS | Jailbreak | Variant | Status |
|-----|-----------|---------|--------|
| 16.3.1 | Dopamine (Roothide) | rootless (`iphoneos-arm64`) | Working |
| 15.7.7 | Dopamine (Roothide) | rootless (`iphoneos-arm64`) | Working |

Tweak injection via ElleKit on arm64 / arm64e.

The rootful variant (`iphoneos-arm`) builds cleanly but has not yet been tested on unc0ver / palera1n rootful — feedback welcome via issues.

## License

This project is licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.
