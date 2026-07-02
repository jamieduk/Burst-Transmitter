#!/bin/bash
# (c) J~Net 2026
#
# https://github.com/jamieduk/Burst-Transmitter
#
# jnetai.com
#
# ./receive.sh "input.wav"
#
#
rate="2400"  # See Notes.txt for info for rate!
in_file="$1"
out_dir="output"
tmp_raw="/tmp/mm_raw.txt"
tmp_clean="/tmp/mm_clean.txt"

mkdir -p "$out_dir"

if [ -z "$in_file" ]; then
  read -p "Enter wav file: " in_file
fi

if [ ! -f "$in_file" ]; then
  echo "File not found: $in_file"
  exit 1
fi

minimodem --rx "$rate" -f "$in_file" > "$tmp_raw"

cat "$tmp_raw" | tr -d '\r\n ' | \
sed -n 's/.*START:://; s/::END.*//p' > "$tmp_clean"

# split filename + data
filename=$(cat "$tmp_clean" | cut -d'|' -f1)
data=$(cat "$tmp_clean" | cut -d'|' -f2-)

echo "$data" | base64 -d > "$out_dir/$filename"

if [ $? -eq 0 ]; then
  echo "RX Complete -> $out_dir/$filename"
else
  echo "Decode failed"
fi

/usr/bin/rm -f "$tmp_raw" "$tmp_clean"
