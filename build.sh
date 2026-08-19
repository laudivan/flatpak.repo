#!/usr/bin/env bash

APP_ID="io.github.laudivan.antigravity"

PROJECT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

BUILD_DIR="/tmp/antigravity_flatpak"

[ -d "${BUILD_DIR}" ] && sudo rm -fr "${BUILD_DIR}"

mkdir -p "${BUILD_DIR}" /tmp/repo

cp -r "${PROJECT_DIR}"/* "${BUILD_DIR}/"

cd "${BUILD_DIR}"

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
