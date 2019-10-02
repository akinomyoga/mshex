#!/bin/bash
# -*- mode: sh-bash -*-
# Title        colored less
# OriginalName mshex/shrc/less.sh
# Created      2017-06-06, KM <myoga.murase@gmail.com>
#
# Synopsis
#
#   mshex/less
#
# ToDo
#
#   * c++ standard header files (without extensions)
#
# ChangeLog
#
# 2018-01-11 KM
#   * padparadscha:~/.bashrc から移動
#

[[ ${_mshex_shrc_less_sh+set} ]] && return
_mshex_shrc_less_sh=1

[[ $- == *i* ]] || return

function mshex/less/initialize {
  local -i colors=$(tput colors)
  if ((colors>=256)); then
    function mshex/less/source-highlight {
      source-highlight -o STDOUT -f esc256-light_background --style-file=my.style "$@"
    }
    # export LESS='-R'
    # export LESSOPEN='| source-highlight -f esc256 -i %s -o STDOUT'
  elif ((colors>=8)); then
    function mshex/less/source-highlight {
      source-highlight -o STDOUT -f esc "$@"
    }
    # export LESS='-R'
    # export LESSOPEN='| source-highlight -f esc -i %s -o STDOUT'
  fi
}
mshex/less/initialize

function advice:nocasematch-off {
  local opt_nocasematch=
  if shopt -q nocasematch &>/dev/null; then
    opt_nocasematch=1
    shopt -u nocasematch
  fi

  "$@"; local ret=$?

  [[ $opt_nocasematch ]] && shopt -s nocasematch

  return "$ret"
}

function mshex/less.impl {
  local -a files=()
  local -a options=()
  local fREST=
  while (($#)); do
    local arg="$1"
    shift
    case "$arg" in
    (--) fREST=1
         continue ;;
    (-)  mshex/array#push files "$arg"
         continue ;;
    (--*)
      if [[ ! $fREST ]]; then
        local rex='^--(buffers|color|max-back-scroll|jump-target|lesskey-file|log-file|LOG-FILE|pattern|prompt|tag|tag-file|tabs|max-forw-scroll|window|quotes|shift)(=.*)?$'
        if [[ $arg =~ $rex ]]; then
          if [[ ! ${BASH_REMATCH[2]} ]]; then
            arg="$arg=$1"
            shift
          fi
        fi
        mshex/array#push options "$arg"
        continue
      fi ;;
    (+*) mshex/array#push options "$arg"
         continue ;;
    (-*)
      if [[ ! $fREST ]]; then
        local i=1 c rex='^[bDhjkoOpPtTxyz"#]$'
        local opref=-; [[ $arg == -+* ]] && opref=-+ i=2
        for ((;i<${#arg};i++)); do
          c="${arg:i:1}"
          if [[ $c =~ $rex ]]; then
            if ((i+1<${#arg})); then
              # -z123 など
              options[${#options[@]}]="$opref$c${arg:i+1}"
            else
              # -z 123 など
              mshex/array#push options "$opref$c" "$1"
              shift
            fi
            break
          elif [[ $c == [0-9] ]]; then
            # -123 など
            mshex/array#push options "$opref${arg:i}"
            break
          else
            mshex/array#push options "$opref$c"
          fi
        done
        continue
      fi ;;
    esac

    mshex/array#push files "$arg"
  done

  local -a hiliteopts=()

  # 初めの引数にファイルの種類 (拡張子) を指定している場合
  local fFileTypeSet=
  if [[ ${files[0]} == .* && ! -f ${files[0]} ]]; then
    fFileTypeSet=1
    mshex/array#push hiliteopts -s "${files[0]#.}"
    files=("${files[@]:1}")
  fi

  if ((${#files[@]}==0)) || [[ ${files[0]} == - ]]; then
    command less "${options[@]}"
  elif [[ -d ${files[0]} ]]; then
    if type l &>/dev/null; then
      l "${files[@]}" | command less -r "${options[@]}"
    else
      command less "${options[@]}" "${files[@]}"
    fi
  elif type -t source-highlight &>/dev/null; then
    if [[ ! $fFileTypeSet && ${files[0]##*/} == .bashrc ]]; then
      fFileTypeSet=1
      mshex/array#push hiliteopts -s sh
    fi

    if ((${#files[@]}==1)); then
      mshex/array#push hiliteopts -i "${files[0]}"
      { mshex/less/source-highlight "${hiliteopts[@]}" || cat "${files[@]}"; } | command less -r "${options[@]}"
    else
      [[ $fFileTypeSet ]] || mshex/array#push hiliteopts -s "${files[0]%%*.}"
      cat -- "${files[@]}" | { mshex/less/source-highlight "${hiliteopts[@]}" || cat -- "${files[@]}"; } | command less -r "${options[@]}"
    fi
  else
    command less "${options[@]}" "${files[@]}"
  fi
}

function mshex/less {
  advice:nocasematch-off mshex/less.impl "$@"
}

alias less=mshex/less
