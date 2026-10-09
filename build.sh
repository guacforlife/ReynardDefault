#!/bin/bash
# Build both debs into packages/ from the same source, so their versions always match:
#   iphoneos-arm64   rootless, stock Theos (~/theos). Rootless Dopamine and palera1n install it
#                    as is; a roothide phone can only take it through the RootHide Patcher.
#   iphoneos-arm64e  native roothide, ~/theos-roothide, signed with codesign. Roothide Sileo
#                    (Dopamine roothide, Relaxin) picks it over the arm64 deb whatever the
#                    versions, and installs it with no conversion.
# Publish the two together: roothide Sileo prefers arm64e even when the arm64 deb is newer, so
# bumping only one leaves the other kind of phone behind.
#
# Then the roothide deb is checked: nothing under var/jb, every Mach-O has arm64 and arm64e
# slices and both are signed, tweak filter plists are 644, and no file still names /var/jb.
# The Patcher used to rewrite /var/jb; a native build has nothing that does. A file that only
# keeps /var/jb as a rootless fallback goes in .roothide-varjb-ok, one deb path per line.
set -euo pipefail
cd "$(dirname "$0")"
BUILD_ROOTFUL=${BUILD_ROOTFUL:-1}   # 1 also builds iphoneos-arm (rootful, stock Theos)

clean() { find . -name .theos -type d -prune -exec rm -rf {} +; }
build() { env -i HOME="$HOME" PATH="$PATH" make package FINALPACKAGE=1 "$@"; }

# ldid-style entitlements (X_CODESIGN_FLAGS = -Sfile) become codesign flags for roothide. The
# path stays relative to the Makefile that names it, which is where make runs for that target.
sign=(TARGET_CODESIGN=codesign "TARGET_CODESIGN_FLAGS=-f -s -")
while read -r target ents; do
    sign+=("${target}_CODESIGN_FLAGS=-f -s - --entitlements $ents")
done < <(find . -name Makefile -not -path '*/.theos/*' -exec \
    sed -n 's/^\([A-Za-z0-9_]*\)_CODESIGN_FLAGS[ :?]*= *-S\([^ ]*\) *$/\1 \2/p' {} +)

clean
build THEOS="$HOME/theos" THEOS_PACKAGE_SCHEME=rootless
if [ "$BUILD_ROOTFUL" = 1 ]; then clean; build THEOS="$HOME/theos" THEOS_PACKAGE_SCHEME=; fi
clean
build THEOS="$HOME/theos-roothide" DEBUG=0 THEOS_PACKAGE_SCHEME=roothide "${sign[@]}"
clean

fail() { echo "build.sh: $*" >&2; exit 1; }
id=$(sed -n 's/^Package: //p' control)
version=$(sed -n 's/^Version: //p' control)
rh="packages/${id}_${version}_iphoneos-arm64e.deb"
for deb in "packages/${id}_${version}_iphoneos-arm64.deb" "$rh"; do
    [ -f "$deb" ] || fail "missing $deb"
done
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
root="$work/deb"
dpkg-deb -R "$rh" "$root"
[ "$(sed -n 's/^Architecture: //p' "$root/DEBIAN/control")" = iphoneos-arm64e ] || fail "$rh: wrong Architecture"
[ ! -e "$root/var/jb" ] || fail "$rh: has files under var/jb"
while IFS= read -r -d '' f; do
    rel=${f#"$root"/}
    case $(file -b "$f") in
    *Mach-O*)
        lipo "$f" -verify_arch arm64 arm64e || fail "$rh: $rel needs arm64 and arm64e slices"
        # Verify a copy: inside a .bundle, codesign demands sealed resources, which no
        # jailbreak bundle ships (roothide re-signs on install without them).
        cp "$f" "$work/macho"
        for a in arm64 arm64e; do
            codesign --verify --arch "$a" "$work/macho" || fail "$rh: $rel $a slice not signed"
        done ;;
    esac
    case $rel in
    Library/MobileSubstrate/DynamicLibraries/*.plist)
        # ElleKit silently skips a filter plist that is not world-readable.
        [ "$(stat -f %Lp "$f")" = 644 ] || fail "$rh: $rel is not 644" ;;
    esac
    if grep -q --binary-files=text /var/jb "$f" && ! grep -qxF "$rel" .roothide-varjb-ok 2>/dev/null; then
        fail "$rh: $rel still names /var/jb"
    fi
done < <(find "$root" -type f -print0)
ls packages/"${id}_${version}"_*.deb | sed 's/^/ok  /'
