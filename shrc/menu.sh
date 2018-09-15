# bash_source -*- mode: sh; mode: sh-bash -*-

# ChangeLog
#
# 2014-08-03
#   * mshex/menu/.printf, mshex/menu/.fflush を定義し入出力を改善
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

function mshex/menu/.init {
  mshex_menu_options=("$@")
  mshex_menu_count=${#mshex_menu_options[*]}

  mshex_menu_max_index=$((mshex_menu_count-1))
  mshex_menu_item_fmt="%0${#mshex_menu_max_index}d %s\n"
  mshex_menu_item_fmt1=$tm_smso${mshex_menu_item_fmt}$tm_rmso
}

if ((mwg_bash>=30100)); then
  function mshex/menu/.printf {
    local buff
    printf -v buff "$@"
    mshex_menu_stdout+=$buff
  }
  function mshex/menu/.fflush {
    printf %s "$mshex_menu_stdout"
    mshex_menu_stdout=
  }
else
  function mshex/menu/.printf {
    printf "$@"
  }
  function mshex/menu/.fflush { :; }
fi

function mshex/menu/.show {
  local mshex_menu_stdout i
  for ((i=0;i<mshex_menu_count;i++));do
    if ((i==mshex_menu_index)); then
      mshex/menu/.printf "$mshex_menu_item_fmt1" $i "${mshex_menu_options[i]}"
    else
      mshex/menu/.printf "$mshex_menu_item_fmt" $i "${mshex_menu_options[i]}"
    fi
  done
  mshex/menu/.printf "$tmf_cuu" $((mshex_menu_count-mshex_menu_index))
  mshex/menu/.fflush
}
function mshex/menu/.goto {
  local -i new_index=$1
  ((new_index==mshex_menu_index)) && return

  if ((new_index>=0&&new_index<mshex_menu_count)); then
    local mshex_menu_stdout
    mshex/menu/.printf "$mshex_menu_item_fmt" $mshex_menu_index "${mshex_menu_options[mshex_menu_index]}"

    local -i delta=$((mshex_menu_index-new_index+1))
    if ((delta>0)); then
      mshex/menu/.printf "$tmf_cuu" $delta
    elif ((delta<0)); then
      mshex/menu/.printf "$tmf_cud" $((-delta))
    fi

    mshex_menu_index=$new_index
    mshex/menu/.printf "$mshex_menu_item_fmt1" $mshex_menu_index "${mshex_menu_options[$mshex_menu_index]}"
    mshex/menu/.printf "$tmf_cuu" 1
    mshex/menu/.fflush
  else
    return 1
  fi
}

function mshex/menu/.up {
  if ((mshex_menu_index>0)); then
    local mshex_menu_stdout
    mshex/menu/.printf "$mshex_menu_item_fmt" $mshex_menu_index "${mshex_menu_options[$mshex_menu_index]}"
    mshex/menu/.printf "$tmf_cuu" 2
    let mshex_menu_index--
    mshex/menu/.printf "$mshex_menu_item_fmt1" $mshex_menu_index "${mshex_menu_options[$mshex_menu_index]}"
    mshex/menu/.printf "$tmf_cuu" 1
    mshex/menu/.fflush
  else
    return 1
  fi
}
function mshex/menu/.down {
  if ((mshex_menu_index<mshex_menu_count-1)); then
    local mshex_menu_stdout
    mshex/menu/.printf "$mshex_menu_item_fmt" $mshex_menu_index "${mshex_menu_options[$mshex_menu_index]}"
    let mshex_menu_index++
    mshex/menu/.printf "$mshex_menu_item_fmt1" $mshex_menu_index "${mshex_menu_options[$mshex_menu_index]}"
    mshex/menu/.printf "$tmf_cuu" 1
    mshex/menu/.fflush
  else
    return 1
  fi
}
function mshex/menu/.clear {
  ((mshex_menu_index>0)) && printf '\e[%dA' "$mshex_menu_index"
  ((mshex_menu_count>0)) && printf '\e[%dM' "$mshex_menu_count"
}

function mshex/menu/.stdout/redraw {
  local beg=${beg:-0} end=${end:-$mshex_menu_count}

  local i

  mshex/menu/.printf ""
  if ((beg<mshex_menu_index)); then
    mshex/menu/.printf "$tmf_cuu" $((mshex_menu_index-beg))
  elif ((beg>mshex_menu_index)); then
    mshex/menu/.printf "$tmf_cud" $((beg-mshex_menu_index))
  fi

  for ((i=beg;i<end;i++));do
    if ((i==mshex_menu_index)); then
      mshex/menu/.printf "$tm_el$mshex_menu_item_fmt1" $i "${mshex_menu_options[$i]}"
    else
      mshex/menu/.printf "$tm_el$mshex_menu_item_fmt" $i "${mshex_menu_options[$i]}"
    fi
  done

  if ((end<mshex_menu_index)); then
    mshex/menu/.printf "$tmf_cud" $((mshex_menu_index-end))
  elif ((end>mshex_menu_index)); then
    mshex/menu/.printf "$tmf_cuu" $((end-mshex_menu_index))
  fi
  mshex/menu/.fflush
}

function mshex/menu/.redraw {
  local mshex_menu_stdout
  mshex/menu/.stdout/redraw "$@"
  mshex/menu/.fflush
}
function mshex/menu/delete {
  mshex_menu_options=("${mshex_menu_options[@]::mshex_menu_index}" "${mshex_menu_options[@]:mshex_menu_index+1}")
  mshex_menu_count=${#mshex_menu_options[*]}
  (((mshex_menu_index>=mshex_menu_count)&&(mshex_menu_index--)))

  local mshex_menu_stdout
  mshex/menu/.printf "$tm_dl1"
  mshex/menu/.stdout/redraw "$mshex_menu_index"
  mshex/menu/.fflush
}

function mshex/menu/exch {
  local index="$1"
  ((0<index&&index<mwg_cdhist_count)) || return 1

  local mshex_menu_stdout

  mshex_menu_options=(
    "${mshex_menu_options[@]::index-1}"
    "${mshex_menu_options[index]}"
    "${mshex_menu_options[index-1]}"
    "${mshex_menu_options[@]:index+1}")
  if ((index==mshex_menu_index)); then
    let mshex_menu_index--
    mshex/menu/.printf "$tmf_cuu" 1
  elif ((index-1==mshex_menu_index)); then
    let mshex_menu_index++
    mshex/menu/.printf "$tmf_cud" 1
  fi

  mshex/menu/.stdout/redraw "$((index-1))" "$((index+1))"
  mshex/menu/.fflush
}

function mshex/menu/.impl {
  local -a mshex_menu_options
  local -i mshex_menu_index=${arg_default_index-0}
  local -i mshex_menu_count
  local -i mshex_menu_max_index
  local mshex_menu_item_fmt
  local mshex_menu_item_fmt1

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
  
  mshex/menu/.init "$@"
  mshex/menu/.show >&2
  
  if stty | grep '-echo\b' &>/dev/null; then
    mshex_menu_disabling_echo=
  else
    mshex_menu_disabling_echo=1
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
      mshex/menu/.up >&2;;
    (down|C-n|n)
      a_index=
      mshex/menu/.down >&2;;
    ([0-9])
      a_index="$a_index$key"
      if ((${#a_index}>=${#mshex_menu_max_index})); then
        mshex/menu/.goto ${a_index} >&2
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
      mshex/menu/.redraw ;;
    (*)
      if [[ $MWG_MENU_ONREADKEY ]] && $MWG_MENU_ONREADKEY; then
        continue
      else
        printf '\a' >&2
      fi ;;
    esac
  done
  
  mshex/menu/.clear >&2

  if [[ $mshex_menu_disabling_echo ]]; then
    stty echo
  fi

  if [[ $cancel_flag ]]; then
    _ret=-1
  else
    _ret=$mshex_menu_index
  fi
}
function mshex/menu {
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
  mshex/menu/.impl "$@"
  
  if [[ $_vname ]]; then
    eval "$_vname=\"\$_ret\""
  else
    echo "$_ret"
  fi
}

function mshex/menu/.select {
  local varname=$1
  shift
  local -a options=("$@")

  local index
  mshex/menu -v index "${options[@]}"
  printf -v "$varname" %s "${options[index]}"
}
