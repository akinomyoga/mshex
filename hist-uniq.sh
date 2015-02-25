#!/bin/bash

tac $HOME/.bash_history | {
  declare -A lines
  declare line
  while read -r line; do
    test -n "${lines[x$line]}" && continue
    lines["x$line"]=1
    echo "$line"
  done
} | tac | grep -v '^#' > $HOME/1.tmp

mwgbk -m $HOME/.bash_history && \
  mv $HOME/1.tmp $HOME/.bash_history
