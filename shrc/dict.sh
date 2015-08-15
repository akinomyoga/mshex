#!/bin/bash

# 連想配列の機能
#
# usage
#   eval "$(mwg.dict new:h)"
#     declares the dictionary variable
#
#   mwg.dict h[key]=val
#     associates `val' with the specified `key'.
#
#   mwg.dict h[key]
#     prints the value associated with the `key'.
#
#   mwg.dict var=h[key]
#     sets the value associated with the `key' to the variable `var'.
#
#   mwg.dict unset:h[key]
#     NOT YET IMPLEMENTED
#
# ChangeLog
#
#   2013-05-27, KM, created
#     * implementation for bash-4, zsh
#     * `mwg.dict -n:hash[key]', `mwg.dict -z:hash[key]'
#     * `mwg.dict set:hash [k1]=v1 [k2]=v2'
#
#   2013-05-28, KM
#     * implementation for bash-3
#
#   2014-08-03, KM
#     * 'declare:hash', 'local:hash' に対応
#     * 'keys=(!hash[@])' に対応
#

((__mwg_mshex_dict__PragmaOnce>=1)) && return
__mwg_mshex_dict__PragmaOnce=1

if [[ $ZSH_VERSION || $mwg_bash -ge 40000 ]]; then
  mwg_dict_declare=(-A DICTNAME)
  function mwg.dict/.new {
    local declare="$1"
    local hname="$2"
    echo "$declare -A '$hname'"
    # declare -gA '$hname' # for bash-4.2
  }
  mwg.dict.set () {
    local hname="$1"
    local key="$2"
    local value="$3"
    eval "${hname}[\$key]=\"\$value\""
  }
  mwg.dict.echo () {
    local hname="$1"
    local key="$2"
    eval "echo \"\${$hname[\$key]}\""
  }
  mwg.dict.get () {
    local vname="$1"
    local hname="$2"
    local key="$3"
    eval "$vname=\"\${$hname[\$key]}\""
  }
  function mwg.dict/.getkeys {
    local vname="$1"
    local hname="$2"
    eval "$vname=(\"\${!$hname[@]}\")"
  }

  # # key に特別な値が含まれている場合に困る
  # # 一つの hname に対する処理なのだからもっと簡単にできる方法がある筈。
  # # というか declare -p $hname で充分なのではないか??
  # # でもそれだと追記が難しい。
  # function mwg.dict.save {
  #   local hname="$1"
  #   local fname="$2"
  #   local -a keys
  #   mwg.dict/.getkeys keys "$hname"
  #   :> "$fname"
  #   for key in "${keys[@]}"; do
  #     echo "mwg.dict '$hname[$key]=${hname[$key]}'" >> "$fname"
  #   done
  # }
else
  mwg_dict_declare=(-a __mwg_hash__DICTNAME__key __mwg_hash__DICTNAME__val)
  function mwg.dict/.new {
    local declare="$1"
    local hname="$2"
    echo "$declare -a '__mwg_hash__${hname}__key'"
    echo "$declare -a '__mwg_hash__${hname}__val'"
  }
  mwg.dict.set () {
    # mwg.dict.set hash key value
    local hname="$1"
    local key="$2"
    local value="$3"
    local script='
      local i
      for ((i=0;i<${#__mwg_hash__HNAME__key[@]};i++)); do
        if test "${__mwg_hash__HNAME__key[$i]}" == "$key"; then
          __mwg_hash__HNAME__val[$i]="$value"
          break
        fi
      done
      
      if test "$i" -eq ${#__mwg_hash__HNAME__key[@]}; then
        __mwg_hash__HNAME__key[$i]="$key"
        __mwg_hash__HNAME__val[$i]="$value"
      fi
    '
  
    eval "${script//HNAME/$hname}"
  }
  mwg.dict.echo () {
    local hname="$1"
    local key="$2"
    local script='
      local i
      for ((i=0;i<${#__mwg_hash__HNAME__key[@]};i++)); do
        if test "${__mwg_hash__HNAME__key[$i]}" == "$key"; then
          echo "${__mwg_hash__HNAME__val[$i]}"
          break
        fi
      done
    '
  
    eval "${script//HNAME/$hname}"
  }
  mwg.dict.get () {
    local vname="$1"
    local hname="$2"
    local key="$3"
    local script='
      local i
      for ((i=0;i<${#__mwg_hash__HNAME__key[@]};i++)); do
        if test "${__mwg_hash__HNAME__key[$i]}" == "$key"; then
          VNAME="${__mwg_hash__HNAME__val[$i]}"
          break
        fi
      done
    '
  
    script="${script//VNAME/$vname}"
    eval "${script//HNAME/$hname}"
  }
  function mwg.dict/.getkeys {
    eval "$1=(\"\${__mwg_hash__${2}__key[@]}\")"
  }
fi


mwg.dict () {
  local hname_=
  while test $# -gt 0; do
    local expr="$1";
    case "$expr" in
    (new:?*|declare:?*|local:?*) # new:hname[key]=value
      local hname="${expr#*:}"
      local decl="${expr%%:*}"
      test $decl = new && decl=declare
      mwg.dict/.new "$decl" "$hname"
      hname_="$hname"
      ;;
    (set:?*) # hname:
      hname_="${expr#*:}"
      ;;
    (*\[*\]=*) # hname[key]=value
      local hname="${expr%%\[*}"
      expr="${expr:$((${#hname}+1))}"
      local key="${expr%%\]=*}"
      local value="${expr:$((${#key}+2))}"

      test -z "$hname" && hname="$hname_"
      if test -n "$hname"; then
        mwg.dict.set "$hname" "$key" "$value"
      else
        echo "mwg.dict: the dictionary name is not specified. ($1)" 1>&2
      fi
      ;;
    (-[nz]:?*\[*\]) # -n:hname[key] -z:hname[key]
      local flag="${expr:1:1}"; expr="${expr:3}"
      local hname="${expr%%\[*}"
      local key="${expr:$((${#hname}+1))}"; key="${key%\]}"
      local tmp=
      mwg.dict.get tmp "$hname" "$key"
      test -$flag "$tmp"
      return ;;
    (?*=?*\[*\]) # vname=hname[key]
      local head="${expr%%\[*}"
      local key="${expr:$((${#head}+1))}"; key="${key%\]}"
      local hname="${head##*=}"
      local vname="${head%=*}"
      mwg.dict.get "$vname" "$hname" "$key" ;;
    (?*\[*\]) # hname[key]
      local hname="${expr%%\[*}"
      local key="${expr:$((${#hname}+1))}"; key="${key%\]}"
      mwg.dict.echo "$hname" "$key" ;;
    (?*'=(!'*'[@])') # keys=(!hname[@])
      local vname="${expr%=\(\!*\[@\]\)}"
      local hname="${expr:${#vname}+3:${#expr}-${#vname}-7}"
      mwg.dict/.getkeys "$vname" "$hname" ;;
    (*)
      echo "mwg.dict: unknown operation '$1'" 1>&2
      ;;
    esac
    shift
  done
}

# eval "$(mwg.dict new:hash new:hoge new:season)"
# mwg.dict hash[key]='value'
# mwg.dict hoge[koge]='fdaaa'
# mwg.dict hoge[moge]='hahaha'
# mwg.dict hoge[koge]
# mwg.dict season[haru]=spring
# mwg.dict season[natsu]=summer
# mwg.dict season[aki]=autumn
# mwg.dict season[fuyu]=winter
# mwg.dict season[aki]=fall
# mwg.dict x=season[aki]
# echo "x=$x"

# mwg.dict -n:season[haru] && echo ok1
# mwg.dict -n:season[hoge] && echo ng2
# mwg.dict -z:season[haru] && echo ng3
# mwg.dict -z:season[hoge] && echo ok4
