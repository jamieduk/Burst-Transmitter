#!/bin/bash
# (c) J~Net 2026
# Audio Burst Transfer System - CRYPTO LAYER
# crypto.sh

# =========================
# LOAD CONFIG
# =========================
source "./config.conf"

# =========================
# AES ENCRYPT (BASE64 WRAPPED)
# =========================
aes_encrypt() {
  local input="$1"

  echo -n "$input" | openssl enc -aes-256-cbc -a -salt -pass pass:"$aes_pass"
}

# =========================
# AES DECRYPT
# =========================
aes_decrypt() {
  local input="$1"

  echo -n "$input" | openssl enc -aes-256-cbc -d -a -pass pass:"$aes_pass"
}

# =========================
# SHA256 HASH
# =========================
sha256_hash() {
  local input="$1"
  echo -n "$input" | sha256sum | awk '{print $1}'
}

# =========================
# CRC32 HASH (portable python)
# =========================
crc32_hash() {
  local input="$1"

  python3 - <<EOF
import zlib
import sys
print(zlib.crc32(sys.argv[1].encode()) & 0xffffffff)
EOF
}

# =========================
# VERIFY SHA256
# =========================
verify_sha256() {
  local data="$1"
  local expected="$2"

  local actual
  actual=$(sha256_hash "$data")

  if [ "$actual" = "$expected" ]; then
    return 0
  fi

  return 1
}

# =========================
# VERIFY CRC32
# =========================
verify_crc32() {
  local data="$1"
  local expected="$2"

  local actual
  actual=$(crc32_hash "$data")

  if [ "$actual" = "$expected" ]; then
    return 0
  fi

  return 1
}

# =========================
# SAFE ENCRYPT WRAPPER
# =========================
encrypt_payload() {
  local data="$1"

  if [ "$enable_aes" = "1" ]; then
    aes_encrypt "$data"
  else
    echo -n "$data"
  fi
}

# =========================
# SAFE DECRYPT WRAPPER
# =========================
decrypt_payload() {
  local data="$1"

  if [ "$enable_aes" = "1" ]; then
    aes_decrypt "$data"
  else
    echo -n "$data"
  fi
}
