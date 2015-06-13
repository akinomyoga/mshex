# bash source -*- mode: sh; mode: sh-bash -*-
#
# echox-1.0.0 - echo extensions for bash
#
#   copyright 2010-2012, Koichi Murase, myoga.murase@gmail.com
#
#   file:  $HOME/.mwg/echox
#   usage: source $HOME/.mwg/echox
# 
#
# ChangeLog
#
# 2012-10-15, KM, echox-1.0.0
#   * version 番号その他を付ける事に。
# 2012-10-02, KM
#   * echor がデフォルトの値を返した時に exit 1 になってしまうのを修正
# 2012-05-24, KM
#   * escape sequence による色付けを修正
# 2012-04-30, KM
#   * 引数判定で引数を test のオプションと間違えるバグを修正
# 2011-10-23, KM
#   * インデント push/pop 機能
# 2011-04-07, KM
#   * tkyntn に移植
# 2010-09-26, KM
#   * echo に対する引数 (-n, -e) を受け取れる様に修正
# 2010-09-22, KM
#   * 作成
#
#-------------------------------------------------------------------------------
#  utils
#-------------------------------------------------------------------------------
mshex_echox_prog="$0"
mshex_echox_indent=0
mshex_echox_indent_text=''
mshex_echox_indent_stk[0]=''

function echox.initialize {
  if [[ -t 1 ]]; then
    local fColorAuto=1
  else
    local fColorAuto=
  fi
  local fColor="$fColorAuto"

  while (($#)); do
    local arg="$1"
    shift
    case "$arg" in
    (--color|--color=always)
      fColor=1 ;;
    (--color=none|--color=never)
      fColor= ;;
    (--color=auto)
      fColor="$fColorAuto" ;;
    (*)
      echo "echox.initialize! unrecognized option '$arg'" >&2
      return ;;
    esac
  done

  if [[ $fColor ]]; then
    mshex_term_sgr0='[m'
    mshex_term_setfg='[32m'
    mshex_term_setfb='[34m'
    mshex_term_setfm='[35m'
    mshex_term_setfK='[90m'
    mshex_term_setfR='[91m'
    mshex_term_setfB='[94m'
  else
    mshex_term_sgr0=
    mshex_term_setfg=
    mshex_term_setfb=
    mshex_term_setfm=
    mshex_term_setfK=
    mshex_term_setfR=
    mshex_term_setfB=
  fi
}
echox.initialize "$@"

mshex_bash=$((${BASH_VERSINFO[0]}*10000+${BASH_VERSINFO[1]}*100+${BASH_VERSINFO[2]}))

function echox {
  if test "x${1:0:2}" == x-e -o "x${1:0:2}" == x-n; then
    local opt="$1"
    shift
  else
    local opt=''
  fi
  echo $opt "$mshex_term_setfB$mshex_echox_prog\$$mshex_term_sgr0 $mshex_echox_indent_text$mshex_term_setfb$*$mshex_term_sgr0"
}
function echoe {
  if test "x${1:0:2}" == x-e -o "x${1:0:2}" == x-n; then
    local opt="$1"
    shift
  else
    local opt=''
  fi
  echo $opt "$mshex_term_setfR$mshex_echox_prog!$mshex_term_sgr0 $mshex_echox_indent_text$*"
}
function echom {
  if test "x${1:0:2}" == x-e -o "x${1:0:2}" == x-n; then
    local opt="$1"
    shift
  else
    local opt=''
  fi
  echo $opt "$mshex_term_setfb$mshex_echox_prog:$mshex_term_sgr0 $mshex_echox_indent_text$*"
}
function echor {
  local var="$1"
  local msg="$mshex_term_setfb$mshex_echox_prog: $mshex_echox_indent_text$mshex_term_setfg$2$mshex_term_sgr0"
  local def="$3"
  test -n "$def" && msg="$msg [$mshex_term_setfm$def$mshex_term_sgr0]"

  if test "$mshex_bash" -ge 40000; then
    read -e -i "$def" -p "$msg$mshex_term_setfb ? $mshex_term_sgr0" "$var"
  else
    read -e           -p "$msg$mshex_term_setfb ? $mshex_term_sgr0" "$var"
  fi

  if test -n "$def"; then
    eval ': ${'"$var"':=$def}'
  fi
}

function echox_push {
  local indent="$1"
  if test -z "$indent"; then
    indent="$mshex_term_setfK- "
  fi

  mshex_echox_indent_stk[$mshex_echox_indent]=$mshex_echox_indent_text
  mshex_echox_indent=$((mshex_echox_indent+1))
  mshex_echox_indent_text="$mshex_echox_indent_text$indent$mshex_term_sgr0"
}

function echox_pop {
  if test "$mshex_echox_indent" -gt 0; then
    mshex_echox_indent=$((mshex_echox_indent-1))
    mshex_echox_indent_text=${mshex_echox_indent_stk[$mshex_echox_indent]}
  fi
}
