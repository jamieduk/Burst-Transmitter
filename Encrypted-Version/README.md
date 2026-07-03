# (c) J~Net 2026
# AUDIO BURST TRANSFER SYSTEM (Minimodem Protocol)

========================================
OVERVIEW
========================================

This project implements a file transfer system over audio WAV files using:

- minimodem (FSK audio modulation)
- base64 encoding for binary-safe transport
- AES-256 encryption (optional)
- SHA256 + CRC32 integrity checks
- packet-based streaming protocol
- duplicate packet redundancy

It simulates a lightweight "audio TCP-like system" over offline WAV files.

========================================
FEATURES
========================================

✔ File → packet splitting
✔ Filename + extension preservation
✔ Base64 encoding layer
✔ AES-256 encryption (optional)
✔ SHA256 verification per packet
✔ CRC32 verification per packet
✔ Packet duplication for redundancy
✔ Automatic reassembly on RX
✔ Output folder structure
✔ Menu-driven interface (start.sh)

========================================
PROJECT STRUCTURE
========================================

audio-burst/
├── start.sh        # Main menu system
├── config.conf     # Global configuration
├── protocol.sh     # Packet framing + reassembly logic
├── crypto.sh       # AES + hashing + verification
├── tx.sh           # Transmitter (file → WAV)
├── rx.sh           # Receiver (WAV → file)
├── lib.sh          # Helpers + logging utilities
├── output/         # Final decoded files
├── /tmp/           # Temporary packet data

========================================
REQUIREMENTS
========================================

Install dependencies:

- minimodem
- sox
- openssl
- base64
- python3

Ubuntu example:

sudo apt install minimodem sox openssl python3 coreutils

========================================
HOW TO USE
========================================

1) Start system

```bash
./start.sh
