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

((_mshex_menu_PragmaOnce>=1)) && return
_mshex_menu_PragmaOnce=1

mshex/term/register-key dl1 dl1 $'\e[M'
mshex/term/register-key el  el  $'\e[K'

function mshex/menu/.init {
  _mshex_menu_options=("$@")
  _mshex_menu_count=${#_mshex_menu_options[*]}

  _mshex_menu_max_index=$((_mshex_menu_count-1))
  _mshex_menu_item_fmt="%0${#_mshex_menu_max_index}d %s\n"
  _mshex_menu_item_fmt1=$tm_smso${_mshex_menu_item_fmt}$tm_rmso
}

if ((mwg_bash>=30100)); then
  function mshex/menu/.printf {
    local buff
    printf -v buff "$@"
    _mshex_menu_stdout+=$buff
  }
  function mshex/menu/.fflush {
    printf %s "$_mshex_menu_stdout"
    _mshex_menu_stdout=
  }
else
  function mshex/menu/.printf {
    printf "$@"
  }
  function mshex/menu/.fflush { :; }
fi

function mshex/menu/.show {
  local _mshex_menu_stdout i
  for ((i=0;i<_mshex_menu_count;i++));do
    if ((i==_mshex_menu_index)); then
      mshex/menu/.printf "$_mshex_menu_item_fmt1" $i "${_mshex_menu_options[i]}"
    else
      mshex/menu/.printf "$_mshex_menu_item_fmt" $i "${_mshex_menu_options[i]}"
    fi
  done
  mshex/menu/.printf "$tmf_cuu" $((_mshex_menu_count-_mshex_menu_index))
  mshex/menu/.fflush
}
function mshex/menu/.goto {
  local -i new_index=$1
  ((new_index==_mshex_menu_index)) && return

  if ((new_index>=0&&new_index<_mshex_menu_count)); then
    local _mshex_menu_stdout
    mshex/menu/.printf "$_mshex_menu_item_fmt" $_mshex_menu_index "${_mshex_menu_options[_mshex_menu_index]}"

    local -i delta=$((_mshex_menu_index-new_index+1))
    if ((delta>0)); then
      mshex/menu/.printf "$tmf_cuu" $delta
    elif ((delta<0)); then
      mshex/menu/.printf "$tmf_cud" $((-delta))
    fi

    _mshex_menu_index=$new_index
    mshex/menu/.printf "$_mshex_menu_item_fmt1" $_mshex_menu_index "${_mshex_menu_options[$_mshex_menu_index]}"
    mshex/menu/.printf "$tmf_cuu" 1
    mshex/menu/.fflush
  else
    return 1
  fi
}

function mshex/menu/.up {
  if ((_mshex_menu_index>0)); then
    local _mshex_menu_stdout
    mshex/menu/.printf "$_mshex_menu_item_fmt" $_mshex_menu_index "${_mshex_menu_options[$_mshex_menu_index]}"
    mshex/menu/.printf "$tmf_cuu" 2
    ((_mshex_menu_index--))
    mshex/menu/.printf "$_mshex_menu_item_fmt1" $_mshex_menu_index "${_mshex_menu_options[$_mshex_menu_index]}"
    mshex/menu/.printf "$tmf_cuu" 1
    mshex/menu/.fflush
  else
    return 1
  fi
}
function mshex/menu/.down {
  if ((_mshex_menu_index<_mshex_menu_count-1)); then
    local _mshex_menu_stdout
    mshex/menu/.printf "$_mshex_menu_item_fmt" $_mshex_menu_index "${_mshex_menu_options[$_mshex_menu_index]}"
    ((_mshex_menu_index++))
    mshex/menu/.printf "$_mshex_menu_item_fmt1" $_mshex_menu_index "${_mshex_menu_options[$_mshex_menu_index]}"
    mshex/menu/.printf "$tmf_cuu" 1
    mshex/menu/.fflush
  else
    return 1
  fi
}
function mshex/menu/.clear {
  ((_mshex_menu_index>0)) && printf '\e[%dA' "$_mshex_menu_index"
  ((_mshex_menu_count>0)) && printf '\e[%dM' "$_mshex_menu_count"
}

function mshex/menu/.stdout/redraw {
  local beg=${beg:-0} end=${end:-$_mshex_menu_count}

  local i

  mshex/menu/.printf ""
  if ((beg<_mshex_menu_index)); then
    mshex/menu/.printf "$tmf_cuu" $((_mshex_menu_index-beg))
  elif ((beg>_mshex_menu_index)); then
    mshex/menu/.printf "$tmf_cud" $((beg-_mshex_menu_index))
  fi

  for ((i=beg;i<end;i++));do
    if ((i==_mshex_menu_index)); then
      mshex/menu/.printf "$tm_el$_mshex_menu_item_fmt1" $i "${_mshex_menu_options[$i]}"
    else
      mshex/menu/.printf "$tm_el$_mshex_menu_item_fmt" $i "${_mshex_menu_options[$i]}"
    fi
  done

  if ((end<_mshex_menu_index)); then
    mshex/menu/.printf "$tmf_cud" $((_mshex_menu_index-end))
  elif ((end>_mshex_menu_index)); then
    mshex/menu/.printf "$tmf_cuu" $((end-_mshex_menu_index))
  fi
  mshex/menu/.fflush
}

function mshex/menu/.redraw {
  local _mshex_menu_stdout
  mshex/menu/.stdout/redraw "$@"
  mshex/menu/.fflush
}
function mshex/menu/delete {
  _mshex_menu_options=("${_mshex_menu_options[@]::_mshex_menu_index}" "${_mshex_menu_options[@]:_mshex_menu_index+1}")
  _mshex_menu_count=${#_mshex_menu_options[*]}
  (((_mshex_menu_index>=_mshex_menu_count)&&(_mshex_menu_index--)))

  local _mshex_menu_stdout
  mshex/menu/.printf "$tm_dl1"
  mshex/menu/.stdout/redraw "$_mshex_menu_index"
  mshex/menu/.fflush
}

function mshex/menu/exch {
  local index="$1"
  ((0<index&&index<_mshex_cdhist_count)) || return 1

  local _mshex_menu_stdout

  _mshex_menu_options=(
    "${_mshex_menu_options[@]::index-1}"
    "${_mshex_menu_options[index]}"
    "${_mshex_menu_options[index-1]}"
    "${_mshex_menu_options[@]:index+1}")
  if ((index==_mshex_menu_index)); then
    ((_mshex_menu_index--))
    mshex/menu/.printf "$tmf_cuu" 1
  elif ((index-1==_mshex_menu_index)); then
    ((_mshex_menu_index++))
    mshex/menu/.printf "$tmf_cud" 1
  fi

  mshex/menu/.stdout/redraw "$((index-1))" "$((index+1))"
  mshex/menu/.fflush
}

function mshex/menu/.impl {
  local -a _mshex_menu_options
  local -i _mshex_menu_index=${arg_default_index-0}
  local -i _mshex_menu_count
  local -i _mshex_menu_max_index
  local _mshex_menu_item_fmt
  local _mshex_menu_item_fmt1

  if (($#==0)); then
    echo -1
    return 1
  fi

  local tm_smso tm_rmso tmf_cuu tmf_cud tm_dl1 tm_el
  mshex/dict \
    'tm_smso=_mshex_term[smso]' \
    'tm_rmso=_mshex_term[rmso]' \
    'tmf_cuu=_mshex_term[f:cuu]' \
    'tmf_cud=_mshex_term[f:cud]' \
    'tm_dl1=_mshex_term[dl1]' \
    'tm_el=_mshex_term[el]'
  
  mshex/menu/.init "$@"
  mshex/menu/.show >&2
  
  if stty | grep '-echo\b' &>/dev/null; then
    _mshex_menu_disabling_echo=
  else
    _mshex_menu_disabling_echo=1
    trap 'stty echo' INT
    trap 'stty echo' TERM
    trap 'stty echo' KILL
    stty -echo
  fi

  local a_index=
  shopt -s extglob
  while :; do
    mshex/term/readkey key
    case "$key" in
    (up|C-p|p)
      a_index=
      mshex/menu/.up >&2;;
    (down|C-n|n)
      a_index=
      mshex/menu/.down >&2;;
    ([0-9])
      a_index="$a_index$key"
      if ((${#a_index}>=${#_mshex_menu_max_index})); then
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

  if [[ $_mshex_menu_disabling_echo ]]; then
    stty echo
  fi

  if [[ $cancel_flag ]]; then
    _ret=-1
  else
    _ret=$_mshex_menu_index
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
