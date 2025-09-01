#!/bin/bash

# Detect filesystem type of current directory
fs_type=$(stat -f -c %T .)

if [[ "$fs_type" == "9p" || "$fs_type" == "v9fs" ]]; then
  # On Windows filesystem: use Windows Git
  cmd.exe /c git "$@"
else
  # On native Linux filesystem: use WSL Git
  git "$@"
fi

