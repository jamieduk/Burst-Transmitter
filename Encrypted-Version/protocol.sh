#!/bin/bash
# (c) J~Net 2026
# Audio Burst Transfer System - PROTOCOL LAYER (REDUNDANT SMALL PACKETS v3)

source "./config.conf"

mkdir -p "$output_dir"
mkdir -p "$temp_dir"

# =========================
# HASH
# =========================
hash_sha256() {
  echo -n "$1" | sha256sum | awk '{print $1}'
}

# =========================
# CRC32
# =========================
crc32() {
  python3 - "$1" <<'EOF'
import zlib,sys
print(zlib.crc32(sys.argv[1].encode()) & 0xffffffff)
EOF
}

# =========================
# CONFIG TUNING (SMALL PACKETS)
# =========================
packet_size="${packet_size:-32}"          # <<< MUCH SMALLER PACKETS
redundancy="${redundancy:-4}"             # <<< SEND EACH PACKET 4 TIMES

# =========================
# PACKETIZE (REDUNDANT)
# =========================
packetize_file() {
  local file="$1"

  /usr/bin/rm -f "$temp_dir/packets.tmp"
  /usr/bin/rm -f "$temp_dir/data_chunks.tmp"

  if [ ! -f "$file" ]; then
    echo "Missing file: $file"
    return 1
  fi

  b64=$(cat "$file")

  echo "$b64" | fold -w "$packet_size" > "$temp_dir/data_chunks.tmp"

  seq=0
  total=$(wc -l < "$temp_dir/data_chunks.tmp")

  while read -r chunk; do

    if [[ ! "$chunk" =~ ^[A-Za-z0-9+/=]+$ ]]; then
      continue
    fi

    sha=$(hash_sha256 "$chunk")
    crc=$(crc32 "$chunk")

    packet="${start_marker}|ZIPSTREAM|$seq|$total|$sha|$crc|$chunk|$end_marker"

    # =========================
    # REDUNDANT TRANSMISSION
    # =========================
    for ((r=0; r<redundancy; r++)); do
      echo "$packet" >> "$temp_dir/packets.tmp"
    done

    seq=$((seq+1))

  done < "$temp_dir/data_chunks.tmp"

  echo "ZIPSTREAM|$total"
}

# =========================
# REASSEMBLE (LOSS TOLERANT)
# =========================
reassemble_packets() {
  local wav_file="$1"
  EOP_MARKER="|EOP|"
  /usr/bin/rm -f "$temp_dir/raw.txt"
  /usr/bin/rm -f "$temp_dir/clean.txt"
  /usr/bin/rm -f "$temp_dir/rebuilt.b64"
  /usr/bin/rm -f "$temp_dir/sorted.tmp"
  /usr/bin/rm -f "$temp_dir/payload.zip"

  minimodem --rx "$rate" -f "$wav_file" > "$temp_dir/raw.txt"

  grep -o "${start_marker}.*${end_marker}" "$temp_dir/raw.txt" > "$temp_dir/clean.txt"

  declare -A chunks
  declare -A seen

  total_packets=0
  received=0

  while IFS= read -r line; do

    IFS='|' read -r start fn seq total sha crc data end <<< "$line"

    total_packets="$total"

    # dedupe (CRITICAL for redundancy system)
    if [ "${seen[$seq]}" = "1" ]; then
      continue
    fi
    seen[$seq]=1

    check_sha=$(hash_sha256 "$data")
    check_crc=$(crc32 "$data")

    if [ "$check_sha" != "$sha" ] || [ "$check_crc" != "$crc" ]; then
      continue
    fi

    chunks[$seq]="$data"
    received=$((received+1))

  done < "$temp_dir/clean.txt"

  echo "Packets received: $received / $total_packets"

  # =========================
  # MINIMUM COVERAGE CHECK
  # =========================
  min_required=$((total_packets * 70 / 100))

  if [ "$received" -lt "$min_required" ]; then
    echo "Insufficient data ($received/$total_packets) - aborting"
    return 1
  fi

  # =========================
  # REBUILD STREAM
  # =========================
  for seq in $(printf "%s\n" "${!chunks[@]}" | sort -n); do
    echo -n "${chunks[$seq]}" >> "$temp_dir/rebuilt.b64"
  done

  # =========================
  # DECODE ZIP
  # =========================
  if ! base64 -d "$temp_dir/rebuilt.b64" > "$temp_dir/payload.zip"; then
    echo "Base64 decode failed"
    return 1
  fi

  # =========================
  # VERIFY ZIP
  # =========================
  if ! unzip -t "$temp_dir/payload.zip" >/dev/null 2>&1; then
    echo "ZIP corrupted (coverage too low or noise too high)"
    return 1
  fi

  # =========================
  # EXTRACT
  # =========================
  if [ "$AUDIOBURST_KEY_MODE" = "text" ]; then
    unzip -P "$AUDIOBURST_KEY" "$temp_dir/payload.zip" -d "$output_dir"
  else
    unzip -P "$(cat "$AUDIOBURST_KEY")" "$temp_dir/payload.zip" -d "$output_dir"
  fi

  echo "Rebuilt -> $output_dir"
}

# =========================
# EXPORTS
# =========================
export -f packetize_file
export -f reassemble_packets
