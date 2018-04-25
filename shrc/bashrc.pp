#%# template -*- mode:sh -*-
#%m 1 (
#%%if mode=="bash" (
#!/bin/bash
##
## $HOME/.mwg/bashrc
##
## copyright (c) 2010-2012 Koichi MURASE <murase@nt.phys.s.u-tokyo.ac.jp>, <myoga.murase@gmail.com>
##
## common .bashrc settings
##
#%%elif mode=="zsh"
#!/bin/zsh
##
## $HOME/.mwg/bashrc
##
## copyright (c) 2010-2012 Koichi MURASE <murase@nt.phys.s.u-tokyo.ac.jp>, <myoga.murase@gmail.com>
##
## common .zshrc settings
##
#%%)
#-------------------------------------------------------------------------------
#test -z "$LANG" && export LANG='ja_JP.UTF-8'
export LANG='ja_JP.UTF-8'
export TIME_STYLE='+%Y-%m-%d %H:%M:%S'
[[ $HOSTNAME ]] && export HOSTNAME # export されていない事がある

# mwg setting
[[ ! $MWGDIR && -d $HOME/.mwg ]] && MWGDIR=$HOME/.mwg
: ${MWG_LOGINTERM:="$TERM"}

export MWGDIR MWG_LOGINTERM

if [[ $- == *i* ]]; then
#%%if mode=="bash" (
  mwg_bash=$((${BASH_VERSINFO[0]}*10000+${BASH_VERSINFO[1]}*100+${BASH_VERSINFO[2]}))
  if ((mwg_bash>=30100)); then
    function mshex/array#push { eval "$1+=(\"\${@:2}\")"; }
  else
    function mshex/array#push {
      eval "shift; while ((\$#)); do
    $1[\${#$1[@]}]=\"\$1\"
    shift
  done"
    }
  fi

  source "$MWGDIR"/share/mshex/shrc/bashrc_interactive

  function mshex/.settrap {
    # ble には元から同じ機能がある
    ((_ble_bash)) && return

    local tmp1 tmp2
    mwg.dict tmp1=mwg_term[fHR] tmp2=mwg_term[sgr0]
    trap "echo \"$tmp1[trap: exit \$?]$tmp2\"" ERR
  }
  mshex/.settrap

  [[ -s $MWGDIR/share/mshex/shrc/bash_tools ]] && source "$MWGDIR"/share/mshex/shrc/bash_tools
  alias cd=mwg_cdhist.cd

  function mshex/bashrc/bind-keys {
    mshex/util/bind M-c    $'\ec'    mwg_cdhist.select
    mshex/util/bind M-up   $'\e\e[D' mwg_cdhist.prev
    mshex/util/bind M-down $'\e\e[C' mwg_cdhist.next
    if [[ $TERM == rosaterm || $MWG_LOGINTERM == rosaterm ]]; then
      mshex/util/bind 'C-,' $'\e[44;5^' mwg_cdhist.prev # C-,
      mshex/util/bind 'C-.' $'\e[46;5^' mwg_cdhist.next # C-.
      mshex/util/bind 'C--' $'\e[45;5^' mwg_cdhist.prev # C--
      mshex/util/bind 'C-+' $'\e[43;5^' mwg_cdhist.next # C-+
    fi
  }
  if ((_ble_bash)); then
    ble/array#push _ble_keymap_default_load_hook mshex/bashrc/bind-keys
  else
    mshex/bashrc/bind-keys
  fi

  # - () { mwg_cdhist.prev; }
  # + () { mwg_cdhist.next; }
  # = () { mwg_cdhist.select; }
#%%elif mode=="zsh"
  function mshex/array#push { eval "$1+=(\"\${@:2}\")"; }
  source $MWGDIR/share/mshex/shrc/zshrc_interactive
#%%)
fi
#-------------------------------------------------------------------------------
#%)
#%[mode="bash"]
#%$>../out/shrc/bashrc
#%x 1
#%[mode="zsh"]
#%$>../out/shrc/zshrc
#%x 1
