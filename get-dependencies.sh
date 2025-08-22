#!/bin/sh

set -eux

sed -i 's/DownloadUser/#DownloadUser/g' /etc/pacman.conf

ARCH="$(uname -m)"

if [ "$ARCH" = 'x86_64' ]; then
	PKG_TYPE='x86_64.pkg.tar.zst'
else
	PKG_TYPE='aarch64.pkg.tar.xz'
fi

LIBXML_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/libxml2-iculess-$PKG_TYPE"
OPUS_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/opus-nano-$PKG_TYPE"
MESA_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/mesa-nano-$PKG_TYPE"
INTEL_MEDIA_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/intel-media-mini-$PKG_TYPE" 
GTK4_X86_URL="https://d.uguu.se/UuKlGNxW.zst"
GTK4_ARM_URL="https://n.uguu.se/GKbGQMUN.xz"

echo "Installing build dependencies for sharun & AppImage integration..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	base-devel \
	curl \
	desktop-file-utils \
	git \
	libxtst \
	wget \
	xorg-server-xvfb \
	zsync
echo "Installing the app & it's dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	eyedropper

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$LIBXML_URL"  -O  ./libxml2-iculess.pkg.tar.zst
wget --retry-connrefused --tries=30 "$OPUS_URL"    -O  ./opus-nano.pkg.tar.zst
wget --retry-connrefused --tries=30 "$MESA_URL"        -O  ./mesa.pkg.tar.zst

if [ "$ARCH" = 'x86_64' ]; then
	wget --retry-connrefused --tries=30 "$INTEL_MEDIA_URL"  -O ./intel-media.pkg.tar.zst
    wget --retry-connrefused --tries=30 "$GTK4_X86_URL"        -O  ./gtk4.pkg.tar.zst
else
    wget --retry-connrefused --tries=30 "$GTK4_ARM_URL"        -O  ./gtk4.pkg.tar.xz
fi

pacman -U --noconfirm ./*.pkg.tar.*
rm -f ./*.pkg.tar.*

echo "All done!"
echo "---------------------------------------------------------------"
