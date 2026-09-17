#!/usr/bin/env bash
# Made without AI

APP_ID="io.github.laudivan.antigravity"

APP_VERSION="2.14.0"

BUILD="5449404535144448"

PROJECT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

BUILD_DIR="/tmp/unofficial-antigravity.flatpak"

BASE_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub"

rm -f ../repo/${APP_ID}.flatpak

[ -d "$BUILD_DIR" ] && sudo rm -fr "$BUILD_DIR"

# mkdir -p "${BUILD_DIR}"

cp -dpr "$PROJECT_DIR" "$BUILD_DIR"

# magick -density 90 -background none "$APP_ID.svg" "$APP_ID.png"

DT="$(date +%Y-%m-%d)"

sed -i \
    -e "s/{version}/$APP_VERSION/g" \
    -e "s/{build}/$BUILD/g" \
    -e "s/{date}/$DT/g" \
    "$BUILD_DIR/$APP_ID.metainfo.xml"

sed -i \
    -e "s/{version}/$APP_VERSION/g" \
    -e "s/{build}/$BUILD/g" \
    "$BUILD_DIR/$APP_ID.yaml"

for ARCH in {x64,arm}; do
    FILE="antigravity-$APP_VERSION-$BUILD-$ARCH.tar.gz"

    URL="$BASE_URL/$APP_VERSION-$BUILD/linux-$ARCH/Antigravity.tar.gz"

    curl -sSL -o "$BUILD_DIR/$FILE" "$URL"

    sed -i \
        -e "s/{size_$ARCH}/$(stat -c %s "$BUILD_DIR/$FILE")/" \
        -e "s/{sha_$ARCH}/$(sha256sum "$BUILD_DIR/$FILE" | cut -d ' ' -f1)/" \
        "$BUILD_DIR/$APP_ID.yaml"
done

mkdir -p "$BUILD_DIR/repo"

sudo sh <<SCRIPT
    cd "$BUILD_DIR"

    flatpak-builder --install-deps-from=flathub \
	    --repo=repo --force-clean \
	    build "$APP_ID.yaml"

    flatpak build-bundle \
	    ../repo \
	    "$APP_ID.flatpak" \
	    "$APP_ID"

	chown $USER:$USER -R "$APP_ID.flatpak"

	[ -f "$PROJECT_DIR/$APP_ID.flatpak" ] && rm -f "$PROJECT_DIR/$APP_ID.flatpak"

	cp -dpf "$BUILD_DIR/$APP_ID.flatpak" "$PROJECT_DIR/$APP_ID.flatpak"

	cd /

	# rm -fr "$BUILD_DIR"
SCRIPT

# flatpak --user install --assumeyes "${APP_ID}.flatpak"

# flatpak --user run \
#    --verbose --devel --log-a11y-bus --log-session-bus --log-system-bus \
#    "${APP_ID}"
