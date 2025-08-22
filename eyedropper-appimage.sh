#!/bin/sh

set -eux

ARCH="$(uname -m)"
PACKAGE=eyedropper
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

VERSION=$(pacman -Q "$PACKAGE" | awk 'NR==1 {print $2; exit}')
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

# Variables used by quick-sharun
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME="$PACKAGE"-"$VERSION"-anylinux-"$ARCH".AppImage
export DESKTOP=/usr/share/applications/com.github.finefindus.eyedropper.desktop
export ICON=/usr/share/icons/hicolor/scalable/apps/com.github.finefindus.eyedropper.svg
export DEPLOY_OPENGL=1
export STARTUPWMCLASS=eyedropper # For Wayland, this is 'com.github.finefindus.eyedropper', so this needs to be changed in desktop file manually by the user in that case until some potential automatic fix exists for this

# DEPLOY ALL LIBS
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/eyedropper

## Further debloat locale
find ./AppDir/share/locale -type f ! -name '*glib*' ! -name '*eyedropper*' -delete

## Set gsettings to save to keyfile, instead to dconf
echo "GSETTINGS_BACKEND=keyfile" >> ./AppDir/.env

## Copy files needed for search integration
mkdir -p ./AppDir/share/gnome-shell/search-providers/
cp -v /usr/share/gnome-shell/search-providers/com.github.finefindus.eyedropper.search-provider.ini ./AppDir/share/gnome-shell/search-providers/com.github.finefindus.eyedropper.search-provider.ini
mkdir -p ./AppDir/share/dbus-1/services/
cp -v /usr/share/dbus-1/services/com.github.finefindus.eyedropper.SearchProvider.service ./AppDir/share/dbus-1/services/com.github.finefindus.eyedropper.SearchProvider.service

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage
