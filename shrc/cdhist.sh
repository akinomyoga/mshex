#!/bin/bash
## 
## $HOME/.mwg/cdhist.sh
##   requires $HOME/.mwg/bashrc_interactive.sh
## 
## copyright (c) 2012-2014 Koichi Murase <murase@nt.phys.s.u-tokyo.ac.jp>
## 
## .shrc settings specific to bash
##
# if test -n "$_mshex_include_cdhist_sh"; then
#   _mshex_include_cdhist_sh=1
#HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH

# : ${MWGDIR="$HOME"/.mwg}
# . $HOME/.mwg/echox &>/dev/null||:

#------------------------------------------------------------------------------
# mshex/menu/.select

mshex/term/register-key smso smso $'\e[7m'
mshex/term/register-key rmso rmso $'\e[m'

source "${MWGDIR:-$HOME/.mwg}/share/mshex/shrc/menu.sh"

#------------------------------------------------------------------------------
# cd

if [[ ! $_mshex_cdhist_level ]]; then
  _mshex_cdhist=("$PWD")
  _mshex_cdhist_level=0
  _mshex_cdhist_count=1
fi

## 関数 mshex/cdhist/.indexof path
##   @param[in] path
##   @var[out] ret
function mshex/cdhist/.indexof {
  local i
  for ((i=0;i<${#_mshex_cdhist};i++)); do
    if [[ $1 == "${_mshex_cdhist[i]}" ]]; then
      ret=$i
      return
    fi
  done

  return 1
}
function mshex/cdhist/.remove {
  local -i i1=$1
  local -i i2=${2-$((i1+1))}
  ((i1<0)) && i1=0
  ((i2>_mshex_cdhist_count)) && i2=$_mshex_cdhist_count

  local -i i
  for ((i=0;i<i2-i1;i++));do
    _mshex_cdhist[i1+i]=${_mshex_cdhist[i2+i]}
  done

  ((_mshex_cdhist_count-=i2-i1))
  for ((i=${#_mshex_cdhist[*]}-1;i>=_mshex_cdhist_count;i--)); do
    unset "_mshex_cdhist[i]"
  done
}
function mshex/cdhist/.bubble {
  local i iN=$1
  local value=${_mshex_cdhist[iN]}
  for ((i=iN;i>0;i--)); do
    _mshex_cdhist[i]=${_mshex_cdhist[i-1]}
  done
  _mshex_cdhist[0]=$value
}
function mshex/cdhist/.push {
  if [[ $_mshex_cdhist_config_DiscardBranch ]]; then
    if ((_mshex_cdhist_level>0)); then
      mshex/cdhist/.remove 0 $_mshex_cdhist_level
    fi
  fi

  if [[ $_mshex_cdhist_config_BubbleHist && $_mshex_cdhist_level -ge 0 ]]; then
    mshex/cdhist/.bubble $_mshex_cdhist_level
  fi
  _mshex_cdhist_level=0

  local ret
  if mshex/cdhist/.indexof "$1"; then
    local index=$ret
  else
    local index=$_mshex_cdhist_count
    ((_mshex_cdhist_count++))
    _mshex_cdhist[index]=$1
  fi

  mshex/cdhist/.bubble "$index"
}
function mshex/cdhist/.list {
  echo "${_mshex_cdhist[@]//$HOME/~}"
}

function mshex/cdhist/.readkey/exch {
  local index="$1"
  ((0<index&&index<_mshex_cdhist_count)) || return 1

  _mshex_cdhist=(
    "${_mshex_cdhist[@]::index-1}"
    "${_mshex_cdhist[index]}"
    "${_mshex_cdhist[index-1]}"
    "${_mshex_cdhist[@]:index+1}")
  if((index==_mshex_cdhist_level)); then
    ((_mshex_cdhist_level--))
  elif((index==_mshex_cdhist_level)); then
    ((_mshex_cdhist_level++))
  fi

  mshex/menu/exch "$index"
}

function mshex/cdhist/.readkey {
  case "$key" in
  (delete)
    if ((_mshex_cdhist_count>1)); then
      _mshex_cdhist=("${_mshex_cdhist[@]::_mshex_menu_index}" "${_mshex_cdhist[@]:_mshex_menu_index+1}")
      ((_mshex_cdhist_count--))
      (((_mshex_cdhist_level>_mshex_menu_index)&&(_mshex_cdhist_level--)))
      mshex/menu/delete
      return 0
    fi ;;
  (,)
    if ((_mshex_menu_index>0)); then
      mshex/cdhist/.readkey/exch "$_mshex_menu_index"
      return 0
    fi ;;
  (.)
    if ((_mshex_menu_index+1<_mshex_cdhist_count)); then
      mshex/cdhist/.readkey/exch $((_mshex_menu_index+1))
      return 0
    fi ;;
  esac
  return 1
}

function mshex/cdhist/.on-change-level {
  local d=${_mshex_cdhist[_mshex_cdhist_level]}
  if [[ $d != "$PWD" ]]; then
    echo "[cd: $d]"
    builtin cd "$d"
  fi
}

function mshex/cdhist/select {
  local -i index
  local MWG_MENU_ONREADKEY=mshex/cdhist/.readkey
  local MWG_MENU_CANCEL=1
  mshex/menu -v index -i "$_mshex_cdhist_level" "${_mshex_cdhist[@]//$HOME/~}"

  if((index>=0)); then
    _mshex_cdhist_level=$index
    mshex/cdhist/.on-change-level
  fi
}
function mshex/cdhist/next {
  if ((_mshex_cdhist_level>0)); then
    ((_mshex_cdhist_level--))
    mshex/cdhist/.on-change-level
  fi
}
function mshex/cdhist/prev {
  if ((_mshex_cdhist_level<_mshex_cdhist_count-1)); then
    ((_mshex_cdhist_level++))
    mshex/cdhist/.on-change-level
  fi
}

function mshex/cdhist/cd {
  # read arguments
  local -a args=()
  local dst=
  local fForce=
  while (($#)); do
    case "$1" in
    (-f) fForce=1 ;;
    (-)
      dst=$OLDPWD
      mshex/array#push args "$1" ;;
    (-*)
      mshex/array#push args "$1" ;;
    (*)
      : ${dst:="$1"}
      mshex/array#push args "$1" ;;
    esac
    shift
  done

  if [[ $fForce ]]; then
    : ${dst:="$HOME"}
    [[ -e $dst ]] || mkdir -p "$dst"
  fi

  if [[ $dst != "$PWD" ]] && builtin cd "${args[@]}"; then
    mshex/cdhist/.push "$PWD" &>/dev/null
  fi
}

# alias cd=mshex/cdhist/cd
# - () { mshex/cdhist/prev; }
# + () { mshex/cdhist/next; }
# = () { mshex/cdhist/select; }
# bind -x '"\ec":mshex/cdhist/select'
# bind '"[D":"a"' && bind -x '"a":mshex/cdhist/prev'
# bind '"[C":"b"' && bind -x '"b":mshex/cdhist/next'

#HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
# fi
