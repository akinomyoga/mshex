#!/bin/bash
## -*- coding:utf-8 -*-
## $HOME/.mwg/share/mshex/shrc/term.sh
##
## Copyright (c) 2010-2013 Koichi MURASE <murase@nt.phys.s.u-tokyo.ac.jp>, <myoga.murase@gmail.com>
## 
## terminfo/termcap manipulators
##
## mshex/term/echo         name
## mshex/term/register-key name tputargs defaultValue
## mshex/term/register_cap name value
##
## mshex/term/readkey     var
## mshex/term/readkey/keymap-def  kseq kname
## mshex/term/readkey/keymap-tdef tname kseq kname
##
## mshex/term/set_title         title
## mshex/term/set_title.escaped title

((_mshex_term_PragmaOnce>=2)) && return
_mshex_term_PragmaOnce=2

declare "${_mshex_dict_declare[@]//DICTNAME/_mshex_term}"
declare "${_mshex_dict_declare[@]//DICTNAME/_mshex_term_keymap}"

#------------------------------------------------------------------------------
# mshex/term

function mshex/term/.cache.fname {
  local varname=
  [[ $1 == '-v' ]] && varname=$2

  local shrc=common
  local cachedir=$MWGDIR/share/mshex/$shrc.cache
  if [[ ! -d $cachedir ]]; then
    if [[ -d $MWGDIR/shrc.d/$shrc ]]; then
      mv "$MWGDIR/shrc.d/$shrc" "$cachedir"
    else
      mkdir -p "$cachedir"
    fi
  fi

  local cache=$cachedir/mshex_term.$TERM
  if [[ ! -s $cache ]]; then
    cat <<EOF > "$cache"
mshex/dict '_mshex_term[f:cuu]=[%dA'
mshex/dict '_mshex_term[f:cud]=[%dB'
mshex/dict '_mshex_term[f:cuf]=[%dC'
mshex/dict '_mshex_term[f:cub]=[%dD'
mshex/dict '_mshex_term[f:il]=[%dL'
mshex/dict '_mshex_term[f:dl]=[%dM'
mshex/dict '_mshex_term[f:cup]=[%d;%dH'
EOF
  fi

  if [[ $varname ]]; then
    eval "$varname=\$cache"
  else
    printf %s "$cache"
  fi
}

function mshex/term/.cache.load {
  local fcache
  mshex/term/.cache.fname -v fcache
  source "$fcache"
}
function mshex/term/.cache.set {
  local fcache
  mshex/term/.cache.fname -v fcache

  mshex/dict "_mshex_term[$1]=$2"
  echo "mshex/dict '_mshex_term[$1]=$2'" >> "$fcache"
}
function mshex/term/echo {
  mshex/dict "_mshex_term[$1]"
}
function mshex/term/register-key {
  local name=$1
  local tiargs=$2
  local def=$3
  if mshex/dict -z:"_mshex_term[$name]"; then
    mshex/term/.cache.set "$name" "$(tput $tiargs 2>/dev/null || echo -n "$def")"
  fi
}
function mshex/term/register_cap {
  local name=$1
  local tiargs=$2
  if mshex/dict -z:"_mshex_term[$name]"; then
    if tput $tiargs &>/dev/null; then
      mshex/term/.cache.set "$name" 1 # true
    else
      mshex/term/.cache.set "$name" 0 # false
    fi
  fi
}

# 62ms
mshex/term/.cache.load

#------------------------------------------------------------------------------
# mshex/term/color

mshex/term/color.init(){
  if mshex/dict -z:'_mshex_term[sgr0]'; then
    echo -n "initializing _mshex_term colors... " >&2
    mshex/term/register-key fDR   'setaf 1'  $'\e[31m'
    mshex/term/register-key fDG   'setaf 2'  $'\e[32m'
    mshex/term/register-key fDB   'setaf 4'  $'\e[34m'
    mshex/term/register-key fDC   'setaf 6'  $'\e[36m'
    mshex/term/register-key fDM   'setaf 5'  $'\e[35m'
    mshex/term/register-key fDY   'setaf 3'  $'\e[33m'
    mshex/term/register-key fDK   'setaf 0'  $'\e[30m'
    mshex/term/register-key fDW   'setaf 7'  $'\e[37m'
    echo -n '*' >&2
    mshex/term/register-key fHR   'setaf 9'  $'\e[91m'
    mshex/term/register-key fHG   'setaf 10' $'\e[92m'
    mshex/term/register-key fHB   'setaf 12' $'\e[94m'
    mshex/term/register-key fHC   'setaf 14' $'\e[96m'
    mshex/term/register-key fHM   'setaf 13' $'\e[95m'
    mshex/term/register-key fHY   'setaf 11' $'\e[93m'
    mshex/term/register-key fHK   'setaf 8'  $'\e[90m'
    mshex/term/register-key fHW   'setaf 15' $'\e[97m'
    echo -n '*' >&2
    mshex/term/register-key bDR   'setab 1'  $'\e[41m'
    mshex/term/register-key bDG   'setab 2'  $'\e[42m'
    mshex/term/register-key bDB   'setab 4'  $'\e[44m'
    mshex/term/register-key bDC   'setab 6'  $'\e[46m'
    mshex/term/register-key bDM   'setab 5'  $'\e[45m'
    mshex/term/register-key bDY   'setab 3'  $'\e[43m'
    mshex/term/register-key bDK   'setab 0'  $'\e[40m'
    mshex/term/register-key bDW   'setab 7'  $'\e[47m'
    echo -n '*' >&2
    mshex/term/register-key bHR   'setab 9'  $'\e[101m'
    mshex/term/register-key bHG   'setab 10' $'\e[102m'
    mshex/term/register-key bHB   'setab 12' $'\e[104m'
    mshex/term/register-key bHC   'setab 14' $'\e[106m'
    mshex/term/register-key bHM   'setab 13' $'\e[105m'
    mshex/term/register-key bHY   'setab 11' $'\e[103m'
    mshex/term/register-key bHK   'setab 8'  $'\e[100m'
    mshex/term/register-key bHW   'setab 15' $'\e[107m'
    echo -n '*' >&2
    mshex/term/register-key sgr0  'sgr0'     $'\e[m'
    echo " done" >&2
  fi
}
mshex/term/color.init

#------------------------------------------------------------------------------
# mshex/term/readkey

function mshex/term/readkey/keymap-def {
  local kseq=$1
  local kname=$2
  mshex/dict/.set _mshex_term_keymap "x$kseq" "$kname"
}

function mshex/term/readkey/keymap-tdef {
  local tname=$1
  local default=$2
  local kname=$3
  mshex/term/register-key "$tname" "$tname" "$default"

  local kseq
  mshex/dict "kseq=_mshex_term[$tname]"
  mshex/dict/.set _mshex_term_keymap "x$kseq" "$kname"
}

# 47ms
# ※bash-3.1 で '^@' があるとエラーになる。
mshex/term/readkey/keymap-def $'\0' C-@ # 空白になる
mshex/term/readkey/keymap-def '' C-a
mshex/term/readkey/keymap-def '' C-b
mshex/term/readkey/keymap-def '' C-c
mshex/term/readkey/keymap-def '' C-d
mshex/term/readkey/keymap-def '' C-e
mshex/term/readkey/keymap-def '' C-f
mshex/term/readkey/keymap-def $'\a' C-g
mshex/term/readkey/keymap-def $'\b' C-h
mshex/term/readkey/keymap-def $'\t' TAB
mshex/term/readkey/keymap-def $'\n' C-j
mshex/term/readkey/keymap-def $'\v' C-k
mshex/term/readkey/keymap-def $'\f' C-l
mshex/term/readkey/keymap-def $'\r' RET
mshex/term/readkey/keymap-def '' C-n
mshex/term/readkey/keymap-def '' C-o
mshex/term/readkey/keymap-def '' C-p
mshex/term/readkey/keymap-def '' C-q
mshex/term/readkey/keymap-def '' C-r
mshex/term/readkey/keymap-def '' C-s
mshex/term/readkey/keymap-def '' C-t
mshex/term/readkey/keymap-def '' C-u
mshex/term/readkey/keymap-def '' C-v
mshex/term/readkey/keymap-def '' C-w
mshex/term/readkey/keymap-def '' C-x
mshex/term/readkey/keymap-def '' C-y
mshex/term/readkey/keymap-def '' C-z

mshex/term/readkey/keymap-def ' ' SP

mshex/term/readkey/keymap-def $'\e[A' up
mshex/term/readkey/keymap-def $'\e[B' down
mshex/term/readkey/keymap-def $'\e[C' right
mshex/term/readkey/keymap-def $'\e[D' left
mshex/term/readkey/keymap-def $'\eOA' up
mshex/term/readkey/keymap-def $'\eOB' down
mshex/term/readkey/keymap-def $'\eOC' right
mshex/term/readkey/keymap-def $'\eOD' left
mshex/term/readkey/keymap-tdef kcuu1 $'\eOA' up
mshex/term/readkey/keymap-tdef kcud1 $'\eOB' down
mshex/term/readkey/keymap-tdef kcuf1 $'\eOC' right
mshex/term/readkey/keymap-tdef kcub1 $'\eOD' left
mshex/term/readkey/keymap-tdef khome $'\e[1~' home
mshex/term/readkey/keymap-tdef kich1 $'\e[2~' insert
mshex/term/readkey/keymap-tdef kdch1 $'\e[3~' delete
mshex/term/readkey/keymap-tdef kend  $'\e[4~' end
mshex/term/readkey/keymap-tdef kpp   $'\e[5~' prev
mshex/term/readkey/keymap-tdef knp   $'\e[6~' next

## function mshex/term/readkey/.readchar
if ((mwg_bash>=40100)); then
  # -N は 40100 以降
  function mshex/term/readkey/.readchar {
    IFS= read -srN 1 "$1"
  }
  mshex/term/readkey/keymap-def '' C-@
else
  # -n は 20400 以降
  function mshex/term/readkey/.readchar {
    IFS= read -srn 1 "$1"
  }
  mshex/term/readkey/keymap-def '' RET
fi

## mshex/term/readkey/.impl
## @env[out] _ret
function mshex/term/readkey/.impl {
  local s= c
  while mshex/term/readkey/.readchar c; do
    s=$s$c

    local key skey keys m=0
    mshex/dict 'keys=(!_mshex_term_keymap[@])'
    for key in "${keys[@]}"; do
      local seq=${key:1}
      if [[ $s == "$seq" ]]; then
        skey=$key
        ((m++))
      elif [[ $seq == "$s"* ]]; then
        ((m+=2))
      fi
    done
    
    if ((m==1)); then
      mshex/dict "_ret=_mshex_term_keymap[$skey]"
      return 0
    elif ((m==0)); then
      _ret=$s
      return 1
    fi
  done
}

function mshex/term/readkey {
  local _vname=$1
  local _ret _ext
  mshex/term/readkey/.impl; _ext=$?
  eval "$_vname=\$_ret"
  return "$_ext"
}

#------------------------------------------------------------------------------
# set_title
mshex/term/register_cap hs hs
mshex/term/register-key tsl tsl $'\e]0;'
mshex/term/register-key fsl fsl $'\a'
function mshex/term/set_title {
  local title=$1
  case "$TERM" in
  (screen*)
    printf '\e]0;%s\a\ek%s\e\\' "$title" "$title" ;;
  (*)
    local hs; mshex/dict 'hs=_mshex_term[hs]'
    if [[ $hs == 1 ]]; then
      local tsl fsl; mshex/dict 'tsl=_mshex_term[tsl]' 'fsl=_mshex_term[fsl]'
      printf %s "$tsl${title}$fsl"
    fi ;;
  esac
}

function mshex/term/set_title.escaped {
  local bs='\'
  local title=$1
  case "$TERM" in
  (screen*)
    printf '\e]0;%s\a\ek%s\e\\\\' "$title" "$title" ;;
  (*)
    local hs; mshex/dict 'hs=_mshex_term[hs]'
    if [[ $hs == 1 ]]; then
      local tsl fsl; mshex/dict 'tsl=_mshex_term[tsl]' 'fsl=_mshex_term[fsl]'
      tsl=${tsl//"$bs"/"$bs$bs"}
      fsl=${fsl//"$bs"/"$bs$bs"}
      printf %s "$tsl${title}$fsl"
    fi ;;
  esac
}
