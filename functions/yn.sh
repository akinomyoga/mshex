#!/bin/bash

function mshex.yn {
  local prompt_yn='yes/no'
  local ret_default=
  case "$1" in
  (-y)
    ret_default=0
    prompt_yn='Yes/no'
    shift ;;
  (-n)
    ret_default=1
    prompt_yn='yes/No'
    shift ;;
  (*)
    echo 'msehx.yn: invalid usage!' >&2
    exit 1 ;;
  esac

  while read -ep "$* ($prompt_yn): " line; do
    case "x${line,,}" in
    (xyes)
      return 0 ;;
    (xno)
      return 1 ;;
    (x)
      if [[ $ret_default ]]; then
        if ((ret_default==0)); then
          echo "$* ($prompt_yn): yes"
        else
          echo "$* ($prompt_yn): no"
        fi
        return "$ret_default"
      fi ;;
    esac
  done

  return 1
}
