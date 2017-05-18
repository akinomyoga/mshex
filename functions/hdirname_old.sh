#!/bin/bash

#------------------------------------------------------------------------------
#
# from libmwg_sh.sh (deleted)
#

# mwg.Path.GetScriptDirectory
#   呼び出されたシェルが存在しているディレクトリを取得
mwg.Path.GetScriptDirectory() {
  local arg0="$1"
  local defaultDir="$2"
  test -h "$arg0" && arg0="$(readlink -f "$arg0")"
  local dir="${arg0%/*}"
  if test "$dir" != "$arg0"; then
    echo -n "$dir"
  else
    echo -n "${defaultDir:-$PWD}"
  fi
}
SHDIR="$(mwg.Path.GetScriptDirectory "$0")"

#
# from 2015-09-22 mcxx/cxx_conf.sh
#
mwg.Path.GetScriptDirectory.set() {
  local v="$1"
  local arg0="$2"
  local defaultDir="$3"
  test -h "$arg0" && arg0="$(readlink -f "$arg0")"
  local dir="${arg0%/*}"
  if test "$dir" != "$arg0"; then
    eval "$v='$dir'"
  else
    eval "$v='${defaultDir:-$PWD}'"
  fi
}
mwg.Path.GetScriptDirectory.set SHDIR "${BASH_SOURCE:-$0}" "$MWGDIR/mcxx"

#------------------------------------------------------------------------------
# get_script_directory 系列
#
# from mcxx/cxxar (2015-09-22)
#
get_script_directory () {
  local arg0="$1"
  test -h "$arg0" && arg0="$(readlink -f "$arg0")"
  dir="${arg0%/*}"
  if test "$dir" != "$arg0"; then
    echo -n "$dir"
  else
    echo -n "$MWGDIR/mcxx"
  fi
}

#
# from mcxx/cxx (2015-07-03)
#

function get_script_directory {
  if test "x$1" == x-v; then
    local _fscr="$3"
    test -h "$_fscr" && _fscr="$(PATH=/bin:/usr/bin readlink -f "$_fscr")"

    local _dir="${_fscr%/*}"
    test "$_dir" == "$_fscr" && _dir="$MWGDIR/mcxx" # 既定値

    eval "$2=\"\$_dir\""
  else
    local _value
    get_script_directory -v _value "$1"
    echo -n "$_value"
  fi
}

#
# from mcxx/cxx (2015-09-22)
#

function get_script_directory {
  if test "x$1" == x-v; then
    local _fscr="$3"
    [[ -h "$_fscr" ]] && _fscr="$(PATH=/bin:/usr/bin readlink -f "$_fscr")"

    local _dir
    if [[ $_fscr == */* ]]; then
      _dir="${_fscr%/*}"
    elif [[ -s $_fscr ]]; then
      _dir=.
    else
      _dir="$4" # 既定値
    fi

    eval "$2=\"\$_dir\""
  else
    local _value
    get_script_directory -v _value "$1"
    echo -n "$_value"
  fi
}

#------------------------------------------------------------------------------
