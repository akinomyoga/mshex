#!/bin/bash
# -*- mode:sh -*-
# Title        PATH 操作系関数
# OriginalName mshex/shrc/lib/path.sh
# Created      2014-08-03, KM <myoga.murase@gmail.com>
#
# Synopsis
#
#   PATH.canonicalize [-v VARNAME] [-F SEP]
#   PATH.prepend      [-v VARNAME] [-F SEP] [-n] PATHS...
#   PATH.append       [-v VARNAME] [-F SEP] [-n] PATHS...
#   PATH.remove       [-v VARNAME] [-F SEP] PATHS...
#   PATH.show         [VARNAME]
#
#   -v VARNAME  変更する変数名。既定値 PATH
#   -F SEP      パスの区切に使用する文字。既定値 :
#   -n          存在しないパスは追加しない
#
# 制限 (今後対処するかもしれない物)
#   現在なし
#
# ChangeLog
#
# 2014-08-03, KM
#   * 何度も色々な所で書き散らして色々な version があるので纏める。
#   * PATH.prepend, PATH.append, PATH.remove, PATH.show 実装
#   * `-n' option の追加。
#   * 引数に指定したパスも : で分割する様に変更。
#   * PATH.canonicalize 実装、他の実装も再考
#     + 既に登録されている物を append すると最後に回されてしまうなどの問題を修正。
#     + 重複しているパス要素を常に全て削除する様に変更。
#

test -n "${MSHEX_LIB_PATH_SH+1}" && return
MSHEX_LIB_PATH_SH=1

MSHEX_LIB_PATH_SH_localVariables=(
  _PATH_varname _PATH_sep _PATH_paths
  _PATH_value _PATH_flags
  _PATH_cmdname)

# @var[out] _PATH_varname
# @var[out] _PATH_value
# @var[out] _PATH_paths
# @var[out] _PATH_sep
function PATH._readArguments {
  _PATH_varname=PATH
  _PATH_sep=:
  _PATH_flags=-
  _PATH_paths=()
  while test $# -gt 0; do
    case "$1" in
    (-v) # variable name
      _PATH_varname="$2"
      shift 2 ;;
    (-v*)
      _PATH_varname="${2:2}"
      shift 1 ;;
    (-F) # field separater
      _PATH_sep="$2"
      shift 2 ;;
    (-F*)
      _PATH_sep="${2:2}"
      shift 1 ;;
    (-n)
      _PATH_flags+=n ;;
    (--help)
      echo "usage: $_PATH_cmdname [-v VARNAME] [-F SEP] [-n] PATHS..."
      _PATH_flags+=x
      return ;;
    (-*)
      echo "$_PATH_cmdname: unknown option" >&2
      echo "usage: $_PATH_cmdname [-v VARNAME] [-F SEP] [-n] PATHS..." >&2
      _PATH_flags+=e
      return ;;
    (*)
      IFS="$_PATH_sep" eval "_PATH_paths+=(\$1)"
      shift ;;
    esac
  done

  eval "_PATH_value=\${$_PATH_varname}"
}

function PATH._canonicalizeImpl {
  local IFS="$_PATH_sep"
  local path ret= chk=
  for path in $_PATH_value; do
    test -z "$path" && continue
    test "${chk/$_PATH_sep$path$_PATH_sep/}" != "$chk" && continue
    chk+="$_PATH_sep$path$_PATH_sep"
    ret+="$_PATH_sep$path"
  done
  _PATH_value="${ret:1}"
}

function PATH.canonicalize {
  local "${MSHEX_LIB_PATH_SH_localVariables[@]}"
  local _PATH_cmdname=PATH.canonicalize
  PATH._readArguments "$@"
  test -z "${_PATH_flags/*x*/}" && return
  test -z "${_PATH_flags/*e*/}" && return 1
  
  PATH._canonicalizeImpl
  eval "export $_PATH_varname='$_PATH_value'"
}

function PATH.remove {
  local "${MSHEX_LIB_PATH_SH_localVariables[@]}"
  local _PATH_cmdname=PATH.remove
  PATH._readArguments "$@"
  test -z "${_PATH_flags/*x*/}" && return
  test -z "${_PATH_flags/*e*/}" && return 1

  local _PATH_path
  for _PATH_path in "${_PATH_paths[@]}"; do
    _PATH_value="${_PATH_value//$_PATH_sep$_PATH_path$_PATH_sep/$_PATH_sep}"
    _PATH_value="${_PATH_value#$_PATH_path$_PATH_sep}"
    _PATH_value="${_PATH_value%$_PATH_sep$_PATH_path}"
    if test "$_PATH_value" == "$_PATH_path"; then
      _PATH_value=''
      break
    fi
  done

  PATH._canonicalizeImpl
  eval "export $_PATH_varname='$_PATH_value'"
}

function PATH.prepend {
  local "${MSHEX_LIB_PATH_SH_localVariables[@]}"
  local _PATH_cmdname=PATH.prepend
  PATH._readArguments "$@"
  test -z "${_PATH_flags/*x*/}" && return
  test -z "${_PATH_flags/*e*/}" && return 1

  local _PATH_path _PATH_cpath=
  for _PATH_path in "${_PATH_paths[@]}"; do
    test -z "${_PATH_flags/*n*/}" -a ! -e "$_PATH_path" && continue
    _PATH_cpath+="$_PATH_path$_PATH_sep"
  done
  _PATH_value="$_PATH_cpath$_PATH_value"

  PATH._canonicalizeImpl
  eval "export $_PATH_varname='$_PATH_value'"
}

function PATH.append {
  local "${MSHEX_LIB_PATH_SH_localVariables[@]}"
  local _PATH_cmdname=PATH.append
  PATH._readArguments "$@"
  test -z "${_PATH_flags/*x*/}" && return
  test -z "${_PATH_flags/*e*/}" && return 1

  local _PATH_path
  for _PATH_path in "${_PATH_paths[@]}"; do
    test -z "${_PATH_flags/*n*/}" -a ! -e "$_PATH_path" && continue
    _PATH_value+="$_PATH_sep$_PATH_path"
  done

  PATH._canonicalizeImpl
  eval "export $_PATH_varname='$_PATH_value'"
}

function PATH.show {
  local name="${1-PATH}"
  eval "echo \"\${$name}\""|sed 's/:/\n/g'
}

