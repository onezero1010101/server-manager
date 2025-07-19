#!/bin/sh
echo "$(date): UPS has been on battery for 10 minutes!" >> /etc/nut/poll.log
# Add other actions (e.g., alerting, logging, safe shutdown, etc.)
