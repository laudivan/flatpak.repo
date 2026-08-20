#!/usr/bin/env bash
# Made without AI

APP_ID="io.github.laudivan.antigravity"

APP_VERSION="2.8.1"

BUILD="6512087774658560"

PROJECT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

BUILD_DIR="/tmp/unofficial-antigravity.flatpak"

BASE_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub"

FILE="Antigravity.tar.gz"

rm -fr repo

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

for ARCH in {arm,x64}; do
    URL="$BASE_URL/$APP_VERSION-$BUILD/linux-$ARCH/$FILE"

    curl -sSL -o "$BUILD_DIR/$FILE" "$URL"

    SIZE="$(stat -c %s "$BUILD_DIR/$FILE")"

    SHA="$(sha256sum "$BUILD_DIR/$FILE" | cut -d ' ' -f1)"

    sed -i \
        -e "s/{size_$ARCH}/$SIZE/" \
        -e "s/{sha_$ARCH}/$SHA/" \
        "$BUILD_DIR/$APP_ID.yaml"

    rm -f "$BUILD_DIR/$FILE"
done

mkdir -p "$BUILD_DIR/repo"

sudo sh <<SCRIPT
    cd "$BUILD_DIR"

    flatpak-builder --install-deps-from=flathub \
	    --repo=repo --force-clean \
	    build "$APP_ID.yaml"

    flatpak build-bundle \
	    repo \
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
