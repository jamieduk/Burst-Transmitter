#!/bin/bash
# (c) J~Net 2026
# AUDIO BURST TX - STABLE BINARY SAFE MODE

source "./config.conf"
source "./protocol.sh"

mkdir -p "$output_dir"
mkdir -p "$temp_dir"

/usr/bin/rm -f /tmp/audioburst/* 2>/dev/null

in_file="$1"

if [ -z "$in_file" ]; then
    read -rp "Input file: " in_file
fi

if [ ! -f "$in_file" ]; then
    echo "File not found"
    exit 1
fi

echo
echo "Key Setup"
echo "========="
echo "1) Passphrase"
echo "2) Key file"
read -rp "Select option: " keyopt

case "$keyopt" in
    1)
        read -rsp "Passphrase: " passphrase
        echo
        key="$passphrase"
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

zip_file="$temp_dir/payload.zip"
/usr/bin/rm -f "$zip_file"

zip -q -P "$key" "$zip_file" "$in_file"

if [ ! -f "$zip_file" ]; then
    echo "ZIP failed"
    exit 1
fi

base64_file="$temp_dir/payload.b64"
base64 -w 0 "$zip_file" > "$base64_file"

final_wav="$output_dir/audio_burst.wav"
/usr/bin/rm -f "$final_wav"

echo "Transmitting..."

# ONE CLEAN STREAM ONLY (NO PACKETS, NO EOP)
minimodem --tx 1200 --ascii -f "$final_wav" < "$base64_file"

echo "TX complete -> $final_wav"
