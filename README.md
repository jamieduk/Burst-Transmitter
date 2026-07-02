# (c) J~Net 2026
# README.md - Audio Burst File Transfer System (Minimodem Protocol)

# AUDIO BURST FILE TRANSFER SYSTEM
# ===============================
#
# This project implements a lightweight file transfer system using:
# - minimodem (audio modem encoding/decoding)
# - WAV audio files as transport medium
# - base64 encoding for binary-safe transmission
# - simple packet framing protocol
#
# Files can be transmitted through audio and fully reconstructed on the receiver side,
# including original filename and extension.

---

## FEATURES

- File transfer over WAV audio
- Preserves original filename + extension
- Base64 safe encoding (binary-safe)
- START/END packet framing
- Simple redundancy (packet duplication)
- Works fully offline
- Linux shell-based (no dependencies beyond minimodem + coreutils)

---

## HOW IT WORKS

### TRANSMISSION FLOW

1. Input file is selected (e.g. test.txt)
2. File is base64 encoded
3. Packet is constructed:

   START::filename|base64data::END

4. Packet is duplicated for redundancy
5. minimodem converts data into audio WAV file

---

### RECEPTION FLOW

1. WAV file is decoded using minimodem
2. Raw stream is extracted
3. START/END packet is isolated
4. filename and payload are split
5. base64 decoded back into original file
6. file is written into output/ folder

---

## FILES

- transmit.sh
  Sends a file via WAV audio burst

- receiver-burst.sh
  Receives WAV audio and reconstructs original file

---

## USAGE

### TRANSMIT

```bash
./transmit.sh test.txt
