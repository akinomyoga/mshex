#!/bin/bash

tac $HOME/.bash_history | {
  declare -A lines
  declare line
  while read -r line; do
    test -n "${lines[x$line]}" && continue
    lines["x$line"]=1
    echo "$line"
  done
} | tac
