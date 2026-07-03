#!/bin/bash
# (c) J~Net 2026
# Audio Burst Transfer System - LIB HELPERS
# lib.sh

source "./config.conf"

# =========================
# LOGGING
# =========================
log_msg() {
  if [ "$log_enabled" = "1" ]; then
    echo "[$(date +%F\ %T)] $1" >> "$log_file"
  fi
}

# =========================
# SAFE CREATE DIRS
# =========================
ensure_dirs() {
  mkdir -p "$output_dir"
  mkdir -p "$temp_dir"
}

# =========================
# CLEAN TEMP FILES
# =========================
clean_temp() {
  rm -f "$temp_dir"/*.tmp 2>/dev/null
  rm -f "$temp_dir"/*.b64 2>/dev/null
  rm -f "$temp_dir"/*.wav 2>/dev/null
}

# =========================
# FILE SIZE CHECK
# =========================
file_size() {
  local file="$1"
  stat -c%s "$file" 2>/dev/null
}

# =========================
# SAFE BASE64 ENCODE
# =========================
b64_encode() {
  base64 -w 0
}

# =========================
# SAFE BASE64 DECODE
# =========================
b64_decode() {
  base64 -d
}

# =========================
# PAUSE UTILITY
# =========================
pause() {
  read -p "Press ENTER to continue..."
}

# =========================
# PROGRESS PRINT
# =========================
progress() {
  echo "[*] $1"
}

# =========================
# INIT SYSTEM
# =========================
init_system() {
  ensure_dirs
  log_msg "System initialised"
}
