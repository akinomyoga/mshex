#!/bin/bash
# -*- mode:sh;coding:utf-8 -*-

# shell functions

# bash-version
declare -i mwg_bash=$((${BASH_VERSINFO[0]}*10000+${BASH_VERSINFO[1]}*100+${BASH_VERSINFO[2]}))

function source_if { [[ -e $1 ]] && source "$@" >/dev/null; }

function mkd { [[ -d $1 ]] || mkdir -p "$1"; }

#------------------------------------------------------------------------------
# PATH : environmental variable

function mwg.PATH.add {
  mwg.PATH.remove "$@"

  local name=$1; shift
  local paths; eval "paths=\${$name}"
  for p in "$@"; do
    paths=$p${paths:+:}$paths
  done
  eval "export $name='$paths'"
}

function mwg.PATH.append {
  mwg.PATH.remove "$@"

  local name=$1; shift
  local paths; eval "paths=\${$name}"
  for p in "$@"; do
    paths="$paths${paths:+:}$p"
  done
  eval "export $name='$paths'"
}

function mwg.PATH.remove {
  local name=$1; shift
  local paths; eval "paths=\${$name}"
  for p in "$@"; do
    paths="${paths//:$p:/:}"
    paths="${paths#$p:}"
    paths="${paths%:$p}"
    if [[ $paths == "$p" ]]; then
      paths=''
      break
    fi
  done
  #echo "export $name='$paths'"
  eval "export $name='$paths'"
}

function mwg.PATH.show {
  local name=${1-PATH} | sed 's/:/\n/g'
  eval "echo \"\${$name}\""
}

#------------------------------------------------------------------------------
# String manipulations

mwg_String_table_lalpha='abcdefghijklmnopqrstuvwxyz'
mwg_String_table_ualpha='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
function mwg.String.Uppercase.__get {
  if ((mwg_bash>=40100)); then
    return="${*^^?}"
  else
    # return="$(echo -n "$*"|tr a-z A-Z)"

    local text="$*" i
    return=
    for ((i=0;i<${#text};i++));do
      local c=${text:i:1}
      local index_tmp=${mwg_String_table_lalpha%%$c*}
      local index=${#index_tmp}
      if ((index<26)); then
        return=$return${mwg_String_table_ualpha:index:1}
      else
        return=$return$c
      fi
    done
  fi
}

function mwg.String.Lowercase.__get {
  if ((mwg_bash >=40100)); then
    return="${*,,?}"
  else
    # return="$(echo -n "$*"|tr a-z A-Z)"

    local text="$*" i
    return=
    for ((i=0;i<${#text};i++));do
      local c=${text:i:1}
      local index_tmp=${mwg_String_table_ualpha%%$c*}
      local index=${#index_tmp}
      if ((index<26)); then
        return=$return${mwg_String_table_lalpha:index:1}
      else
        return=$return$c
      fi
    done
  fi
}

declare mwg_Char_ToCharCode_table
function mwg_Char_ToCharCode_table.init {
  local table00=$'\x3f\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f'
  local table01=$'\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f'
  local table02=$'\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f'
  local table03=$'\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x3e\x3f'
  local table04=$'\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f'
  local table05=$'\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5a\x5b\x5c\x5d\x5e\x5f'
  local table06=$'\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f'
  local table07=$'\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f'
  local table08=$'\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f'
  local table09=$'\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f'
  local table0a=$'\xa0\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf'
  local table0b=$'\xb0\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf'
  local table0c=$'\xc0\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf'
  local table0d=$'\xd0\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc\xdd\xde\xdf'
  local table0e=$'\xe0\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef'
  local table0f=$'\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff'
  mwg_Char_ToCharCode_table="$table00$table01$table02$table03$table04$table05$table06$table07$table08$table09$table0a$table0b$table0c$table0d$table0e$table0f"
}
mwg_Char_ToCharCode_table.init
function mwg.Char.ToCharCode.__get {
  local c="${1:0:1}"
  if [[ "$c" == '?' ]]; then
    return=63
  elif [[ "$c" == '*' ]]; then
    return=42
  else
    local tmp=${mwg_Char_ToCharCode_table%%$c*}
    return=${#tmp}
  fi

  # 実は printf -v return '%d' "'${1:0:1}" の一行で OK かも
  # <a href="http://stackoverflow.com/questions/890262/integer-ascii-value-to-character-in-bash-using-printf">Integer ASCII value to character in BASH using printf - Stack Overflow</a>
}

function mwg.Char.ToHexCode.__get {
  mwg.Char.ToCharCode.__get "$1"
  local -i n=$return
  local hi=$((n/16))
  local lo=$((n%16))

  case "$hi" in
  10) hi=a ;;
  11) hi=b ;;
  12) hi=c ;;
  13) hi=d ;;
  14) hi=e ;;
  15) hi=f ;;
  esac
  case "$lo" in
  10) lo=a ;;
  11) lo=b ;;
  12) lo=c ;;
  13) lo=d ;;
  14) lo=e ;;
  15) lo=f ;;
  esac
  return=$hi$lo
}

function mwg.String.HexEncode.__get {
  local text="$*"
  local code=

  local i
  for ((i=0;i<${#text};i++));do
    mwg.Char.ToHexCode.__get ${text:i:1}
    code=$code$return
  done

  return=$code
}

mwg_String_Base64_table='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
if which base64 &>/dev/null; then
  mwg_String_Base64_which=1
fi
function mwg.String.Base64Encode.__get {
  local text="$*" i j s
  if ((${#text}>150)) && [[ $mwg_String_Base64_which ]]; then
    return=$(echo -n "$text" | base64)
    return
  fi

  unset 'buff[*]'
  local -a buff=()
  for ((i=0;i<${#text};i+=3)); do
    local cook=${text:i:3}

    ((s=0))
    for ((j=0;j<3;j++));do
      mwg.Char.ToCharCode.__get "${cook:j:1}"
      ((s=s*256+return))
    done

    local quartet=
    for ((j=3;j>=0;j--));do
      if ((j>${#cook})); then
        quartet="=$quartet"
      else
        quartet=${mwg_String_Base64_table:$((s%64)):1}$quartet
      fi
      ((s/=64))
    done

    buff[${#buff[*]}]=$quartet
  done

  local IFS=
  return="${buff[*]}"
}

function mwg.String.Base64Encode {
  local return=
  mwg.String.Base64Encode.__get "$@"
  echo "$return"
}

function mwg.String.EndsWith {
  [[ $1 == *"$2" ]]
}
function mwg.String.StartsWith {
  [[ $1 == "$2"* ]]
}
