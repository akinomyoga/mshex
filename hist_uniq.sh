#!/bin/bash

#------------------------------------------------------------------------------
# read arguments

fError=
check_syntax=

fTargetSet=
target=

while (($#)); do
  arg="$1"
  shift
  case "$arg" in 
  (--check-syntax)
    check_syntax=1 ;;
  (-*)
    echo "${0##*/}: unrecognized option \`$arg'" >&2
    fError=1 ;;
  (*)
    if [[ -f $arg ]]; then
      if [[ $fTargetSet ]]; then
        echo "${0##*/}: multiple target files are specified." >&2
        fError=1
      else
        fTargetSet=1
        target="$arg"
      fi
    elif [[ -e $arg ]]; then
      echo "${0##*/}: the specified path \`$arg' is not an ordinary file." >&2
      fError=1
    else
      echo "${0##*/}: the specified file \`$arg' does not exist." >&2
      fError=1
    fi ;;
  esac
done

if [[ ! $fTargetSet ]]; then
  if [[ -f $HOME/.bash_history ]]; then
    target="$HOME/.bash_history"
  else
    echo "${0##*/}: the default target file \`$HOME/.bash_history' does not exist." >&2
    fError=1
  fi
fi

[[ $fError ]] && exit 1

#------------------------------------------------------------------------------

tac "$target" | {
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

mwgbk -m "$target" && mv "$HOME/1.tmp" "$target"

if [[ $check_syntax && -s "$HOME/2.tmp" ]]; then
  cat bash_history.invalid >> "$HOME/.bash_history.invalid"
fi
