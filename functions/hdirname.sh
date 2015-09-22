#!/bin/bash

# hdirname filename [defaultValue]
#   そのファイルが実際に存在しているディレクトリを取得する。
#   ディレクトリ名自体はシンボリックリンクでも良い。
#
# 目標
#   * bash-3.0 で動く
#   * どの環境でも動く
#   *
#
# 参考
#
# http://kohkimakimoto.hatenablog.com/entry/2014/06/12/104110
#

# from mshex/functions/hdirname.sh

# readlink -f
function hdirname/readlink {
  local path="$1"
  case "$OSTYPE" in
  (cygwin|linux-gnu)
    # 少なくとも cygwin, GNU/Linux では readlink -f が使える
    PATH=/bin:/usr/bin readlink -f "$path" ;;
  (darwin*|*)
    # Mac OSX には readlink -f がない。
    local PWD="$PWD" OLDPWD="$OLDPWD"
    while [[ -h $path ]]; do
      local link="$(PATH=/bin:/usr/bin readlink "$path" || true)"
      [[ $link ]] || break

      if [[ $link = /* || $path != */* ]]; then
        # * $link ~ 絶対パス の時
        # * $link ~ 相対パス かつ ( $path が現在のディレクトリにある ) の時
        path="$link"
      else
        local dir="${path%/*}"
        path="${dir%/}/$link"
      fi
    done
    echo -n "$path" ;;
  esac
}

## @fn hdirname/impl file defaultValue
## @param[in] file
## @param[in] defaultValue
## @var[out] _ret
function hdirname {
  if [[ $1 == -v ]]; then
    # hdirname -v var file defaultValue
    eval '
      '$2'="$3"
      [[ -h ${'$2'} ]] && '$2'=$(hdirname/readlink "${'$2'}")

      if [[ ${'$2'} == */* ]]; then
        '$2'="${'$2'%/*}"
        : "${'$2':=/}"
      else
        '$2'="${4-$PWD}"
      fi
    '
  elif [[ $1 == -v* ]]; then
    hdirname -v "${1:2}" "${@:2}"
  else
    local ret
    hdirname -v ret "$@"
    echo -n "$ret"
  fi
}

#------------------------------------------------------------------------------
# from libmwg_sh.sh (deleted)
#
# # mwg.Path.GetScriptDirectory
# #   呼び出されたシェルが存在しているディレクトリを取得
# mwg.Path.GetScriptDirectory() {
#   local arg0="$1"
#   local defaultDir="$2"
#   test -h "$arg0" && arg0="$(readlink -f "$arg0")"
#   local dir="${arg0%/*}"
#   if test "$dir" != "$arg0"; then
#     echo -n "$dir"
#   else
#     echo -n "${defaultDir:-$PWD}"
#   fi
# }
# SHDIR="$(mwg.Path.GetScriptDirectory "$0")"
#
# from 2015-09-22 mcxx/cxx_conf.sh
#
# mwg.Path.GetScriptDirectory.set() {
#   local v="$1"
#   local arg0="$2"
#   local defaultDir="$3"
#   test -h "$arg0" && arg0="$(readlink -f "$arg0")"
#   local dir="${arg0%/*}"
#   if test "$dir" != "$arg0"; then
#     eval "$v='$dir'"
#   else
#     eval "$v='${defaultDir:-$PWD}'"
#   fi
# }
# mwg.Path.GetScriptDirectory.set SHDIR "${BASH_SOURCE:-$0}" "$MWGDIR/mcxx"
#

#------------------------------------------------------------------------------
# get_script_directory 系列
#
# from mcxx/cxxar (2015-09-22)
#
# get_script_directory () {
#   local arg0="$1"
#   test -h "$arg0" && arg0="$(readlink -f "$arg0")"
#   dir="${arg0%/*}"
#   if test "$dir" != "$arg0"; then
#     echo -n "$dir"
#   else
#     echo -n "$MWGDIR/mcxx"
#   fi
# }
#
# from mcxx/cxx (2015-07-03)
#
# function get_script_directory {
#   if test "x$1" == x-v; then
#     local _fscr="$3"
#     test -h "$_fscr" && _fscr="$(PATH=/bin:/usr/bin readlink -f "$_fscr")"
#
#     local _dir="${_fscr%/*}"
#     test "$_dir" == "$_fscr" && _dir="$MWGDIR/mcxx" # 既定値
#
#     eval "$2=\"\$_dir\""
#   else
#     local _value
#     get_script_directory -v _value "$1"
#     echo -n "$_value"
#   fi
# }
#
# from mcxx/cxx (2015-09-22)
#
# function get_script_directory {
#   if test "x$1" == x-v; then
#     local _fscr="$3"
#     [[ -h "$_fscr" ]] && _fscr="$(PATH=/bin:/usr/bin readlink -f "$_fscr")"
#
#     local _dir
#     if [[ $_fscr == */* ]]; then
#       _dir="${_fscr%/*}"
#     elif [[ -s $_fscr ]]; then
#       _dir=.
#     else
#       _dir="$4" # 既定値
#     fi
#
#     eval "$2=\"\$_dir\""
#   else
#     local _value
#     get_script_directory -v _value "$1"
#     echo -n "$_value"
#   fi
# }

#------------------------------------------------------------------------------
