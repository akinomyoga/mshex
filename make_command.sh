#!/usr/bin/env bash

MWGDIR=$HOME/.mwg
function is-function { declare -f "$1" &>/dev/null; }
function mkd { [[ -d $1 ]] || mkdir -p "$1"; }

#------------------------------------------------------------------------------
# copy

function make:copy {
  local flag_script=
  while [[ $1 == -* ]]; do
    local arg=$1; shift
    case $arg in
    (-s) flag_script=1 ;;
    esac
  done

  local src=$1 dst=$2
  local sedrules=
  local ascii_nl=$'\n'
  local ascii_bs='\'

  # Rewrite rules for shebang
  if [[ $flag_script ]]; then
    if [[ ! -x /bin/bash ]]; then
      # Android など /bin/... が異なる場所にある環境がある

      local bash_path=$BASH
      if [[ ! -x $bash_path ]]; then
        bash_path=$(type -p bash 2>/dev/null)
        if [[ ! -x $bash_path ]]; then
          bash_path=$(which bash 2>/dev/null)
          if [[ ! -x $bash_path ]]; then
            bash_path=
          fi
        fi
      fi
      
      if [[ $bash_path ]]; then
        sedrules=$sedrules'1{s:/bin/bash:'${bash_path//:/$ascii_bs:}':;}'$ascii_nl
      fi
    fi
  fi

  [[ -h $dst ]] && rm -f "$dst"
  if [[ $sedrules ]]; then
    sed '1{s:/bin/bash:'"${bash_path//:/\\:}"':;}' "$src" > "$dst"

    # ToDo: touch -r reference file に対応していない場合もある
    touch -r "$src" "$dst" 2>/dev/null

    chmod 755 "$dst"
  else
    cp -p "$src" "$dst"
  fi
}

#------------------------------------------------------------------------------
# initialize-source-highlight

function make:initialize-source-highlight {
  local target_dir=$1
  local source_dir=/usr/share/source-highlight
  [[ -d $source_dir ]] || source_dir=/usr/local/share/source-highlight
  [[ -d $source_dir ]] || return

  [[ -e $target_dir ]] && rm -rf "$target_dir"
  mkdir "$target_dir"

  # create links
  ln -s "$source_dir" "$target_dir"/base
  local -a files=()
  for file in "$target_dir"/base/*; do
    files[${#files[@]}]=${file#$target_dir/}
  done
  ln -s "${files[@]}" "$target_dir"/

  # outlang.map
  rm -f "$target_dir"/outlang.map
  cp "$target_dir"/base/outlang.map "$target_dir"/outlang.map
  echo 'esc256-light_background = esc256-light_background.outlang' >> "$target_dir"/outlang.map
}

#------------------------------------------------------------------------------
# update

function make:update/mv {
  if [[ -f $1 ]]; then
    if [[ ! -e $2 ]]; then
      echo mv "$1" "$2"
      mv "$1" "$2"
    else
      echo rm -f "$1"
      rm -f "$1"
    fi
  elif [[ -d $1 ]]; then
    if [[ ! -e $2 ]]; then
      echo mv "$1" "$2"
      mv "$1" "$2"
    else
      echo rm -rf "$1"
      rm -rf "$1"
    fi
  fi
}
function make:update/rm {
  if [[ -f $1 ]]; then
    echo rm -f "$1"
    rm -f "$1"
  elif [[ -d $1 ]]; then
    echo rm -rf "$1"
    rm -rf "$1"
  fi
}

function make:update {
  # 2012-07-26
  if [[ -d $MWGDIR/bashrc.d ]]; then
    rm -rf "$MWGDIR/bashrc.d"
  fi

  #------------------------------------
  # 2012-10-03

  local sdir=$MWGDIR/share/mshex
  mkd "$sdir"

  local dir1=$MWGDIR/shrc.d
  if [[ -d $dir1 ]]; then
    make:update/mv "$dir1/bashrc" "$sdir/bashrc.cache"
    make:update/mv "$dir1/zshrc" "$sdir/zshrc.cache"
    make:update/mv "$dir1/tools/menu.bash_source" "$sdir/shrc/menu.bash_source"
    make:update/rm "$dir1"
  fi

  mkd "$sdir/shrc"
  make:update/mv "$MWGDIR/cdhist.sh" "$sdir/shrc/cdhist.sh"
  make:update/mv "$MWGDIR/bashrc_interactive" "$sdir/shrc/bashrc_interactive"
  make:update/mv "$MWGDIR/zshrc_interactive" "$sdir/shrc/zshrc_interactive"

  #------------------------------------
  # 2015-02-08

  make:update/rm "$sdir/shrc/menu.bash_source"

  #------------------------------------
  # 2018-06-28

  make:update/mv "$MWGDIR/bashrc_common.sh" "$sdir/shrc/bashrc_common.sh"
  make:update/mv "$sdir/shrc/bashrc_interactive" "$sdir/shrc/bashrc_interactive.sh"
  make:update/mv "$sdir/shrc/zshrc_interactive" "$sdir/shrc/zshrc_interactive.sh"
}

#------------------------------------------------------------------------------

if is-function "make:$1"; then
  "make:$1" "${@:2}"
elif (($#==0)); then
  echo "usage: ./make_command.sh SUBCOMMAND ..." >&2
  exit 2
else
  echo "make_command.sh: unrecognized subcommand '$1'" >&2
  exit 2
fi
