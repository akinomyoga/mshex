#%# template -*- mode:sh -*-
#%m 1 (
#%%if mode=="bash" (
#!/bin/bash
##
## $HOME/.mwg/bashrc
##
## Copyright (c) 2010-2012 Koichi MURASE <murase@nt.phys.s.u-tokyo.ac.jp>, <myoga.murase@gmail.com>
##
## .bashrc settings
##
#%%elif mode=="zsh"
#!/bin/zsh
##
## $HOME/.mwg/bashrc
##
## copyright (c) 2010-2012 Koichi MURASE <murase@nt.phys.s.u-tokyo.ac.jp>, <myoga.murase@gmail.com>
##
## .zshrc settings
##
#%%)
#-------------------------------------------------------------------------------
#
# Common settings
#
#-------------------------------------------------------------------------------

#[[ ! $LANG ]] && export LANG='ja_JP.UTF-8'
if [[ $TERM == linux ]]; then
  export LANG='C.UTF-8'
else
  export LANG='ja_JP.UTF-8'
fi
export TIME_STYLE='+%Y-%m-%d %H:%M:%S'
[[ $HOSTNAME ]] && export HOSTNAME # export されていない事がある

# mwg setting
[[ ! $MWGDIR && -d $HOME/.mwg ]] && MWGDIR=$HOME/.mwg
: ${MWG_LOGINTERM:="$TERM"}

export MWGDIR MWG_LOGINTERM

if [[ $- == *i* ]]; then
#%%if mode=="bash" (
  mshex_bash=$((${BASH_VERSINFO[0]}*10000+${BASH_VERSINFO[1]}*100+${BASH_VERSINFO[2]}))
  if ((mshex_bash>=30100)); then
    function mshex/array#push { eval "$1+=(\"\${@:2}\")"; }
  else
    function mshex/array#push {
      eval "shift; while ((\$#)); do
    $1[\${#$1[@]}]=\"\$1\"
    shift
  done"
    }
  fi

  source "$MWGDIR"/share/mshex/shrc/bashrc_interactive.sh

  function mshex/.settrap {
    # ble には元から同じ機能がある
    ((_ble_bash)) && return

    local tmp1 tmp2
    mshex/dict 'tmp1=_mshex_term[fHR]' 'tmp2=_mshex_term[sgr0]'
    trap "echo \"$tmp1[trap: exit \$?]$tmp2\"" ERR
  }
  mshex/.settrap

  [[ -s $MWGDIR/share/mshex/shrc/cdhist.sh ]] && source "$MWGDIR"/share/mshex/shrc/cdhist.sh
  alias cd=mshex/cdhist/cd

  function mshex/bashrc/bind-keys {
    mshex/util/bind next   $'\e[6~'  mshex/cdhist/select
    #mshex/util/bind M-c    $'\ec'    mshex/cdhist/select
    mshex/util/bind M-up   $'\e\e[D' mshex/cdhist/prev
    mshex/util/bind M-down $'\e\e[C' mshex/cdhist/next
    if [[ $TERM == rosaterm || $MWG_LOGINTERM == rosaterm ]]; then
      mshex/util/bind 'C-,' $'\e[44;5^' mshex/cdhist/prev # C-,
      mshex/util/bind 'C-.' $'\e[46;5^' mshex/cdhist/next # C-.
      mshex/util/bind 'C--' $'\e[45;5^' mshex/cdhist/prev # C--
      mshex/util/bind 'C-+' $'\e[43;5^' mshex/cdhist/next # C-+
    fi
  }
  mshex/util/eval-after-load mshex/bashrc/bind-keys

  # - () { mshex/cdhist/prev; }
  # + () { mshex/cdhist/next; }
  # = () { mshex/cdhist/select; }
#%%elif mode=="zsh"
  function mshex/array#push { eval "$1+=(\"\${@:2}\")"; }
  source $MWGDIR/share/mshex/shrc/zshrc_interactive.sh
#%%)
fi

#%)
#%[mode="bash"]
#%$>../out/shrc/bashrc_common.sh
#%x 1
#%[mode="zsh"]
#%$>../out/shrc/zshrc_common.sh
#%x 1
