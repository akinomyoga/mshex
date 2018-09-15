# bash_source -*- mode: sh; mode: sh-bash -*-

# ChangeLog
#
# 2014-08-03
#   * mwg_menu/printf, mwg_menu/fflush を定義し入出力を改善
#   * 速度向上の為、source して起動する形式から関数を呼び出す形式に変更
#

#------------------------------------------------------------------------------
# Include

# source "$MWGDIR/share/mshex/shrc/dict.sh"
# source "$MWGDIR/share/mshex/shrc/term.sh"
#------------------------------------------------------------------------------

((__mwg_mshex_menu__PragmaOnce>=1)) && return
__mwg_mshex_menu__PragmaOnce=1

mwg_term.register_key dl1 dl1 $'\e[M'
mwg_term.register_key el  el  $'\e[K'

function mwg_menu.init {
  mwg_menu_options=("$@")
  mwg_menu_count=${#mwg_menu_options[*]}

  mwg_menu_max_index=$((mwg_menu_count-1))
  mwg_menu_item_fmt="%0${#mwg_menu_max_index}d %s\n"
  mwg_menu_item_fmt1=$tm_smso${mwg_menu_item_fmt}$tm_rmso
}

if ((mwg_bash>=30100)); then
  function mwg_menu/printf {
    local buff
    printf -v buff "$@"
    mwg_menu_stdout+=$buff
  }
  function mwg_menu/fflush {
    printf %s "$mwg_menu_stdout"
    mwg_menu_stdout=
  }
else
  function mwg_menu/printf {
    printf "$@"
  }
  function mwg_menu/fflush { :; }
fi

function mwg_menu.show {
  local mwg_menu_stdout i
  for ((i=0;i<mwg_menu_count;i++));do
    if ((i==mwg_menu_index)); then
      mwg_menu/printf "$mwg_menu_item_fmt1" $i "${mwg_menu_options[i]}"
    else
      mwg_menu/printf "$mwg_menu_item_fmt" $i "${mwg_menu_options[i]}"
    fi
  done
  mwg_menu/printf "$tmf_cuu" $((mwg_menu_count-mwg_menu_index))
  mwg_menu/fflush
}
function mwg_menu.goto {
  local -i new_index=$1
  ((new_index==mwg_menu_index)) && return

  if ((new_index>=0&&new_index<mwg_menu_count)); then
    local mwg_menu_stdout
    mwg_menu/printf "$mwg_menu_item_fmt" $mwg_menu_index "${mwg_menu_options[mwg_menu_index]}"

    local -i delta=$((mwg_menu_index-new_index+1))
    if ((delta>0)); then
      mwg_menu/printf "$tmf_cuu" $delta
    elif ((delta<0)); then
      mwg_menu/printf "$tmf_cud" $((-delta))
    fi

    mwg_menu_index=$new_index
    mwg_menu/printf "$mwg_menu_item_fmt1" $mwg_menu_index "${mwg_menu_options[$mwg_menu_index]}"
    mwg_menu/printf "$tmf_cuu" 1
    mwg_menu/fflush
  else
    return 1
  fi
}

function mwg_menu.up {
  if ((mwg_menu_index>0)); then
    local mwg_menu_stdout
    mwg_menu/printf "$mwg_menu_item_fmt" $mwg_menu_index "${mwg_menu_options[$mwg_menu_index]}"
    mwg_menu/printf "$tmf_cuu" 2
    let mwg_menu_index--
    mwg_menu/printf "$mwg_menu_item_fmt1" $mwg_menu_index "${mwg_menu_options[$mwg_menu_index]}"
    mwg_menu/printf "$tmf_cuu" 1
    mwg_menu/fflush
  else
    return 1
  fi
}
function mwg_menu.down {
  if ((mwg_menu_index<mwg_menu_count-1)); then
    local mwg_menu_stdout
    mwg_menu/printf "$mwg_menu_item_fmt" $mwg_menu_index "${mwg_menu_options[$mwg_menu_index]}"
    let mwg_menu_index++
    mwg_menu/printf "$mwg_menu_item_fmt1" $mwg_menu_index "${mwg_menu_options[$mwg_menu_index]}"
    mwg_menu/printf "$tmf_cuu" 1
    mwg_menu/fflush
  else
    return 1
  fi
}
function mwg_menu.clear {
  ((mwg_menu_index>0)) && printf '\e[%dA' "$mwg_menu_index"
  ((mwg_menu_count>0)) && printf '\e[%dM' "$mwg_menu_count"
}

function mwg_menu/stdout/redraw {
  local beg=${beg:-0} end=${end:-$mwg_menu_count}

  local i

  mwg_menu/printf ""
  if ((beg<mwg_menu_index)); then
    mwg_menu/printf "$tmf_cuu" $((mwg_menu_index-beg))
  elif ((beg>mwg_menu_index)); then
    mwg_menu/printf "$tmf_cud" $((beg-mwg_menu_index))
  fi

  for ((i=beg;i<end;i++));do
    if ((i==mwg_menu_index)); then
      mwg_menu/printf "$tm_el$mwg_menu_item_fmt1" $i "${mwg_menu_options[$i]}"
    else
      mwg_menu/printf "$tm_el$mwg_menu_item_fmt" $i "${mwg_menu_options[$i]}"
    fi
  done

  if ((end<mwg_menu_index)); then
    mwg_menu/printf "$tmf_cud" $((mwg_menu_index-end))
  elif ((end>mwg_menu_index)); then
    mwg_menu/printf "$tmf_cuu" $((end-mwg_menu_index))
  fi
  mwg_menu/fflush
}

function mwg_menu/redraw {
  local mwg_menu_stdout
  mwg_menu/stdout/redraw "$@"
  mwg_menu/fflush
}
function mwg_menu/delete {
  mwg_menu_options=("${mwg_menu_options[@]::mwg_menu_index}" "${mwg_menu_options[@]:mwg_menu_index+1}")
  mwg_menu_count=${#mwg_menu_options[*]}
  (((mwg_menu_index>=mwg_menu_count)&&(mwg_menu_index--)))

  local mwg_menu_stdout
  mwg_menu/printf "$tm_dl1"
  mwg_menu/stdout/redraw "$mwg_menu_index"
  mwg_menu/fflush
}

function mwg_menu/exch {
  local index="$1"
  ((0<index&&index<mwg_cdhist_count)) || return 1

  local mwg_menu_stdout

  mwg_menu_options=(
    "${mwg_menu_options[@]::index-1}"
    "${mwg_menu_options[index]}"
    "${mwg_menu_options[index-1]}"
    "${mwg_menu_options[@]:index+1}")
  if ((index==mwg_menu_index)); then
    let mwg_menu_index--
    mwg_menu/printf "$tmf_cuu" 1
  elif ((index-1==mwg_menu_index)); then
    let mwg_menu_index++
    mwg_menu/printf "$tmf_cud" 1
  fi

  mwg_menu/stdout/redraw "$((index-1))" "$((index+1))"
  mwg_menu/fflush
}

function mwg_menu/impl {
  local -a mwg_menu_options
  local -i mwg_menu_index=${arg_default_index-0}
  local -i mwg_menu_count
  local -i mwg_menu_max_index
  local mwg_menu_item_fmt
  local mwg_menu_item_fmt1

  if test $# -eq 0; then
    echo -1
    return 1
  fi

  local tm_smso tm_rmso tmf_cuu tmf_cud tm_dl1 tm_el
  mshex/dict \
    'tm_smso=mwg_term[smso]' \
    'tm_rmso=mwg_term[rmso]' \
    'tmf_cuu=mwg_term[f:cuu]' \
    'tmf_cud=mwg_term[f:cud]' \
    'tm_dl1=mwg_term[dl1]' \
    'tm_el=mwg_term[el]'
  
  mwg_menu.init "$@"
  mwg_menu.show >&2
  
  if stty | grep '-echo\b' &>/dev/null; then
    mwg_menu_disabling_echo=
  else
    mwg_menu_disabling_echo=1
    trap 'stty echo' INT
    trap 'stty echo' TERM
    trap 'stty echo' KILL
    stty -echo
  fi

  local a_index=
  shopt -s extglob
  while :; do
    mwg_term.readkey key
    case "$key" in
    (up|C-p|p)
      a_index=
      mwg_menu.up >&2;;
    (down|C-n|n)
      a_index=
      mwg_menu.down >&2;;
    ([0-9])
      a_index="$a_index$key"
      if ((${#a_index}>=${#mwg_menu_max_index})); then
        mwg_menu.goto ${a_index} >&2
        a_index=
      fi
      ;;
    (RET|C-j|m|eof)
      break;;
    (q|C-g)
      if [[ $MWG_MENU_CANCEL ]]; then
        local cancel_flag=1
        break
      else
        echo -n $'\a' >&2
      fi ;;
    (C-l)
      mwg_menu/redraw ;;
    (*)
      if [[ $MWG_MENU_ONREADKEY ]] && $MWG_MENU_ONREADKEY; then
        continue
      else
        printf '\a' >&2
      fi ;;
    esac
  done
  
  mwg_menu.clear >&2

  if [[ $mwg_menu_disabling_echo ]]; then
    stty echo
  fi

  if [[ $cancel_flag ]]; then
    _ret=-1
  else
    _ret=$mwg_menu_index
  fi
}
function mwg_menu {
  local _vname=
  local arg_default_index
  while [[ $1 == -* ]]; do
    case "$1" in
    (-i)
      # echo "debug: arg_defualt_index=$2" >&2
      arg_default_index=$2
      shift 2 ;;
    (-v)
      _vname=$2
      shift 2 ;;
    -) break;;
    esac
  done
  
  local _ret
  mwg_menu/impl "$@"
  
  if [[ $_vname ]]; then
    eval "$_vname=\"\$_ret\""
  else
    echo "$_ret"
  fi
}

function mwg_menu.select {
  local varname=$1
  shift
  local -a options=("$@")

  local index
  mwg_menu -v index "${options[@]}"
  printf -v "$varname" %s "${options[index]}"
}
