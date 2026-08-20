#!/bin/zsh
# MTI weekly AI analysis launcher (Mondays 11:00 via launchd)
set -euo pipefail

export PATH="/usr/local/bin:/opt/homebrew/bin:${HOME}/.npm-global/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="${HOME}/Library/Logs/mti-ai-analysis"
mkdir -p "$LOG_DIR"

# Optional mount hook from config
CFG="${MTI_AI_CONFIG:-$HOME/.config/mti-ai-analysis/config.json}"
if [[ -f "$CFG" ]]; then
  MOUNT_SCRIPT="$(/usr/bin/python3 - <<'PY' "$CFG"
import json,sys
from pathlib import Path
p=Path(sys.argv[1])
try:
  c=json.loads(p.read_text())
  print(c.get('mount_script') or '')
except Exception:
  print('')
PY
)"
  if [[ -n "${MOUNT_SCRIPT}" ]]; then
    MOUNT_SCRIPT="${MOUNT_SCRIPT/#\~/$HOME}"
    if [[ -x "$MOUNT_SCRIPT" || -f "$MOUNT_SCRIPT" ]]; then
      /bin/zsh "$MOUNT_SCRIPT" >>"$LOG_DIR/mount.log" 2>&1 || true
      sleep 2
    fi
  fi
fi

/usr/bin/python3 "$SKILL_DIR/scripts/mti_weekly_ust_analysis.py" \
  >>"$LOG_DIR/weekly.launchd.out.log" 2>>"$LOG_DIR/weekly.launchd.err.log"
