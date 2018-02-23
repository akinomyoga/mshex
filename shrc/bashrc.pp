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
[[ ! $MWGDIR && -d $HOME/.mwg ]] && MWGDIR="$HOME/.mwg"
: ${MWG_LOGINTERM:="$TERM"}

export MWGDIR MWG_LOGINTERM

if [[ $- == *i* ]]; then
#%%if mode=="bash" (
  declare -i mwg_bash=$((${BASH_VERSINFO[0]}*10000+${BASH_VERSINFO[1]}*100+${BASH_VERSINFO[2]}))
  export mwg_bash

  source "$MWGDIR"/share/mshex/shrc/bashrc_interactive

  function mwg/.settrap {
    # ble には元から同じ機能がある
    ((_ble_bash)) && return

    local tmp1 tmp2
    mwg.dict tmp1=mwg_term[fHR] tmp2=mwg_term[sgr0]
    trap "echo \"$tmp1[trap: exit \$?]$tmp2\"" ERR
  }

  mwg/.settrap

  [[ -s $MWGDIR/share/mshex/shrc/bash_tools ]] && source "$MWGDIR"/share/mshex/shrc/bash_tools
  alias cd=mwg_cdhist.cd
  mwg_bashrc.bind3 M-c    'c'    mwg_cdhist.select
  mwg_bashrc.bind3 M-up   '[D' mwg_cdhist.prev
  mwg_bashrc.bind3 M-down '[C' mwg_cdhist.next
  if [[ $TERM == rosaterm || $MWG_LOGINTERM == rosaterm ]]; then
    mwg_bashrc.bind3 'C-,' '[44;5^' mwg_cdhist.prev # C-,
    mwg_bashrc.bind3 'C-.' '[46;5^' mwg_cdhist.next # C-.
    mwg_bashrc.bind3 'C--' '[45;5^' mwg_cdhist.prev # C--
    mwg_bashrc.bind3 'C-+' '[43;5^' mwg_cdhist.next # C-+
  fi
  # - () { mwg_cdhist.prev; }
  # + () { mwg_cdhist.next; }
  # = () { mwg_cdhist.select; }
#%%elif mode=="zsh"
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
