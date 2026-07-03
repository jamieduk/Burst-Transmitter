#!/bin/bash
# (c) J~Net 2026
# Audio Burst Transfer System - MAIN MENU
# start.sh

text="Encrypted Audio Burst Transfer System By (c) J~Net 2026"
color="\e[92m"

clear

echo -e "$color$text"

source "./config.conf"

sleep 0.3

while true; do
  clear
  echo "=================================="
  echo "  AUDIO BURST TRANSFER SYSTEM"
  echo "=================================="
  echo "1) Transmit File (TX)"
  echo "2) Receive File (RX)"
  echo "3) View Config"
  echo "4) Exit"
  echo "=================================="
  read -p "Select option: " opt

  case "$opt" in

    1)
      read -p "Input file: " file
      if [ ! -f "$file" ]; then
        echo "File not found"
        sleep 1
        continue
      fi

      ./tx.sh "$file"
      read -p "Press enter to return..."
      ;;

    2)
      read -p "Input WAV file: " wav
      if [ ! -f "$wav" ]; then
        echo "File not found"
        sleep 1
        continue
      fi

      ./rx.sh "$wav"
      read -p "Press enter to return..."
      ;;

    3)
      clear
      echo "----- CONFIG -----"
      cat config.conf
      echo "------------------"
      read -p "Press enter to return..."
      ;;

    4)
      echo "Exiting..."
      exit 0
      ;;

    *)
      echo "Invalid option"
      sleep 1
      ;;
  esac

done
