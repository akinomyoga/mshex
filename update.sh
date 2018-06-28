#!/bin/sh

MWGDIR=$HOME/.mwg

mkd() { test -d "$1" || mkdir -p "$1"; }
upd_mv() {
  if test -f "$1"; then
    if test ! -e "$2"; then
      echo mv "$1" "$2"
      mv "$1" "$2"
    else
      echo rm -f "$1"
      rm -f "$1"
    fi
  elif test -d "$1"; then
    if test ! -e "$2"; then
      echo mv "$1" "$2"
      mv "$1" "$2"
    else
      echo rm -rf "$1"
      rm -rf "$1"
    fi
  fi
}
upd_rm() {
  if test -f "$1"; then
    echo rm -f "$1"
    rm -f "$1"
  elif test -d "$1"; then
    echo rm -rf "$1"
    rm -rf "$1"
  fi
}

#------------------------------------------------------------------------------
# 2012-07-26

if test -d "$MWGDIR/bashrc.d"; then
  rm -rf "$MWGDIR/bashrc.d"
fi

#------------------------------------------------------------------------------
# 2012-10-03

sdir="$MWGDIR/share/mshex"
mkd "$sdir"

if test -d "$MWGDIR/shrc.d"; then
  dir1="$MWGDIR/shrc.d"
  
  upd_mv "$dir1/bashrc" "$sdir/bashrc.cache"
  upd_mv "$dir1/zshrc" "$sdir/zshrc.cache"
  upd_mv "$dir1/tools/menu.bash_source" "$sdir/shrc/menu.bash_source"

  echo rm -rf "$dir1"
  rm -rf "$dir1"
fi

mkd "$sdir/shrc"
upd_mv "$MWGDIR/bash_tools" "$sdir/shrc/bash_tools"
upd_mv "$MWGDIR/bashrc_interactive" "$sdir/shrc/bashrc_interactive"
upd_mv "$MWGDIR/zshrc_interactive" "$sdir/shrc/zshrc_interactive"

#------------------------------------------------------------------------------
# 2015-02-08

upd_rm "$sdir/shrc/menu.bash_source"

#------------------------------------------------------------------------------
# 2018-06-28

upd_mv "$MWGDIR/bashrc_common.sh" "$sdir/shrc/bashrc_common.sh"
upd_mv "$sdir/shrc/bashrc_interactive" "$sdir/shrc/bashrc_interactive.sh"
upd_mv "$sdir/shrc/zshrc_interactive" "$sdir/shrc/zshrc_interactive.sh"
