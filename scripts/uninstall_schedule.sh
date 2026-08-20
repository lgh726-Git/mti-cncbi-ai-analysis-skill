#!/bin/zsh
set -euo pipefail

LABEL="com.lgh726.mti-ai-analysis.weekly"
PLIST_DST="$HOME/Library/LaunchAgents/${LABEL}.plist"
UID_NUM="$(id -u)"

launchctl bootout "gui/${UID_NUM}" "$LABEL" 2>/dev/null || true
launchctl bootout "gui/${UID_NUM}" "$PLIST_DST" 2>/dev/null || true
launchctl unload "$PLIST_DST" 2>/dev/null || true
rm -f "$PLIST_DST"
echo "Removed launchd job: $LABEL"
