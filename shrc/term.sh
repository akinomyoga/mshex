#!/bin/bash
## -*- coding:utf-8 -*-
## $HOME/.mwg/share/mshex/shrc/term.sh
##
## Copyright (c) 2010-2013 Koichi MURASE <murase@nt.phys.s.u-tokyo.ac.jp>, <myoga.murase@gmail.com>
## 
## terminfo/termcap manipulators
##
## mwg_term.echo         name
## mwg_term.register_key name tputargs defaultValue
## mwg_term.register_cap name value
##
## mwg_term.readkey     var
## mwg_term_keymap.def  kseq kname
## mwg_term_keymap.tdef tname kseq kname
##
## mwg_term.set_title         title
## mwg_term.set_title.escaped title

((__mwg_mshex_term__PragmaOnce>=2)) && return
__mwg_mshex_term__PragmaOnce=2

declare "${mwg_dict_declare[@]//DICTNAME/mwg_term}"
declare "${mwg_dict_declare[@]//DICTNAME/mwg_term_keymap}"

#------------------------------------------------------------------------------
# mwg_term

mwg_term/.cache.fname(){
  local varname=
  test "x$1" = x-v && varname="$2"

  local shrc=common
  local cachedir="$MWGDIR/share/mshex/$shrc.cache"
  if test ! -d "$cachedir"; then
    if test -d "$MWGDIR/shrc.d/$shrc"; then
      mv "$MWGDIR/shrc.d/$shrc" "$cachedir"
    else
      mkdir -p "$cachedir"
    fi
  fi

  local cache="$cachedir/mwg_term.$TERM"
  if test ! -s "$cache"; then
    cat <<EOF > "$cache"
mwg.dict 'mwg_term[f:cuu]=[%dA'
mwg.dict 'mwg_term[f:cud]=[%dB'
mwg.dict 'mwg_term[f:cuf]=[%dC'
mwg.dict 'mwg_term[f:cub]=[%dD'
mwg.dict 'mwg_term[f:il]=[%dL'
mwg.dict 'mwg_term[f:dl]=[%dM'
mwg.dict 'mwg_term[f:cup]=[%d;%dH'
EOF
  fi

  if test -n "$varname"; then
    eval "$varname=\"$cache\""
  else
    echo -n "$cache"
  fi
}

mwg_term/.cache.load() {
  local fcache
  mwg_term/.cache.fname -v fcache
  source "$fcache"
}
mwg_term/.cache.set() {
  local fcache
  mwg_term/.cache.fname -v fcache

  mwg.dict "mwg_term[$1]=$2"
  echo "mwg.dict 'mwg_term[$1]=$2'" >> "$fcache"
}
mwg_term.echo(){
  mwg.dict "mwg_term[$1]"
}
mwg_term.register_key() {
  local name="$1"
  local tiargs="$2"
  local def="$3"
  if mwg.dict -z:"mwg_term[$name]"; then
    mwg_term/.cache.set "$name" "$(tput $tiargs 2>/dev/null || echo -n "$def")"
  fi
}
mwg_term.register_cap() {
  local name="$1"
  local tiargs="$2"
  if mwg.dict -z:"mwg_term[$name]"; then
    if tput $tiargs &>/dev/null; then
      mwg_term/.cache.set "$name" 1 # true
    else
      mwg_term/.cache.set "$name" 0 # false
    fi
  fi
}

# 62ms
mwg_term/.cache.load

#------------------------------------------------------------------------------
# mwg_term.color

mwg_term.color.init(){
  if mwg.dict -z:'mwg_term[sgr0]'; then
    echo -n "initializing mwg_term colors... " >&2
    mwg_term.register_key fDR   'setaf 1'  '[31m'
    mwg_term.register_key fDG   'setaf 2'  '[32m'
    mwg_term.register_key fDB   'setaf 4'  '[34m'
    mwg_term.register_key fDC   'setaf 6'  '[36m'
    mwg_term.register_key fDM   'setaf 5'  '[35m'
    mwg_term.register_key fDY   'setaf 3'  '[33m'
    mwg_term.register_key fDK   'setaf 0'  '[30m'
    mwg_term.register_key fDW   'setaf 7'  '[37m'
    echo -n '*' >&2
    mwg_term.register_key fHR   'setaf 9'  '[91m'
    mwg_term.register_key fHG   'setaf 10' '[92m'
    mwg_term.register_key fHB   'setaf 12' '[94m'
    mwg_term.register_key fHC   'setaf 14' '[96m'
    mwg_term.register_key fHM   'setaf 13' '[95m'
    mwg_term.register_key fHY   'setaf 11' '[93m'
    mwg_term.register_key fHK   'setaf 8'  '[90m'
    mwg_term.register_key fHW   'setaf 15' '[97m'
    echo -n '*' >&2
    mwg_term.register_key bDR   'setab 1'  '[41m'
    mwg_term.register_key bDG   'setab 2'  '[42m'
    mwg_term.register_key bDB   'setab 4'  '[44m'
    mwg_term.register_key bDC   'setab 6'  '[46m'
    mwg_term.register_key bDM   'setab 5'  '[45m'
    mwg_term.register_key bDY   'setab 3'  '[43m'
    mwg_term.register_key bDK   'setab 0'  '[40m'
    mwg_term.register_key bDW   'setab 7'  '[47m'
    echo -n '*' >&2
    mwg_term.register_key bHR   'setab 9'  '[101m'
    mwg_term.register_key bHG   'setab 10' '[102m'
    mwg_term.register_key bHB   'setab 12' '[104m'
    mwg_term.register_key bHC   'setab 14' '[106m'
    mwg_term.register_key bHM   'setab 13' '[105m'
    mwg_term.register_key bHY   'setab 11' '[103m'
    mwg_term.register_key bHK   'setab 8'  '[100m'
    mwg_term.register_key bHW   'setab 15' '[107m'
    echo -n '*' >&2
    mwg_term.register_key sgr0  'sgr0'     '[m'
    echo " done" >&2
  fi
}
mwg_term.color.init

#------------------------------------------------------------------------------
# mwg_term.readkey

function mwg_term_keymap.def {
  local kseq="$1"
  local kname="$2"
  mwg.dict.set mwg_term_keymap "x$kseq" "$kname"
}

function mwg_term_keymap.tdef {
  local tname="$1"
  local default="$2"
  local kname="$3"
  mwg_term.register_key "$tname" "$tname" "$default"

  local kseq
  mwg.dict "kseq=mwg_term[$tname]"
  mwg.dict.set mwg_term_keymap "x$kseq" "$kname"
}

# 47ms
# ※bash-3.1 で '^@' があるとエラーになる。
mwg_term_keymap.def $'\0' C-@ # 空白になる
mwg_term_keymap.def '' C-a
mwg_term_keymap.def '' C-b
mwg_term_keymap.def '' C-c
mwg_term_keymap.def '' C-d
mwg_term_keymap.def '' C-e
mwg_term_keymap.def '' C-f
mwg_term_keymap.def '' C-g
mwg_term_keymap.def $'\b' C-h
mwg_term_keymap.def $'\t' TAB
mwg_term_keymap.def $'\n' C-j
mwg_term_keymap.def '' C-l
mwg_term_keymap.def '' RET
mwg_term_keymap.def '' C-n
mwg_term_keymap.def '' C-o
mwg_term_keymap.def '' C-p
mwg_term_keymap.def '' C-q
mwg_term_keymap.def '' C-r
mwg_term_keymap.def '' C-s
mwg_term_keymap.def '' C-t
mwg_term_keymap.def '' C-u
mwg_term_keymap.def '' C-v
mwg_term_keymap.def '' C-w
mwg_term_keymap.def '' C-x
mwg_term_keymap.def '' C-y
mwg_term_keymap.def '' C-z

mwg_term_keymap.def ' ' SP

mwg_term_keymap.def '[A' up
mwg_term_keymap.def '[B' down
mwg_term_keymap.def '[C' right
mwg_term_keymap.def '[D' left
mwg_term_keymap.def 'OA' up
mwg_term_keymap.def 'OB' down
mwg_term_keymap.def 'OC' right
mwg_term_keymap.def 'OD' left
mwg_term_keymap.tdef kcuu1 'OA' up
mwg_term_keymap.tdef kcud1 'OB' down
mwg_term_keymap.tdef kcuf1 'OC' right
mwg_term_keymap.tdef kcub1 'OD' left
mwg_term_keymap.tdef khome '[1~' home
mwg_term_keymap.tdef kich1 '[2~' insert
mwg_term_keymap.tdef kdch1 '[3~' delete
mwg_term_keymap.tdef kend  '[4~' end
mwg_term_keymap.tdef kpp   '[5~' prev
mwg_term_keymap.tdef knp   '[6~' next

## function mwg_term/.read-char
if ((mwg_bash>=40100)); then
  # -N は 40100 以降
  function mwg_term/.read-char {
    IFS= read -srN 1 "$1"
  }
  mwg_term_keymap.def '' C-@
else
  # -n は 20400 以降
  function mwg_term/.read-char {
    IFS= read -srn 1 "$1"
  }
  mwg_term_keymap.def '' RET
fi

## mwg_term/.readkey-impl
## @env[out] _ret
function mwg_term/.readkey-impl {
  local s= c
  while mwg_term/.read-char c; do
    s="$s$c"

    local key skey m=0
    mwg.dict 'keys=(!mwg_term_keymap[@])'
    for key in "${keys[@]}"; do
      local seq="${key:1}"
      if test "$s" == "$seq"; then
        skey="$key"
        let m++
      elif test "${seq#$s}" != "$seq"; then
        let m+=2
      fi
    done
    
    if ((m==1)); then
      mwg.dict "_ret=mwg_term_keymap[$skey]"
      return 0
    elif ((m==0)); then
      _ret="$s"
      return 1
    fi
  done
}

function mwg_term.readkey {
  local _vname="$1"
  local _ret _ext
  mwg_term/.readkey-impl; _ext=$?
  eval "$_vname=\"\$_ret\""
  return $_ext
}

#------------------------------------------------------------------------------
# set_title
mwg_term.register_cap hs hs
mwg_term.register_key tsl tsl ']0;'
mwg_term.register_key fsl fsl ''
mwg_term.set_title() {
  local title="$1"
  case "$TERM" in
  screen*)
    echo -n "]0;${title}""k${title}\\";;
  *)
    local hs; mwg.dict 'hs=mwg_term[hs]'
    if test "$hs" == 1; then
      local tsl fsl; mwg.dict 'tsl=mwg_term[tsl]' 'fsl=mwg_term[fsl]'
      echo -n "$tsl${title}$fsl"
    fi
    ;;
  esac
}

mwg_term.set_title.escaped() {
  local bs='\'
  local title="$1"
  case "$TERM" in
  screen*)
    echo -n "]0;${title}""k${title}\\\\";;
  *)
    local hs; mwg.dict 'hs=mwg_term[hs]'
    if test "$hs" == 1; then
      local tsl fsl; mwg.dict 'tsl=mwg_term[tsl]' 'fsl=mwg_term[fsl]'
      tsl=${tsl//"$bs"/"$bs$bs"}
      fsl=${fsl//"$bs"/"$bs$bs"}
      echo -n "$tsl${title}$fsl"
    fi
    ;;
  esac
}
