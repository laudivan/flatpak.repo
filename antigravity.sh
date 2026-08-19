#!/bin/bash
set -euo pipefail

# Enable Wayland support automatically when available
export ELECTRON_OZONE_PLATFORM_HINT="auto"

# Launch binary via zypak-wrapper for Chromium/Electron sandbox integration
exec zypak-wrapper /app/extra/antigravity "$@"
