#!/usr/bin/env sh
# Copy new capture script from data folder and set as executable

SCRIPT_CAPTURE_NEW="/home/control/capture_local.py"
SCRIPT_CAPTURE_CURRENT="/home/control/skycam/scripts/capture_local.py"
SCRIPT_CAPTURE_LOG="/data/data/update_capture.log"

if [ -f "$SCRIPT_CAPTURE_NEW" ]; then
    # Get timestamp to rename old script files
    TIMESTAMP="$(date +%Y%m%dT%H%M%S)"
    # Rename current script
    mv "$SCRIPT_CAPTURE_CURRENT" "$SCRIPT_CAPTURE_CURRENT"."$TIMESTAMP"
    # Rename new script and make it executable
    mv "$SCRIPT_CAPTURE_NEW" "$SCRIPT_CAPTURE_CURRENT"
    chmod +x "$SCRIPT_CAPTURE_CURRENT"
    # Write last update to log
    printf "%s:\n\%s\n" \
    "Capture script updated on $TIMESTAMP" \
    "$(diff "$SCRIPT_CAPTURE_CURRENT"."$TIMESTAMP" "$SCRIPT_CAPTURE_CURRENT")" \
    >> "$SCRIPT_CAPTURE_LOG"
    # Compress old script
    gzip "$SCRIPT_CAPTURE_CURRENT"."$TIMESTAMP"
fi

SCRIPT_NETWORK_NEW="/home/control/skycam_network.sh"
SCRIPT_NETWORK_CURRENT="/home/control/skycam/scripts/skycam_network.sh"
SCRIPT_NETWORK_LOG="/data/data/update_startup.log"

if [ -f "$SCRIPT_NETWORK_NEW" ]; then
  # Get timestamp to rename old script files
  TIMESTAMP="$(date +%Y%m%dT%H%M%S)"
  # Rename current script
  mv "$SCRIPT_NETWORK_CURRENT" "$SCRIPT_NETWORK_CURRENT"."$TIMESTAMP"
  # Rename new script and make it executable
  mv "$SCRIPT_NETWORK_NEW" "$SCRIPT_NETWORK_CURRENT"
  chmod +x "$SCRIPT_NETWORK_CURRENT"
  # Write last update to log
  printf "%s:\n\%s\n" \
    "Capture script updated on $TIMESTAMP" \
    "$(diff "$SCRIPT_NETWORK_CURRENT"."$TIMESTAMP" "$SCRIPT_NETWORK_CURRENT")" \
    >> "$SCRIPT_NETWORK_LOG"
      # Compress old script
      gzip "$SCRIPT_NETWORK_CURRENT"."$TIMESTAMP"
fi

exit 0
