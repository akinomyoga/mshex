#!/bin/bash

# hdirname filename [defaultValue]
#   そのファイルが実際に存在しているディレクトリを取得する。
#   ディレクトリ名自体はシンボリックリンクでも良い。
#
# 目標
#   * bash-3.0 で動く
#   * どの環境でも動く
#
# 参考
#
# http://kohkimakimoto.hatenablog.com/entry/2014/06/12/104110
#

# from mshex/functions/hdirname.sh

# readlink -f
function hdirname/readlink {
  local path="$1"
  case "$OSTYPE" in
  (cygwin|linux-gnu)
    # 少なくとも cygwin, GNU/Linux では readlink -f が使える
    PATH=/bin:/usr/bin readlink -f "$path" ;;
  (darwin*|*)
    # Mac OSX には readlink -f がない。
    local PWD="$PWD" OLDPWD="$OLDPWD"
    while [[ -h $path ]]; do
      local link="$(PATH=/bin:/usr/bin readlink "$path" || true)"
      [[ $link ]] || break

      if [[ $link = /* || $path != */* ]]; then
        # * $link ~ 絶対パス の時
        # * $link ~ 相対パス かつ ( $path が現在のディレクトリにある ) の時
        path="$link"
      else
        local dir="${path%/*}"
        path="${dir%/}/$link"
      fi
    done
    echo -n "$path" ;;
  esac
}

## @fn hdirname/impl file defaultValue
## @param[in] file
## @param[in] defaultValue
## @var[out] _ret
function hdirname {
  if [[ $1 == -v ]]; then
    # hdirname -v var file defaultValue
    eval '
      '$2'="$3"
      [[ -h ${'$2'} ]] && '$2'=$(hdirname/readlink "${'$2'}")

      if [[ ${'$2'} == */* ]]; then
        '$2'="${'$2'%/*}"
        : "${'$2':=/}"
      else
        '$2'="${4-$PWD}"
      fi
    '
  elif [[ $1 == -v* ]]; then
    hdirname -v "${1:2}" "${@:2}"
  else
    local ret
    hdirname -v ret "$@"
    echo -n "$ret"
  fi
}

