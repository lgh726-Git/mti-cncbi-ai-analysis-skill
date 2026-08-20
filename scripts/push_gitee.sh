#!/bin/zsh
# Push/mirror this skill to Gitee.
# Usage:
#   export GITEE_TOKEN=your_private_token
#   export GITEE_OWNER=your_gitee_login   # optional, default: API user
#   bash scripts/push_gitee.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -z "${GITEE_TOKEN:-}" ]]; then
  echo "Set GITEE_TOKEN first (Gitee private token with projects scope)."
  echo "Create at: https://gitee.com/profile/personal_access_tokens"
  exit 1
fi

USER_JSON="$(curl -s -H "User-Agent: mti-skill" "https://gitee.com/api/v5/user?access_token=${GITEE_TOKEN}")"
OWNER="$(print -r -- "$USER_JSON" | /usr/bin/python3 -c 'import sys,json;print(json.load(sys.stdin).get("login",""))')"
if [[ -z "$OWNER" ]]; then
  echo "Invalid GITEE_TOKEN / cannot resolve user:"
  echo "$USER_JSON" | head -c 300; echo
  exit 1
fi
OWNER="${GITEE_OWNER:-$OWNER}"
REPO="mti-cncbi-ai-analysis-skill"
echo "Gitee owner=$OWNER repo=$REPO"

# Create repo if missing
CODE="$(curl -s -o /tmp/gitee_repo.json -w "%{http_code}" \
  "https://gitee.com/api/v5/repos/${OWNER}/${REPO}?access_token=${GITEE_TOKEN}")"
if [[ "$CODE" == "404" ]]; then
  echo "Creating Gitee repo..."
  curl -s -X POST "https://gitee.com/api/v5/user/repos" \
    -d "access_token=${GITEE_TOKEN}" \
    -d "name=${REPO}" \
    -d "description=MTI/CNCBI UST weekly AI analysis skill" \
    -d "has_issues=true" \
    -d "has_wiki=true" \
    --data-urlencode "homepage=https://github.com/lgh726-Git/mti-cncbi-ai-analysis-skill" \
    -d "public=1" >/tmp/gitee_create.json
  cat /tmp/gitee_create.json | /usr/bin/python3 -c 'import sys,json;d=json.load(sys.stdin);print(d.get("html_url") or d)'
else
  echo "Repo exists (HTTP $CODE)"
fi

REMOTE="https://oauth2:${GITEE_TOKEN}@gitee.com/${OWNER}/${REPO}.git"
if git remote get-url gitee >/dev/null 2>&1; then
  git remote set-url gitee "$REMOTE"
else
  git remote add gitee "$REMOTE"
fi

git push -u gitee main
# scrub token from remote url after push
git remote set-url gitee "https://gitee.com/${OWNER}/${REPO}.git"
echo "Done: https://gitee.com/${OWNER}/${REPO}"
