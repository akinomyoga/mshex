#%# template -*- mode:sh -*-
#%m 1 (
#%%if mode=="zsh" (
#!/bin/zsh
##
## $HOME/.mwg/bashrc
##
## copyright (c) 2010-2016 Koichi MURASE <myoga.murase@gmail.com>
## 
## common .zshrc settings
##
#%%else
#!/bin/bash
##
## $HOME/.mwg/bashrc
##
## copyright (c) 2010-2016 Koichi MURASE <myoga.murase@gmail.com>
## 
## common .bashrc settings
##
#%%)
#==============================================================================
# Include

source "$MWGDIR/share/mshex/shrc/dict.sh"

# 141ms = (ファイル読み取り 62ms) + (mwg.dict 操作 47ms)
source "$MWGDIR/share/mshex/shrc/term.sh"

#==============================================================================
# aliases

alias emacs='emacs -nw'
alias c='cd -'
alias C='cd ../'
alias ..='cd ../'

alias scp='scp -p'
alias cp='cp -ia'
alias mv='mv -i'
alias rm='rm -i'
alias rmi='remove'
alias grep='grep --color=auto'
alias ls='ls --color=auto -G'

alias s='stty echo -nl'

#-------------------------------------------------------------------------------
# jobs

alias j='jobs'
alias f='fg'
alias F='fg %-'
alias 1='fg %1'
alias 2='fg %2'
alias 3='fg %3'
alias 4='fg %4'
alias 5='fg %5'
alias 6='fg %6'
alias 7='fg %7'
alias 8='fg %8'
alias 9='fg %9'
alias 10='fg %10'
alias 11='fg %11'
alias 12='fg %12'
alias 13='fg %13'
alias 14='fg %14'
alias 15='fg %15'
alias 16='fg %16'
alias 17='fg %17'
alias 18='fg %18'
alias 19='fg %19'
alias 20='fg %20'
alias 21='fg %21'
alias 22='fg %22'
alias 23='fg %23'
alias 24='fg %24'
alias 25='fg %25'
alias 26='fg %26'
alias 27='fg %27'
alias 28='fg %28'
alias 29='fg %29'

#-------------------------------------------------------------------------------
# alias functions

if ((mwg_bash>=40200)); then
  function d { printf $'%(\e[94m%F (%a) %T %Z\e[m \e[90m(%x %r)\e[m %Y%m%d-%H%M%S)T\n\n' -1; cal; }
else
  function d { date +$'\e[94m%F (%a) %T %Z\e[m\n%Y%m%d-%H%M%S'; echo; cal; }
fi


if type source-highlight &>/dev/null; then
  function v/less-highlight { source-highlight -o STDOUT -f esc256-light_background --style-file=my.style "$@" | less -SRFX; }
else
  function v/less-highlight { less -SRFX; }
fi

function v {
  if (($#==1)) && [[ ( $1 == *.o || $1 == *.obj || $1 == *.exe ) && -f $1 ]]; then
    #objdump -CDM intel "$1" | v/less-highlight -s asm
    objdump -CDM intel "$1" | v/less-highlight --lang-def=$HOME/.mwg/share/mshex/shrc/x86.lang
  fi
}

# alias m=make
function m/sub:t {
  sed -n '/^\.PHONY:/ { s/\.PHONY:[[:space:]]*\|[[:space:]]$//g ; s/[[:space:]]\{1,\}/\n/g ; p }' "$1" | sort -u
}
function m {
  local fHere= arg regex
  for arg in "$@"; do
    regex='^(-C|-f)' && [[ $arg =~ $regex ]] && fHere=1
  done

  if [[ $fHere || -f Makefile || -f Makefile.pp ]]; then
    if [[ Makefile -ot Makefile.pp ]]; then
      mwg_pp.awk Makefile.pp > Makefile || return
    fi

    if [[ -f Makefile && $1 == ? ]] && declare -f m/"sub:$1" >/dev/null ; then
      m/"sub:$1" Makefile "${@:2}"
    else
      make "$@"
    fi
  else
    local dir="${PWD%/}"
    while :; do
      if [[ -f $dir/Makefile ]]; then
        if [[ $1 == ? ]] && declare -f m/"sub:$1" >/dev/null; then
          m/"sub:$1" "$dir/Makefile" "${@:2}"
        else
          make -C "${dir:-/}" "$@"
        fi
        return
      elif [[ $dir != */* ]]; then
        make "$@"
        return
      else
        dir="${dir%/*}"
      fi
    done
  fi
}

# alias g=git

function g/check-commit-arguments {
  while (($#)); do
    local arg="$1"; shift
    local msg=
    case "$arg" in
    (-m)  msg="$1"; shift ;;
    (-m*) msg="${arg:2}"  ;;
    esac

    if [[ $msg == COMMIT || $msg != *' '* && -f $msg ]]; then
      #  誤って g commit -F file を g commit -m file とする事が頻発なのでチェックする。
      echo "mshex/g: The commit message is too simple, and there is a file with that name. Did you mean \`-F $msg' (but not \`-m $msg')?" >&2
      return 1
    fi
  done

  return
}
function g {
  if(($#==0)); then
    git -c color.status=always status | less -FSRX
  else
    local default=

    case "$1" in
    (u) git add -u ;;
    (l) ls -ld $(git ls-files "${@:2}") ;;

    # stepcounter
    # from ephemient's answer at http://stackoverflow.com/questions/4822471/count-number-of-lines-in-a-git-repository
    (c) git diff --stat 4b825dc642cb6eb9a060e54bf8d69288fbee4904 ;;

    (b)
      if (($#==1)); then
        git branch -vv
        git remote -v
      else
        git branch "${@:2}"
      fi ;;

    (dist)
      local name="${PWD##*/}"
      test -d dist || mkdir -p dist
      local archive="dist/$name-$(date +%Y%m%d).tar.xz"
      git archive --format=tar --prefix="./$name/" HEAD | xz > "$archive"
      ;;

    # diff
    (d*)
      # 正規表現は変数に入れて使わないと bash-4.0 と bash-3.0 で解釈が異なる
      local rex_diff='^d([0-9]*)$'
      if [[ $1 =~ $rex_diff ]]; then
        shift
        local index="${BASH_REMATCH[1]}"

        local -a diff_options=()
        if [[ $index ]]; then
          if ((index<=0)); then
            diff_options=(HEAD --cached)
          else
            diff_options=(HEAD~$((index)) HEAD~$((index-1)))
          fi
        fi

        if [[ -t 1 ]] && type nkf &>/dev/null; then
          git diff --minimal -M -C -b --color "${diff_options[@]}" "$@" | nkf -x | less -FSRX
        else
          git diff --minimal -M -C -b "${diff_options[@]}" "$@"
        fi
      else
        default=1
      fi ;;

    # show graphs
    # from http://stackoverflow.com/questions/1057564/pretty-git-branch-graphs
    ([tT])
      local esc="(\[[ -?]*[@-~])"
      if [[ $1 == t ]]; then
        local format='%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(reset)%s%C(reset) %C(ul)- %an%C(reset)%C(bold yellow)%d%C(reset)'
        local indent="([[:space:]*|\/]|$esc)* $esc*[[:alnum:]]+$esc* - $esc*\([^()]+\)$esc* "
        git log --graph --abbrev-commit --decorate --date=relative --format=format:"$format" --all --date-order |
          ifold -s -w "$COLUMNS" --indent="$indent"
      else
        local format='%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(reset)%s%C(reset) %C(ul)- %an%C(reset)'
        local indent="([[:space:]*|\/]|$esc)*"
        git log --graph --abbrev-commit --decorate --format=format:"$format" --all --date-order |
          ifold -s -w "$COLUMNS" --indent="$indent"
      fi ;;

    (commit) g/check-commit-arguments && git "$@" ;;

    (*) default=1 ;;
    esac

    [[ ! $default ]] || git "$@"
  fi
}

#------------------------------------------------------------------------------
#%%if mode=="zsh" (
bind_fg () {
  echo -n $'\e['"${COLUMNS:-80}"'D\e[2K'
  setopt no_beep
  fg "$@" ; local r="$?"
  setopt beep
  if test $r = 18; then
    # suspended
    #echo -n $'\e[3A\e[2M\e[1B'
  elif test $r = 1; then
    # no such job
    echo $'\e[2A\e[M\e[B' ; zle redisplay
  else
    echo ; zle redisplay
  fi
} ; zle -N bind_fg
bindkey 'z' bind_fg
bindkey '' bind_fg

bind_pushd () { pushd -0; } ; zle -N bind_pushd
bindkey 'c' bind_pushd

if test "$TERM" = rosaterm -o "$MWG_LOGINTERM" = rosaterm; then
  bindkey '[3~' delete-char
  bindkey '[2~' overwrite-mode
  bindkey '[1~' beginning-of-line
  bindkey '[4~' end-of-line

  bindkey '[1;5D' emacs-backward-word
  bindkey '[1;5C' emacs-forward-word
  bindkey '[D' backward-word
  bindkey '[C' forward-word
  bindkey '' backward-kill-word
  bindkey '[3;5~' kill-word
  # bindkey '' copy-backward-word
  # bindkey '[3~' copy-forward-word


  bind_jobs () { jobs; } ; zle -N bind_jobs ; bindkey '[6~' bind_jobs
  bind_fg0 () { bind_fg %-; } ; zle -N bind_fg0 ; bindkey '[48;5^' bind_fg0
  bind_fg1 () { bind_fg %1; } ; zle -N bind_fg1 ; bindkey '[49;5^' bind_fg1
  bind_fg2 () { bind_fg %2; } ; zle -N bind_fg2 ; bindkey '[50;5^' bind_fg2
  bind_fg3 () { bind_fg %3; } ; zle -N bind_fg3 ; bindkey '[51;5^' bind_fg3
  bind_fg4 () { bind_fg %4; } ; zle -N bind_fg4 ; bindkey '[52;5^' bind_fg4
  bind_fg5 () { bind_fg %5; } ; zle -N bind_fg5 ; bindkey '[53;5^' bind_fg5
  bind_fg6 () { bind_fg %6; } ; zle -N bind_fg6 ; bindkey '[54;5^' bind_fg6
  bind_fg7 () { bind_fg %7; } ; zle -N bind_fg7 ; bindkey '[55;5^' bind_fg7
  bind_fg8 () { bind_fg %8; } ; zle -N bind_fg8 ; bindkey '[56;5^' bind_fg8
  bind_fg9 () { bind_fg %9; } ; zle -N bind_fg9 ; bindkey '[57;5^' bind_fg9
fi
#%%elif mode=="bash"
declare -i mwg_bashrc_bindx_count=0
declare "${mwg_dict_declare[@]//DICTNAME/mwg_bashrc_bindx_dict}"

mwg_bashrc.bindx() {
  if test $# -ne 2; then
    echo "usage: mwg_bashrc.bindx keyseq command" 1>&2
    exit 1
  fi

  local seq="$1"
  local cmd="$2"
  local q='"'
  if test "${#seq}" -le 2; then
    bind -x "$q$seq$q:$cmd"
  else
    local id; mwg.dict "id=mwg_bashrc_bindx_dict[$cmd]"
    if test -z "$id"; then
      let mwg_bashrc_bindx_count++
      if test $mwg_bashrc_bindx_count -eq 10; then
        let mwg_bashrc_bindx_count++
      fi
      id=$mwg_bashrc_bindx_count
      mwg.dict "mwg_bashrc_bindx_dict[$cmd]=$id"
    fi

    local hex seq2
    if((mwg_bash>=40100)); then
      printf -v hex  '\\x%x' "$id"
      printf -v seq2 "$hex"
    else
      # cygwin だと fork が遅い
      hex='\x'$(printf '%x' $id)
      seq2="$(printf "$hex")"
    fi

    bind "$q$seq$q:$q$seq2$q"
    bind -x "$q$seq2$q:$cmd"
  fi
}

if ((_ble_bash)); then
  function mwg_bashrc.bind3 {
    ble-bind -cf "$1" "$3"
  }
else
  function mwg_bashrc.bind3 {
    mwg_bashrc.bindx "$2" "$3"
  }
fi

mwg_bashrc.bind3 M-z $'\ez' 'fg'
# mwg_bashrc.bind3 M-c $'\ec' 'pushd -0'
mwg_bashrc.bind3 M-l $'\el' l

if test "$TERM" = rosaterm -o "$MWG_LOGINTERM" = rosaterm; then
  if ! ((_ble_bash)); then
    bind '"\eL":downcase-word'

    bind '"[2~":overwrite-mode'             # Ins

    # move-word
    bind '"[1;5D":backward-word'            # C-Left
    bind '"[1;5C":forward-word'             # C-Right
    bind '"[D":shell-backward-word'       # M-Left
    bind '"[C":shell-forward-word'        # M-Right
    # kill-word
    bind '"":backward-kill-word'            # C-Backspace
    bind '"":unix-word-rubout'            # M-Backspace
    bind '"[27;2;8~":shell-backward-kill-word' # S-Backspace
    bind '"[3;5~":kill-word'                # C-Delete
    bind '"[3;5~":shell-kill-word'          # M-delete
    # copy-word
    bind '"":copy-backward-word'          # C-M-Backwspace
    bind '"[3;5~":copy-forward-word'      # C-M-Delete

    # region
    bind '"":kill-region'                   # C-w
    bind '"w":copy-region-as-kill'          # M-w

    bind '"[20~":undo'                      # F9
    bind '"[27;5;13~":shell-expand-line'    # C-RET
    bind '"":history-expand-line'         # M-RET
  fi

  mwg_bashrc.bind3 'next' '[6~' 'jobs'
  mwg_bashrc.bind3 'C-0' '[27;5;48~' 'fg %-'
  mwg_bashrc.bind3 'C-1' '[27;5;49~' 'fg %1'
  mwg_bashrc.bind3 'C-2' '[27;5;50~' 'fg %2'
  mwg_bashrc.bind3 'C-3' '[27;5;51~' 'fg %3'
  mwg_bashrc.bind3 'C-4' '[27;5;52~' 'fg %4'
  mwg_bashrc.bind3 'C-5' '[27;5;53~' 'fg %5'
  mwg_bashrc.bind3 'C-6' '[27;5;54~' 'fg %6'
  mwg_bashrc.bind3 'C-7' '[27;5;55~' 'fg %7'
  mwg_bashrc.bind3 'C-8' '[27;5;56~' 'fg %8'
  mwg_bashrc.bind3 'C-9' '[27;5;57~' 'fg %9'
  # mwg_bashrc.bind3 'M-RET' ''     'stty echo'

  # 古い rosaterm の設定 (redundant for ble-bind)
  if ! ((_ble_bash)); then
    bind '"[8;2^":shell-backward-kill-word'    # S-Backspace
    bind '"[13;5^":shell-expand-line'       # C-RET
    mwg_bashrc.bindx '[48;5^' 'fg %-'
    mwg_bashrc.bindx '[49;5^' 'fg %1'
    mwg_bashrc.bindx '[50;5^' 'fg %2'
    mwg_bashrc.bindx '[51;5^' 'fg %3'
    mwg_bashrc.bindx '[52;5^' 'fg %4'
    mwg_bashrc.bindx '[53;5^' 'fg %5'
    mwg_bashrc.bindx '[54;5^' 'fg %6'
    mwg_bashrc.bindx '[55;5^' 'fg %7'
    mwg_bashrc.bindx '[56;5^' 'fg %8'
    mwg_bashrc.bindx '[57;5^' 'fg %9'
  fi
fi
#%%)

#==============================================================================
#  shell/terminal settings - prompt

#%%m set_prompt (
mwg_bashrc.PS1.set() {
  # prompt
  if test -n "$1" -a -n "$2"; then
    local A='<A>'"$1"'<Z>';
    local Z='<A>'"$2"'<Z>';
  else
    local A=''
    local Z=''
  fi
  local _prompt='['"$A"'<user>@<host>'"$Z"' <jobs> <pwd>]<pchar> '

  # title_host
  if test -z "$SSH_CLIENT"; then
    local title_host=''
  elif test -n "$PROGRAMFILES"; then
    local title_host='<host>'
  else
    local title_host='<user>@<host>'
  fi

  # title
  case "$TERM" in
  screen*)
      local label1='['"$title_host"'] <jobs> <pwd> @ <pwp>'
      local screenWindowLabel='${SCREEN_WINDOW_TITLE}${SCREEN_WINDOW_TITLE:+ }['"${title_host:+<host>}"'] <jobs> <pwd> @ <pwp>'
      local title1=']0;'"$label1"''
#%%if mode=="zsh" (
      local screenWindowTitle='k'"$screenWindowLabel"'\'
#%%else
      local screenWindowTitle='k'"$screenWindowLabel"'\\'
#%%)
      local title="$title1$screenWindowTitle"
      ;;
  *)
      local label='['"$title_host"'] <jobs> <pwd> @ <pwp>'
#%%if mode=="zsh" (
      local title="$(mwg_term.set_title "$label")";
#%%else
      local title="$(mwg_term.set_title.escaped "$label")";
#%%)
      ;;
  esac

  export PS1='<A>'"$title"'<Z>'"$_prompt"
#%%if mode=="zsh" (
  export RPS1='<pwp>';
#%%)
}

mwg_bashrc.PS1.set

mwg_bashrc_set_prompt2 () {
  local A="$1"
  local Z="$2"
  test -n "$A" || mwg.dict 'A=mwg_term[fDG]'
  test -n "$Z" || mwg.dict 'Z=mwg_term[sgr0]'
  mwg_bashrc.PS1.set "$A" "$Z"
}
#%%)
#%%if mode=="zsh" (
#%%%m set_prompt set_prompt.r/<user>/%n/.r/<host>/%m/.r/<jobs>/%j/.r/<pwd>/%c/.r/<pwp>/%~/.r/<pchar>/%#/
#%%%x set_prompt.r/<A>/%{/.r/<Z>/%}/.r/\[\$\]/$/
#%%else
#%%%m set_prompt set_prompt.r/<user>/\u/.r/<host>/\h/.r/<jobs>/\j/.r/<pwd>/\W/.r/<pwp>/\w/.r/<pchar>/\$/
#%%%x set_prompt.r/<A>/\[/.r/<Z>/\]/.r/\[\$\]//
#%%)

function mwg.windowtitle {
  SCREEN_WINDOW_TITLE="$*"
}
#------------------------------------------------------------------------------
#  shell/terminal setting

# history
export HISTSIZE=100000
#%%if mode=="zsh" (

export HISTFILE=$HOME/.zshhistory
export SAVEHIST=100000
setopt HIST_IGNORE_DUPS
zshaddhistory() {
  local line=${1%%$'\n'}
  local cmd=${line%% *}
  [[ "${#line}" -ge 2 && "$cmd" != fg ]]
}

#%%elif mode=="bash"

export HISTFILESIZE=100000
export HISTIGNORE='?:fg:fg *'
export HISTCONTROL='ignoredups'
export LINES COLUMNS
shopt -s checkwinsize
shopt -s histappend
#shopt -s histverify
shopt -s histreedit
shopt -s no_empty_cmd_completion
shopt -u hostcomplete

#%%)

# 125ms
/bin/stty -ixon >/dev/null 2>&1
#==============================================================================
#  options for other tools
#------------------------------------------------------------------------------

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

#%)
#%[mode="bash"]
#%$>../out/shrc/bashrc_interactive
#%x 1
#%[mode="zsh"]
#%$>../out/shrc/zshrc_interactive
#%x 1
