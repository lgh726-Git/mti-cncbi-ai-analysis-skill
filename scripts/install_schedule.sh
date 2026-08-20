#!/bin/zsh
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LABEL="com.lgh726.mti-ai-analysis.weekly"
PLIST_SRC="$SKILL_DIR/launchd/${LABEL}.plist"
PLIST_DST="$HOME/Library/LaunchAgents/${LABEL}.plist"
LOG_DIR="$HOME/Library/Logs/mti-ai-analysis"

mkdir -p "$HOME/Library/LaunchAgents" "$LOG_DIR" "$HOME/.config/mti-ai-analysis"

# Materialize plist with absolute paths
sed -e "s|__SKILL_DIR__|${SKILL_DIR}|g" -e "s|__HOME__|${HOME}|g" \
  "$PLIST_SRC" > "$PLIST_DST"

chmod +x "$SKILL_DIR/scripts/mti-ai-analysis-weekly.sh"
chmod +x "$SKILL_DIR/scripts/mti_weekly_ust_analysis.py"
chmod +x "$SKILL_DIR/scripts/install_schedule.sh"
chmod +x "$SKILL_DIR/scripts/uninstall_schedule.sh"

# Seed config if missing
if [[ ! -f "$HOME/.config/mti-ai-analysis/config.json" ]]; then
  cp "$SKILL_DIR/assets/config.example.json" "$HOME/.config/mti-ai-analysis/config.json"
  echo "Created ~/.config/mti-ai-analysis/config.json — edit paths before relying on schedule."
fi

# Reload launchd job
UID_NUM="$(id -u)"
launchctl bootout "gui/${UID_NUM}" "$LABEL" 2>/dev/null || true
launchctl bootout "gui/${UID_NUM}" "$PLIST_DST" 2>/dev/null || true
if launchctl bootstrap "gui/${UID_NUM}" "$PLIST_DST" 2>/dev/null; then
  echo "Loaded launchd job: $LABEL"
else
  launchctl load "$PLIST_DST"
  echo "Loaded launchd job via load: $LABEL"
fi

echo "Schedule: every Monday 11:00 local time"
echo "Plist: $PLIST_DST"
echo "Logs:  $LOG_DIR"
echo "Test:  python3 $SKILL_DIR/scripts/mti_weekly_ust_analysis.py"
