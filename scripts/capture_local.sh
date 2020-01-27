#!/usr/bin/env bash
# Use raspistill to take sky image and store it locally.
# Note: To get raw bayer data, the smallest size is to take a jpeg with -q1,
#       else, if only JPEG will be used then -q100 and no -r is enough.
#       PNG could be a loseless option to get RGB components too.
# Andres

# Get datetime signature.
DATETIME="$(date -u +%Y%m%dT%H%M%S)"
YEAR=${DATETIME:0:4}
MONTH=${DATETIME:4:2}
DAY=${DATETIME:6:2}

# Define camera name, temporary directory and output file.
CAMERA=$HOSTNAME
TMPDIR="/dev/shm/"
OUTDIR="/home/data/data/"
BASEFILE="${CAMERA}_${YEAR}${MONTH}${DAY}"
LOGFILE="${OUTDIR}${BASEFILE}.log.xz"
TARFILE="${OUTDIR}${BASEFILE}.data.tar"

# This takes a jpeg with low quality and saves raw data to metadata,
# which allows to have a low quality visual image but keep have the
# raw data from the sensor (pre bayer filter). Mode is defined to 3 which
# implies full resolution and 1/6<=fps<=1, but mode 2 could also work
# 1<=fps<=15. Read more on:
# https://picamera.readthedocs.io/en/release-1.13/fov.html#sensor-modes
# mode 2 could also work.
#printf "%s\n" "Taking picture $OUTFILE" | xz >> "$LOGFILE"
#raspistill -n -ag 1 -dg 1 -mm matrix -t 2000 --ISO 100 --ev -10 -q 100 -r -o "$OUTDIR""$OUTFILE"

# Bracketed exposure for HDR
EV_INDEX=0
for EV in -18 -9 6; do
 TMPFILE="${TMPDIR}${HOSTNAME}_${DATETIME}_${EV_INDEX}.jpg"
 printf "%s\n" "Taking picture $OUTFILE" | xz >> "$LOGFILE"
 raspistill -v -n -ag 1 -dg 1 -mm matrix -t 2000 --ISO 100 --ev ${EV} -q 100 -r -o "$TMPFILE" 2>&1 | xz >>"$LOGFILE"
 EV_INDEX=$(( EV_INDEX + 1 ))
 # Compression
 xz -6 "$TMPFILE" &
done

wait

# Add captures to daily tarfile
cd "$TMPDIR"
tar --append -f "$TARFILE" "${HOSTNAME}_${DATETIME}"*.xz && \
  rm "${TMPDIR}${HOSTNAME}_${DATETIME}"*.xz

exit 0
