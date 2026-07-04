#!/bin/bash
# freellmapi health guardrail.
# The bots' entire LLM brain depends on this proxy answering on :3001.
# It silently crash-looped once (missing ENCRYPTION_KEY) and took both bots
# down. This checks the REAL service (not just "process alive"), logs status,
# auto-restarts on a dead port, and warns when no upstreams are healthy.
# Run via launchd ai.freellmapi.healthcheck every ~15 min.

set +e
DIR="/Users/axiom/Projects/systems/freellmapi"
DB="$DIR/server/data/freeapi.db"
LOG="$DIR/healthcheck.log"
STAMP="$(date '+%Y-%m-%d %H:%M:%S')"

TOKEN="$(/usr/bin/sqlite3 "$DB" "SELECT value FROM settings WHERE key='unified_api_key';" 2>/dev/null)"
HEALTHY="$(/usr/bin/sqlite3 "$DB" "SELECT count(*) FROM api_keys WHERE status='healthy';" 2>/dev/null)"

# Hit the real proxy: list models with the unified token.
CODE="$(/usr/bin/curl -s -o /dev/null -w '%{http_code}' -m 12 \
  http://127.0.0.1:3001/v1/models -H "Authorization: Bearer $TOKEN" 2>/dev/null)"

if [ "$CODE" = "200" ]; then
  echo "$STAMP OK  proxy=200 healthy_upstreams=$HEALTHY" >> "$LOG"
  # Warn (don't restart) if the proxy is up but every upstream is dead.
  if [ "${HEALTHY:-0}" -eq 0 ]; then
    echo "$STAMP WARN proxy up but 0 healthy upstreams — bots will fail over to local gemma4:e4b" >> "$LOG"
  fi
else
  echo "$STAMP FAIL proxy=$CODE — attempting restart of ai.freellmapi" >> "$LOG"
  /bin/launchctl kickstart -k "gui/$(id -u)/ai.freellmapi" >> "$LOG" 2>&1
  sleep 6
  CODE2="$(/usr/bin/curl -s -o /dev/null -w '%{http_code}' -m 12 \
    http://127.0.0.1:3001/v1/models -H "Authorization: Bearer $TOKEN" 2>/dev/null)"
  if [ "$CODE2" = "200" ]; then
    echo "$STAMP RECOVERED after restart proxy=200" >> "$LOG"
  else
    echo "$STAMP STILL-DOWN after restart proxy=$CODE2 — manual fix needed (check ENCRYPTION_KEY in $DIR/.env)" >> "$LOG"
  fi
fi

# Keep the log from growing unbounded.
/usr/bin/tail -n 500 "$LOG" > "$LOG.tmp" 2>/dev/null && /bin/mv "$LOG.tmp" "$LOG" 2>/dev/null
exit 0
