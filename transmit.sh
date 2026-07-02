#!/bin/bash
# (c) J~Net 2026
#
# https://github.com/jamieduk/Burst-Transmitter
#
# jnetai.com
#
# ./transmit.sh "input-file"
#
#
rate="2400"  # See Notes.txt for info for rate!
in_file="$1"
out_file="burst_max.wav"

if [ -z "$in_file" ]; then
  read -p "Enter input file: " in_file
fi

if [ ! -f "$in_file" ]; then
  echo "File not found: $in_file"
  exit 1
fi

filename=$(basename "$in_file")
payload=$(base64 -w 0 "$in_file")

packet="START::${filename}|${payload}::END"

# duplicate for redundancy
minimodem --tx "$rate" -f "$out_file" <<< "$packet$packet"

echo "Burst TX Complete -> $out_file (rate=$rate)"
