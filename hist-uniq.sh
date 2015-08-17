#!/bin/bash

check_syntax=

tac $HOME/.bash_history | {
  declare -A lines
  declare line
  while read -r line; do
    test -n "${lines[x$line]}" && continue
    lines["x$line"]=1
    if [[ $check_syntax ]] && ! echo "$line" | bash -n &>/dev/null; then
      echo "$line" >> "$HOME/2.tmp"
      continue
    fi
    echo "$line"
  done
} | tac | grep -v '^#' > "$HOME/1.tmp"

mwgbk -m $HOME/.bash_history && \
  mv $HOME/1.tmp $HOME/.bash_history

if [[ $check_syntax && -s "$HOME/2.tmp" ]]; then
  cat bash_history.invalid >> "$HOME/.bash_history.invalid"
fi
