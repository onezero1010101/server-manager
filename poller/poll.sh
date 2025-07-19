#!/bin/sh
echo "Starting poll.sh"

UPS="apc3000@nut"
STATE_FILE="/etc/nut/.state"
SCRIPT_DIR="/etc/nut/thresholds"
INTERVAL=60

ON_BATT_SCRIPT="/etc/nut/on-battery-10min.sh"
ON_BATT_FLAG="/etc/nut/.on_batt_triggered"

ON_RESTORE_SCRIPT="/etc/nut/on-power-restored-10min.sh"
ON_RESTORE_FLAG="/etc/nut/.on_restore_triggered"

echo "Start" >> /etc/nut/log
date >> /etc/nut/log

THRESHOLDS="50 30 10"

touch "$STATE_FILE"
. "$STATE_FILE" 2>/dev/null || true

on_battery_since=0
power_restored_since=0

while true; do
  echo "Loop" >> /etc/nut/log

  CHARGE=$(upsc "$UPS" battery.charge 2>/dev/null)
  STATUS=$(upsc "$UPS" ups.status 2>/dev/null)

  if [ -z "$CHARGE" ] || [ -z "$STATUS" ]; then
    echo "$(date): Could not read UPS data." >> /etc/nut/poll.log
    sleep "$INTERVAL"
    continue
  fi

  # --- Battery threshold trigger ---
  for threshold in $THRESHOLDS; do
    eval var=\$triggered_$threshold
    if [ "$CHARGE" -le "$threshold" ] && [ "$var" != "yes" ]; then
      echo "$(date): Battery <= ${threshold}%. Executing $threshold.sh" >> /etc/nut/poll.log
      sh "$SCRIPT_DIR/$threshold.sh" &
      echo "triggered_$threshold=yes" >> "$STATE_FILE"
    fi
  done

  # --- On Battery Detection ---
  if echo "$STATUS" | grep -q "OB"; then
    if [ "$on_battery_since" -eq 0 ]; then
      on_battery_since=$(date +%s)
      echo "$(date): Detected on-battery start at $on_battery_since" >> /etc/nut/poll.log
    fi
    power_restored_since=0
    rm -f "$ON_RESTORE_FLAG"

    now=$(date +%s)
    elapsed=$((now - on_battery_since))
    if [ "$elapsed" -ge 600 ] && [ ! -f "$ON_BATT_FLAG" ]; then
      echo "$(date): On battery for 10 minutes. Running $ON_BATT_SCRIPT" >> /etc/nut/poll.log
      sh "$ON_BATT_SCRIPT" &
      touch "$ON_BATT_FLAG"
    fi

  # --- Power Restored Detection ---
  elif echo "$STATUS" | grep -q "OL"; then
    on_battery_since=0
    rm -f "$ON_BATT_FLAG"

    if [ "$power_restored_since" -eq 0 ]; then
      power_restored_since=$(date +%s)
      echo "$(date): Detected power restore at $power_restored_since" >> /etc/nut/poll.log
    fi

    now=$(date +%s)
    restored_elapsed=$((now - power_restored_since))
    if [ "$restored_elapsed" -ge 600 ] && [ ! -f "$ON_RESTORE_FLAG" ]; then
      echo "$(date): Power has been restored for 10 minutes. Running $ON_RESTORE_SCRIPT" >> /etc/nut/poll.log
      sh "$ON_RESTORE_SCRIPT" &
      touch "$ON_RESTORE_FLAG"
    fi
  fi

  sleep "$INTERVAL"
done
