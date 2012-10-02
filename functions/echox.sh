#!/bin/bash
# bash.source

#-------------------------------------------------------------------------------
#  utils
#-------------------------------------------------------------------------------
istest=false
mwg_echox_prog="$0"
mwg_echox_indent=0
mwg_echox_indent_text=''
mwg_echox_indent_stk[0]=''
mwg_term_sgr0=$'[m'

echox () {
  if test "x${1:0:2}" == x-e -o "x${1:0:2}" == x-n; then
    local opt="$1"
    shift
  else
    local opt=''
  fi
  echo $opt "[94m$mwg_echox_prog\$[m $mwg_echox_indent_text[34m$*[m"
}
echoe () {
  if test "x${1:0:2}" == x-e -o "x${1:0:2}" == x-n; then
    local opt="$1"
    shift
  else
    local opt=''
  fi
  echo $opt "[91m$mwg_echox_prog![m $mwg_echox_indent_text$*"
}
echom () {
  if test "x${1:0:2}" == x-e -o "x${1:0:2}" == x-n; then
    local opt="$1"
    shift
  else
    local opt=''
  fi
  echo $opt "[34m$mwg_echox_prog:[m $mwg_echox_indent_text$*"
}
echor () {
  local var="$1"
  local msg=$'\e[34m'"$mwg_echox_prog: $mwg_echox_indent_text"$'\e[32m'"$2"$'\e[m'
  local def="$3"
  test -n "$def" && msg="$msg"$' [\e[35m'"$def"$'\e[m]'
  read -e -i "$def" -p "$msg"$'\e[34m ? \e[m' "$var"
  if test -n "$def"; then
    eval ': ${'"$var"':=$def}'
  fi
}

echox_push () {
  local indent="$1"
  if test -z "$indent"; then
    indent='[90m- '
  fi

  mwg_echox_indent_stk[$mwg_echox_indent]=$mwg_echox_indent_text
  mwg_echox_indent=$((mwg_echox_indent+1))
  mwg_echox_indent_text="$mwg_echox_indent_text$indent"$'\e[m'
}

echox_pop () {
  if test "$mwg_echox_indent" -gt 0; then
    mwg_echox_indent=$((mwg_echox_indent-1))
    mwg_echox_indent_text=${mwg_echox_indent_stk[$mwg_echox_indent]}
  fi
}
