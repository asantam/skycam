#!/usr/bin/env sh
# Copy new capture script from data folder and set as executable

SCRIPT_CURRENT="/home/data/data/capture_local.sh.new"
SCRIPT_NEW="/home/control/skycam/scripts/capture_local.sh"
SCRIPT_LOG="/home/control/skycam/scripts/update_capture.log.gz"

if [ -f "$SCRIPT_NEW" ]; then
	# Get timestamp to rename old script files
	TIMESTAMP="$(date +%Y%m%dT%H%M%S)"
	# Rename current script
	mv "$SCRIPT_CURRENT" "$SCRIPT_CURRENT"."$TIMESTAMP"
	# Rename new script and make it executable
	mv "$SCRIPT_NEW" "$SCRIPT_CURRENT"
	chmod +x "$SCRIPT_CURRENT"
	# Compress old script
	gzip "$SCRIPT_CURRENT"."$TIMESTAMP"
	# Write last update to log
	printf "%s\n" "Capture script updated on $TIMESTAMP" | gzip >> "$SCRIPT_LOG"
fi

exit 0
