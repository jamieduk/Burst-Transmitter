#!/bin/bash
# (c) J~Net 2026
# AUDIO BURST RX - STABLE BINARY SAFE MODE

source "./config.conf"

mkdir -p "$output_dir"
mkdir -p "$temp_dir"

/usr/bin/rm -f /tmp/audioburst/* 2>/dev/null

in_file="$1"

if [ -z "$in_file" ]; then
    read -rp "Input WAV file: " in_file
fi

echo
echo "Key Setup"
echo "========="
echo "1) Passphrase"
echo "2) Key file"
read -rp "Select option: " keyopt

case "$keyopt" in
    1)
        read -rsp "Passphrase: " key
        echo
        ;;
    2)
        read -rp "Key file: " keyfile
        [ ! -f "$keyfile" ] && echo "Missing key file" && exit 1
        key="$(cat "$keyfile")"
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

raw_out="$temp_dir/raw.txt"
base64_file="$temp_dir/payload.b64"
zip_file="$temp_dir/payload.zip"

/usr/bin/rm -f "$raw_out" "$base64_file" "$zip_file"

echo "Decoding audio..."

minimodem --rx 1200 --ascii -f "$in_file" > "$base64_file"

if [ ! -s "$base64_file" ]; then
    echo "No data recovered"
    exit 1
fi

echo "Rebuilding ZIP..."

base64 -d "$base64_file" > "$zip_file"

if ! unzip -P "$key" "$zip_file" -d "$output_dir"; then
    echo "RX failed - ZIP corrupted or wrong key"
    exit 1
fi

echo "RX complete -> $output_dir"
