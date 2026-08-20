#!/usr/bin/env bash
# Made without AI

APP_ID="io.github.laudivan.antigravity"

APP_VERSION="2.8.1"

BUILD="6512087774658560"

PROJECT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

BUILD_DIR="/tmp/antigravity_flatpak"

BASE_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub"

FILE="Antigravity.tar.gz"

[ -d "${BUILD_DIR}" ] && sudo rm -fr "${BUILD_DIR}"

[ -d /tmp/repo ] && sudo rm -fr /tmp/repo

mkdir -p "${BUILD_DIR}" /tmp/repo

cp -r "${PROJECT_DIR}"/* "${BUILD_DIR}/"

cd "${BUILD_DIR}"

magick -density 90 -background none "${APP_ID}.svg" "${APP_ID}.png"

sed "s/{version}/${APP_VERSION}/" "${APP_ID}.metainfo.xml"

sed "s/{build}/${BUILD}/" "${APP_ID}.metainfo.xml"

sed "s/{build}/$(date +%Y-%m-%d)/" "${APP_ID}.metainfo.xml"

for ARCH in {arm,x64}; do
    URL="${BASE_URL}/${APP_VERSION}-${BUILD}/linux-${ARCH}/${FILE}"

    curl -sSL -o "${FILE}" "${URI}"

    SIZE="$(stat -c %s "${FILE}")"

    SHA256="$(sha256sum "${FILE}" | cut -d ' ' -f1)"

    sed "s/<url-${ARCH}>/${URI}/" "${APP_ID}.yaml"

    sed "s/<size-${ARCH}>/${SIZE}/" "${APP_ID}.yaml"

    sed "s/<sha-${ARCH}>/${SHA256}/" "${APP_ID}.yaml"

    rm -f "${FILE}"
done

sudo \
    flatpak-builder --install-deps-from=flathub \
	    --repo=/tmp/repo --force-clean \
	    build "${APP_ID}.yaml" && \
    flatpak build-bundle \
	    --runtime-repo=https://dl.flathub.org/repo/flathub.flatpakrepo \
	    /tmp/repo \
	    "/tmp/repo/${APP_ID}.flatpak" \
	    "${APP_ID}" && \
	mv /tmp/repo "${PROJECT_DIR}" && \
	chown $USER:$USER -R "${PROJECT_DIR}/repo" && \
	rm -fr "${BUILD_DIR}"

flatpak --user install --assumeyes "${PROJECT_DIR}/repo" "${APP_ID}"

flatpak --user run \
    --verbose --devel --log-a11y-bus --log-session-bus --log-system-bus \
    "${APP_ID}"
