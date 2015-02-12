#!/bin/bash

target="${1:-$HOME/.bash_history}"

tac "$target" | {
  declare -A lines
  declare line
  while read -r line; do
    test -n "${lines[x$line]}" && continue
    lines["x$line"]=1
    echo "$line"
  done
} | tac | grep -v '^#' > "$HOME/1.tmp"

mwgbk -m "$target" && mv "$HOME/1.tmp" "$target"
