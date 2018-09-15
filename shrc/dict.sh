#!/bin/bash

# 連想配列の機能
#
# usage
#   eval "$(mshex/dict new:h)"
#     declares the dictionary variable
#
#   mshex/dict h[key]=val
#     associates `val' with the specified `key'.
#
#   mshex/dict h[key]
#     prints the value associated with the `key'.
#
#   mshex/dict var=h[key]
#     sets the value associated with the `key' to the variable `var'.
#
#   mshex/dict unset:h[key]
#     NOT YET IMPLEMENTED
#
# ChangeLog
#
#   2013-05-27, KM, created
#     * implementation for bash-4, zsh
#     * `mshex/dict -n:hash[key]', `mshex/dict -z:hash[key]'
#     * `mshex/dict set:hash [k1]=v1 [k2]=v2'
#
#   2013-05-28, KM
#     * implementation for bash-3
#
#   2014-08-03, KM
#     * 'declare:hash', 'local:hash' に対応
#     * 'keys=(!hash[@])' に対応
#

((_mshex_dict_PragmaOnce>=1)) && return
_mshex_dict_PragmaOnce=1

if [[ $ZSH_VERSION || $mwg_bash -ge 40000 ]]; then
  _mshex_dict_declare=(-A DICTNAME)
  function mshex/dict/.new {
    local declare=$1
    local hname=$2
    echo "$declare -A '$hname'"
    # declare -gA '$hname' # for bash-4.2
  }
  function mshex/dict/.set {
    local hname=$1
    local key=$2
    local value=$3
    eval "${hname}[\$key]=\"\$value\""
  }
  function mshex/dict/.echo {
    local hname=$1
    local key=$2
    eval "echo \"\${$hname[\$key]}\""
  }
  function mshex/dict/.get {
    local vname=$1
    local hname=$2
    local key=$3
    eval "$vname=\"\${$hname[\$key]}\""
  }
  function mshex/dict/.getkeys {
    local vname=$1
    local hname=$2
    eval "$vname=(\"\${!$hname[@]}\")"
  }

  # # key に特別な値が含まれている場合に困る
  # # 一つの hname に対する処理なのだからもっと簡単にできる方法がある筈。
  # # というか declare -p $hname で充分なのではないか??
  # # でもそれだと追記が難しい。
  # function mshex/dict/.save {
  #   local hname="$1"
  #   local fname="$2"
  #   local -a keys
  #   mshex/dict/.getkeys keys "$hname"
  #   :> "$fname"
  #   for key in "${keys[@]}"; do
  #     echo "mshex/dict '$hname[$key]=${hname[$key]}'" >> "$fname"
  #   done
  # }
else
  _mshex_dict_declare=(-a __mwg_hash__DICTNAME__key __mwg_hash__DICTNAME__val)
  function mshex/dict/.new {
    local declare=$1
    local hname=$2
    echo "$declare -a '__mwg_hash__${hname}__key'"
    echo "$declare -a '__mwg_hash__${hname}__val'"
  }
  function mshex/dict/.set {
    # mshex/dict/.set hash key value
    local hname=$1
    local key=$2
    local value=$3
    local script='
      local i
      for ((i=0;i<${#__mwg_hash__HNAME__key[@]};i++)); do
        if [[ ${__mwg_hash__HNAME__key[i]} == "$key" ]]; then
          __mwg_hash__HNAME__val[i]=$value
          break
        fi
      done
      
      if ((i==${#__mwg_hash__HNAME__key[@]})); then
        __mwg_hash__HNAME__key[i]=$key
        __mwg_hash__HNAME__val[i]=$value
      fi
    '
  
    eval "${script//HNAME/$hname}"
  }
  function mshex/dict/.echo {
    local hname=$1
    local key=$2
    local script='
      local i
      for ((i=0;i<${#__mwg_hash__HNAME__key[@]};i++)); do
        if [[ ${__mwg_hash__HNAME__key[i]} == "$key" ]]; then
          echo "${__mwg_hash__HNAME__val[i]}"
          break
        fi
      done
    '
  
    eval "${script//HNAME/$hname}"
  }
  function mshex/dict/.get {
    local vname=$1
    local hname=$2
    local key=$3
    local script='
      local i
      for ((i=0;i<${#__mwg_hash__HNAME__key[@]};i++)); do
        if test "${__mwg_hash__HNAME__key[$i]}" == "$key"; then
          VNAME="${__mwg_hash__HNAME__val[$i]}"
          break
        fi
      done
    '
  
    script=${script//VNAME/$vname}
    eval "${script//HNAME/$hname}"
  }
  function mshex/dict/.getkeys {
    eval "$1=(\"\${__mwg_hash__${2}__key[@]}\")"
  }
fi


function mshex/dict {
  local hname_=
  while (($#)); do
    local expr=$1;
    case "$expr" in
    (new:?*|declare:?*|local:?*) # new:hname[key]=value
      local hname=${expr#*:}
      local decl=${expr%%:*}
      test $decl = new && decl=declare
      mshex/dict/.new "$decl" "$hname"
      hname_=$hname ;;
    (set:?*) # hname:
      hname_=${expr#*:} ;;
    (*\[*\]=*) # hname[key]=value
      local hname=${expr%%\[*}
      expr=${expr:$((${#hname}+1))}
      local key=${expr%%\]=*}
      local value=${expr:$((${#key}+2))}

      [[ ! $hname ]] && hname=$hname_
      if [[ $hname ]]; then
        mshex/dict/.set "$hname" "$key" "$value"
      else
        echo "mshex/dict: the dictionary name is not specified. ($1)" 1>&2
      fi
      ;;
    (-[nz]:?*\[*\]) # -n:hname[key] -z:hname[key]
      local flag=${expr:1:1}; expr=${expr:3}
      local hname=${expr%%\[*}
      local key=${expr:${#hname}+1}; key=${key%\]}
      local tmp=
      mshex/dict/.get tmp "$hname" "$key"
      test -$flag "$tmp"
      return ;;
    (?*=?*\[*\]) # vname=hname[key]
      local head=${expr%%\[*}
      local key=${expr:${#head}+1}; key=${key%\]}
      local hname=${head##*=}
      local vname=${head%=*}
      mshex/dict/.get "$vname" "$hname" "$key" ;;
    (?*\[*\]) # hname[key]
      local hname=${expr%%\[*}
      local key=${expr:${#hname}+1}; key=${key%\]}
      mshex/dict/.echo "$hname" "$key" ;;
    (?*'=(!'*'[@])') # keys=(!hname[@])
      local vname=${expr%=\(\!*\[@\]\)}
      local hname=${expr:${#vname}+3:${#expr}-${#vname}-7}
      mshex/dict/.getkeys "$vname" "$hname" ;;
    (*)
      echo "mshex/dict: unknown operation '$1'" 1>&2
      ;;
    esac
    shift
  done
}

# eval "$(mshex/dict new:hash new:hoge new:season)"
# mshex/dict 'hash[key]=value'
# mshex/dict 'hoge[koge]=fdaaa'
# mshex/dict 'hoge[moge]=hahaha'
# mshex/dict 'hoge[koge]'
# mshex/dict 'season[haru]=spring'
# mshex/dict 'season[natsu]=summer'
# mshex/dict 'season[aki]=autumn'
# mshex/dict 'season[fuyu]=winter'
# mshex/dict 'season[aki]=fall'
# mshex/dict 'x=season[aki]'
# echo "x=$x"

# mshex/dict -n:'season[haru]' && echo ok1
# mshex/dict -n:'season[hoge]' && echo ng2
# mshex/dict -z:'season[haru]' && echo ng3
# mshex/dict -z:'season[hoge]' && echo ok4
