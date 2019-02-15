# bash source -*- mode: sh; mode: sh-bash -*-

mshex_echox_prog="$0"
mshex_echox_indent=0
mshex_echox_indent_text=''
mshex_echox_indent_stk[0]=''

function echox {
  if test "x${1:0:2}" == x-e -o "x${1:0:2}" == x-n; then
    local opt="$1"
    shift
  else
    local opt=''
  fi
  echo $opt "[94m$mshex_echox_prog\$[m $mshex_echox_indent_text[34m$*[m"
}
function echoe {
  if test "x${1:0:2}" == x-e -o "x${1:0:2}" == x-n; then
    local opt="$1"
    shift
  else
    local opt=''
  fi
  echo $opt "[91m$mshex_echox_prog![m $mshex_echox_indent_text$*"
}
function echom {
  if test "x${1:0:2}" == x-e -o "x${1:0:2}" == x-n; then
    local opt="$1"
    shift
  else
    local opt=''
  fi
  echo $opt "[34m$mshex_echox_prog:[m $mshex_echox_indent_text$*"
}
function echor {
  local var="$1"
  local msg=$'\e[34m'"$mshex_echox_prog: $mshex_echox_indent_text"$'\e[32m'"$2"$'\e[m'
  local def="$3"
  test -n "$def" && msg="$msg"$' [\e[35m'"$def"$'\e[m]'
  read -e -i "$def" -p "$msg"$'\e[34m ? \e[m' "$var"
  if test -n "$def"; then
    eval ': ${'"$var"':=$def}'
  fi
}

function echox_push {
  local indent="$1"
  if test -z "$indent"; then
    indent='[90m- '
  fi

  mshex_echox_indent_stk[$mshex_echox_indent]=$mshex_echox_indent_text
  mshex_echox_indent=$((mshex_echox_indent+1))
  mshex_echox_indent_text="$mshex_echox_indent_text$indent"$'\e[m'
}

function echox_pop {
  if test "$mshex_echox_indent" -gt 0; then
    mshex_echox_indent=$((mshex_echox_indent-1))
    mshex_echox_indent_text=${mshex_echox_indent_stk[$mshex_echox_indent]}
  fi
}
