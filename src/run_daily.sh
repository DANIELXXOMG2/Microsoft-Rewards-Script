#!/usr/bin/env bash
set -euo pipefail

# Ensure Playwright uses the preinstalled browsers
export PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# Ensure TZ is set (entrypoint sets TZ system-wide); fallback if missing
export TZ="${TZ:-UTC}"

# Expected daily runs (configurable via env; default 2)
EXPECTED_DAILY_RUNS="${EXPECTED_DAILY_RUNS:-2}"

# Change to project directory
cd /usr/src/microsoft-rewards-script

# Log file for execution tracking (store inside a mounted logs directory)
LOG_DIR="/usr/src/microsoft-rewards-script/logs"
LOG_FILE="$LOG_DIR/execution_log.ndjson"

# Ensure logs directory exists
mkdir -p "$LOG_DIR"

# Function to add execution log as NDJSON (one JSON per line)
add_execution_log() {
    local log_type="$1"
    local message="$2"
    local timestamp=$(date -Iseconds)
    local entry
    entry=$(printf '{"timestamp":"%s","type":"%s","message":"%s","timezone":"%s"}\n' "$timestamp" "$log_type" "${message//"/\"}" "$TZ")
    echo -n "$entry" >> "$LOG_FILE"
}

# Helper to count today's successful executions using grep on NDJSON
count_today_success() {
    local today=$(date +%Y-%m-%d)
    if [ -f "$LOG_FILE" ]; then
        # First filter by today's date, then count lines with EXECUTION_SUCCESS
        grep -F '"timestamp":"'$today"'"' "$LOG_FILE" 2>/dev/null | grep -c '"type":"EXECUTION_SUCCESS"' || echo "0"
    else
        echo "0"
    fi
}

# Optional: prevent overlapping runs
LOCKFILE=/tmp/run_daily.lock
exec 9>"$LOCKFILE"
if ! flock -n 9; then
  echo "[$(date)] [run_daily.sh] Previous instance still running; exiting."
  add_execution_log "EXECUTION_SKIPPED" "Previous instance still running"
  exit 0
fi

# Before doing anything heavy, check if we already met today's quota
TODAY_COUNT=$(count_today_success)
echo "[$(date)] [run_daily.sh] Today's successful executions so far: $TODAY_COUNT/$EXPECTED_DAILY_RUNS"
add_execution_log "DAILY_COUNT_CHECK_PRE" "Before run: $TODAY_COUNT/$EXPECTED_DAILY_RUNS"
if [ "$TODAY_COUNT" -ge "$EXPECTED_DAILY_RUNS" ]; then
  echo "[$(date)] [run_daily.sh] Daily quota already met. Skipping execution."
  add_execution_log "DAILY_GOAL_ALREADY_MET" "Daily goal already met: $TODAY_COUNT/$EXPECTED_DAILY_RUNS"
  exit 0
fi

echo "[$(date)] [run_daily.sh] Starting Microsoft Rewards Script execution..."
add_execution_log "EXECUTION_START" "Microsoft Rewards Script started"

# Random sleep between configurable minutes (default 5-50 minutes)
MINWAIT=${MIN_SLEEP_MINUTES:-5}
MAXWAIT=${MAX_SLEEP_MINUTES:-50}
MINWAIT_SEC=$((MINWAIT*60))
MAXWAIT_SEC=$((MAXWAIT*60))

# Skip sleep if SKIP_RANDOM_SLEEP is set to true
if [ "${SKIP_RANDOM_SLEEP:-false}" != "true" ]; then
    SLEEPTIME=$(( MINWAIT_SEC + RANDOM % (MAXWAIT_SEC - MINWAIT_SEC) ))
    SLEEP_MINUTES=$(( SLEEPTIME / 60 ))
    echo "[$(date)] [run_daily.sh] Sleeping for $SLEEP_MINUTES minutes ($SLEEPTIME seconds) to randomize execution..."
    add_execution_log "RANDOM_SLEEP" "Sleeping for $SLEEP_MINUTES minutes to randomize execution"
    sleep "$SLEEPTIME"
else
    echo "[$(date)] [run_daily.sh] Skipping random sleep (SKIP_RANDOM_SLEEP=true)"
    add_execution_log "SLEEP_SKIPPED" "Random sleep skipped (SKIP_RANDOM_SLEEP=true)"
fi

echo "[$(date)] [run_daily.sh] Starting script..."
if npm start; then
  echo "[$(date)] [run_daily.sh] Script completed successfully."
  add_execution_log "EXECUTION_SUCCESS" "Microsoft Rewards Script completed successfully"
else
  echo "[$(date)] [run_daily.sh] ERROR: Script failed!" >&2
  add_execution_log "EXECUTION_FAILED" "Microsoft Rewards Script failed with error"
  exit 1
fi

# Log completion time and check daily execution count
echo "[$(date)] [run_daily.sh] Execution completed. Checking daily execution count..."

# Re-count today's executions
TODAY_COUNT=$(count_today_success)

echo "[$(date)] [run_daily.sh] Today's successful executions: $TODAY_COUNT/$EXPECTED_DAILY_RUNS"
add_execution_log "DAILY_COUNT_CHECK" "After run: $TODAY_COUNT/$EXPECTED_DAILY_RUNS"

if [ "$TODAY_COUNT" -ge "$EXPECTED_DAILY_RUNS" ]; then
    echo "[$(date)] [run_daily.sh] ✅ Daily goal achieved! ($TODAY_COUNT/$EXPECTED_DAILY_RUNS executions completed)"
    add_execution_log "DAILY_GOAL_ACHIEVED" "Daily goal of $EXPECTED_DAILY_RUNS executions achieved"
else
    echo "[$(date)] [run_daily.sh] ⚠️  Daily goal in progress ($TODAY_COUNT/$EXPECTED_DAILY_RUNS executions completed)"
    add_execution_log "DAILY_GOAL_PROGRESS" "Daily goal in progress: $TODAY_COUNT/$EXPECTED_DAILY_RUNS executions"
fi