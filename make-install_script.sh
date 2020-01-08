#!/usr/bin/env bash

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

case $1 in
(copy)
  make:copy "${@:2}" ;;
(initialize-source-highlight)
  make:initialize-source-highlight "${@:2}" ;;
esac
