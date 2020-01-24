#!/usr/bin/env sh
# Copy new capture script from data folder and set as executable

SCRIPT_NEW="/home/control/capture_local.sh"
SCRIPT_CURRENT="/home/control/skycam/scripts/capture_local.sh"
SCRIPT_LOG="/home/control/skycam/scripts/update_capture.log.gz"

if [ -f "$SCRIPT_NEW" ]; then
	# Get timestamp to rename old script files
	TIMESTAMP="$(date +%Y%m%dT%H%M%S)"
	# Rename current script
	mv "$SCRIPT_CURRENT" "$SCRIPT_CURRENT"."$TIMESTAMP"
	# Rename new script and make it executable
	mv "$SCRIPT_NEW" "$SCRIPT_CURRENT"
	chmod +x "$SCRIPT_CURRENT"
	# Write last update to log
	printf "%s:\n\%s\n" \
	"Capture script updated on $TIMESTAMP" \
	"$(diff "$SCRIPT_CURRENT"."$TIMESTAMP" "$SCRIPT_CURRENT")" |\
	gzip >> "$SCRIPT_LOG"
	# Compress old script
	gzip "$SCRIPT_CURRENT"."$TIMESTAMP"
fi

exit 0
