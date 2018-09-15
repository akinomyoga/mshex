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

# 141ms = (ファイル読み取り 62ms) + (mshex/dict 操作 47ms)
source "$MWGDIR/share/mshex/shrc/term.sh"

#==============================================================================
# Fedora / CentOS

if [[ -e /etc/redhat-release ]]; then
  # Fedora 及び CentOS の変な設定を削除する。

  # 存在しないコマンドに当たった時に、勝手にインターネットに接続して検索しに行く。
  # スクリプトファイルを読み込んだ時に、PATH を間違えていたり存在しないコマンドを
  # 大量に使っていたりすると大変な事になる。C-c を連打しても止められない。
  # <a href="http://luna2-linux.blogspot.jp/2011/03/fedora-14.html">ALL about Linux: Fedora 14 でコマンドを打ち間違えると・・・</a>
  unset -f command_not_found_handle

  # 勝手に screen のタイトルに変なものを設定しようとする。
  if [[ $PROMPT_COMMAND == ble/* ]]; then
    _ble_base_attach_PROMPT_COMMAND=
  else
    PROMPT_COMMAND=
  fi

  # alias ll='ls -l --color=auto'
  unalias ll &>/dev/null
fi

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

if [[ $OSTYPE == cygwin ]] && type -t cygpath &>/dev/null; then
  alias o=cygstart
elif type -t xdg-open &>/dev/null; then
  alias o=xdg-open
elif type -t open &>/dev/null; then
  alias o=open
fi

if [[ $OSTYPE == linux-gnu ]]; then
    alias p='ps uaxf'
elif type -t psforest &>/dev/null; then
  if [[ $(tput colors) -ge 256 ]]; then
    alias p='psforest'
  else
    alias p='psforest --color=never'
  fi
else
  alias p='ps uax'
fi

if type -t colored &>/dev/null; then
  alias ls='colored ls --show-control-chars'
elif [[ $OSTYPE == cygwin || $OSTYPE == msys* ]]; then
  alias ls='ls --color=auto --show-control-chars'
elif [[ $OSTYPE == linux-gnu ]]; then
  alias ls='ls --color=auto'
elif [[ $OSTYPE == darwin* || $OSTYPE == freebsd* ]]; then
  alias ls='ls -G'
fi

if type -t colored &>/dev/null; then
  alias diff='colored -F diff'
fi

type -P l  &>/dev/null || alias l='ls -lB'
type -P ll &>/dev/null || alias ll='ls -l'
type -P la &>/dev/null || alias la='ls -la'

#-------------------------------------------------------------------------------
# functions

if ((mwg_bash>=40200)); then
  function d { printf $'%(\e[94m%F (%a) %T %Z\e[m\n\e[32m%x %r\e[m\n%Y%m%d-%H%M%S)T\n\n' -1; cal; }
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
    objdump -CDM intel "$1" | v/less-highlight --lang-def=$HOME/.mwg/share/mshex/source-highlight/x86.lang
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

function h {
  if (($#)); then
    history "$@"
  else
    history 10 | awk '{printf("!%-3d !%s\n", NR - 11, $0);}'
  fi
}

# alias g=git

function g/apply-commit-time-to-mtime {
  # modified version from http://stackoverflow.com/questions/2458042/restore-files-modification-time-in-git
  git log --pretty=%at --name-status |
    perl -ane '($x,$f)=@F;next if !$x;$t=$x,next if !defined($f);next if $s{$f};$s{$f}=utime($t,$t,$f),next if $x=~/[AM]/;'
}

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
  if (($#==0)); then
    ( # printf '\e[1m$ git status\e[m\n'
      git -c color.status=always status || exit
      printf '\n\e[1m$ git branch\e[m\n'
      git -c color.ui=always branch -vv
      printf '\n\e[1m$ git remote\e[m\n'
      git -c color.ui=always remote -v
      printf '\n\e[1m$ git log -n 5\e[m\n'
      g t -n 5
    ) | less -FSRX
  else
    local default=

    case "$1" in
    (u) git add -u ;;
    (l) ls -ld $(git ls-files "${@:2}") ;;

    (p) git add -p "${@:2}" ;;
    (amend)  git commit --amend --no-edit "${@:2}" ;;
    (reword) git commit --amend "${@:2}" ;;

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
        elif local rex='^[0-9a-f]+$'; [[ $# -eq 1 && $1 =~ $rex ]]; then
          diff_options=("$1~" "$1")
          shift
        fi

        local diff_filter=''
        if [[ -t 1 ]]; then
          if type nkf &>/dev/null; then
            local ctype=${LC_CTYPE:-$LANG} rex
            if rex='.(UTF-?8|utf-?8)$'; [[ $ctype =~ $rex ]]; then
              diff_filter="$diff_filter | nkf -xw"
            elif rex='.(euc(JP|jp)?|ujis)$'; [[ $ctype =~ $rex ]]; then
              diff_filter="$diff_filter | nkf -xe"
            else
              diff_filter="$diff_filter | nkf -x"
            fi
          fi

          if type colored &>/dev/null; then
            mshex/array#push diff_options --color=never
            diff_filter="$diff_filter | colored -tdiff"
          else
            mshex/array#push diff_options --color=always

          fi

          if [[ $diff_filter ]]; then
            diff_filter="$diff_filter | less -FSRX"
          fi
        fi
        eval 'git diff --minimal -M -C -b "${diff_options[@]}" "$@"'"$diff_filter"
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
        git log --graph --abbrev-commit --decorate --date=relative --format=format:"$format" --all --date-order --color=always "${@:2}" |
          ifold -s -w "$COLUMNS" --indent="$indent"
      else
        local format='%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(reset)%s%C(reset) %C(ul)- %an%C(reset)'
        local indent="([[:space:]*|\/]|$esc)*"
        git log --graph --abbrev-commit --decorate --format=format:"$format" --all --date-order --color=always "${@:2}" |
          ifold -s -w "$COLUMNS" --indent="$indent"
      fi ;;

    (commit) g/check-commit-arguments && git "$@" ;;

    (set-mtime)
      g/apply-commit-time-to-mtime ;;

    (*) default=1 ;;
    esac

    [[ ! $default ]] || git "$@"
  fi
}

function mwg/mkd {
  [[ -d "$1" ]] || mkdir -p "$1"
}
mwg_tmp="$MWGDIR/tmp"
mwg/mkd "$mwg_tmp"

# setup DISPLAY

function mwg/display {
  local fsshtty="$mwg_tmp/SSH_TTY"
  if [[ -s $fsshtty ]]; then
    export DISPLAY=$(< "$fsshtty")
  fi
}

function mwg/display/.save {
  if [[ ! $STY && $SSH_TTY && $DISPLAY ]]; then
    if [[ $(tty) == "$SSH_TTY" ]]; then
      <<< "$DISPLAY" sed 's/^127\.0\.0\.1:/:/;s/^localhost:/:/' > "$mwg_tmp/SSH_TTY"
    fi
  fi
}

function mwg/display/.login {
  [[ ! $STY && $DISPLAY ]] && mwg/display/.save
  [[ $STY && ! $DISPLAY ]] && mwg/display
}

mwg/display/.login

#------------------------------------------------------------------------------
#%%if mode=="zsh" (
mshex_bind_fg () {
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
} ; zle -N mshex_bind_fg
bindkey 'z' mshex_bind_fg
bindkey '' mshex_bind_fg

mshex_bind_pushd () { pushd -0; } ; zle -N mshex_bind_pushd
bindkey 'c' mshex_bind_pushd

if [[ $TERM == rosaterm || $MWG_LOGINTERM == rosaterm ]]; then
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


  mshex_bind_jobs () { jobs; } ; zle -N mshex_bind_jobs ; bindkey '[6~' mshex_bind_jobs
  mshex_bind_fg0 () { mshex_bind_fg %-; } ; zle -N mshex_bind_fg0 ; bindkey '[48;5^' mshex_bind_fg0
  mshex_bind_fg1 () { mshex_bind_fg %1; } ; zle -N mshex_bind_fg1 ; bindkey '[49;5^' mshex_bind_fg1
  mshex_bind_fg2 () { mshex_bind_fg %2; } ; zle -N mshex_bind_fg2 ; bindkey '[50;5^' mshex_bind_fg2
  mshex_bind_fg3 () { mshex_bind_fg %3; } ; zle -N mshex_bind_fg3 ; bindkey '[51;5^' mshex_bind_fg3
  mshex_bind_fg4 () { mshex_bind_fg %4; } ; zle -N mshex_bind_fg4 ; bindkey '[52;5^' mshex_bind_fg4
  mshex_bind_fg5 () { mshex_bind_fg %5; } ; zle -N mshex_bind_fg5 ; bindkey '[53;5^' mshex_bind_fg5
  mshex_bind_fg6 () { mshex_bind_fg %6; } ; zle -N mshex_bind_fg6 ; bindkey '[54;5^' mshex_bind_fg6
  mshex_bind_fg7 () { mshex_bind_fg %7; } ; zle -N mshex_bind_fg7 ; bindkey '[55;5^' mshex_bind_fg7
  mshex_bind_fg8 () { mshex_bind_fg %8; } ; zle -N mshex_bind_fg8 ; bindkey '[56;5^' mshex_bind_fg8
  mshex_bind_fg9 () { mshex_bind_fg %9; } ; zle -N mshex_bind_fg9 ; bindkey '[57;5^' mshex_bind_fg9
fi
#%%elif mode=="bash"
declare -i mwg_bashrc_bindx_count=0
declare "${_mshex_dict_declare[@]//DICTNAME/mwg_bashrc_bindx_dict}"

if ((_ble_bash)); then
  function mshex/util/bind {
    ble-bind -cf "$1" "$3"
  }
else
  function mshex/util/bind {
    if (($#!=3)); then
      echo "usage: mshex/bindx keyseq command" 1>&2
      exit 1
    fi

    local seq=$2
    local cmd=$3
    local q='"'
    if ((${#seq}<=2)); then
      if [[ $seq == ['"\'] ]]; then
        bind -x "$q\\$seq$q:$cmd"
      else
        bind -x "$q$seq$q:$cmd"
      fi
    else
      local id; mshex/dict "id=mwg_bashrc_bindx_dict[$cmd]"
      if [[ ! $id ]]; then
        let mwg_bashrc_bindx_count++
        if test $mwg_bashrc_bindx_count -eq 10; then
          let mwg_bashrc_bindx_count++
        fi
        id=$mwg_bashrc_bindx_count
        mshex/dict "mwg_bashrc_bindx_dict[$cmd]=$id"
      fi

      local hex seq2
      if ((mwg_bash>=40100)); then
        printf -v hex  '\\x%x' "$id"
        printf -v seq2 "\\x1E$hex"
      else
        # cygwin だと fork が遅い
        hex='\x'$(printf '%x' $id)
        seq2=$'\x1E'$(printf "$hex")
      fi

      bind "$q$seq$q:$q$seq2$q"
      bind -x "$q$seq2$q:$cmd"
    fi
  }
fi

function mshex/my-key-bindings {
  mshex/util/bind M-z $'\ez' 'fg'
  # mshex/util/bind M-c $'\ec' 'pushd -0'
  mshex/util/bind M-l $'\el' l

  if ((_ble_bash)); then
    if [[ -o emacs ]]; then
      ble-bind -f f9  emacs/undo 2>/dev/null
      ble-bind -f f10 emacs/redo 2>/dev/null
    fi
  fi

  if [[ $TERM == rosaterm || $MWG_LOGINTERM == rosaterm ]]; then
    if ((_ble_bash)); then
      ble-bind -f C-_ delete-backward-cword
    else
      bind $'"\eL":downcase-word'

      bind $'"\e[2~":overwrite-mode'             # Ins

      # move-word
      bind $'"\e[1;5D":backward-word'            # C-Left
      bind $'"\e[1;5C":forward-word'             # C-Right
      bind $'"\e\e[D":shell-backward-word'       # M-Left
      bind $'"\e\e[C":shell-forward-word'        # M-Right
      # kill-word
      bind $'"\x1F":backward-kill-word'          # C-Backspace (^_)
      bind $'"\e\x7F":unix-word-rubout'          # M-Backspace (^?)
      bind $'"\e[27;2;8~":shell-backward-kill-word' # S-Backspace
      bind $'"\e[3;5~":kill-word'                # C-Delete
      bind $'"\e[3;5~":shell-kill-word'          # M-delete
      # copy-word
      bind $'"\e\x1F":copy-backward-word'        # C-M-Backwspace (^[^_)
      bind $'"\e\e[3;5~":copy-forward-word'      # C-M-Delete

      # region
      bind $'"\x17":kill-region'                 # C-w (^W)
      bind $'"\ew":copy-region-as-kill'          # M-w

      bind $'"\e[20~":undo'                      # F9
      bind $'"\e[27;5;13~":shell-expand-line'    # C-RET
      bind $'"\e\r":history-expand-line'         # M-RET (^[^M)
    fi

    mshex/util/bind 'next' $'\e[6~' 'jobs'
    mshex/util/bind 'C-0'  $'\e[27;5;48~' 'fg %-'
    mshex/util/bind 'C-1'  $'\e[27;5;49~' 'fg %1'
    mshex/util/bind 'C-2'  $'\e[27;5;50~' 'fg %2'
    mshex/util/bind 'C-3'  $'\e[27;5;51~' 'fg %3'
    mshex/util/bind 'C-4'  $'\e[27;5;52~' 'fg %4'
    mshex/util/bind 'C-5'  $'\e[27;5;53~' 'fg %5'
    mshex/util/bind 'C-6'  $'\e[27;5;54~' 'fg %6'
    mshex/util/bind 'C-7'  $'\e[27;5;55~' 'fg %7'
    mshex/util/bind 'C-8'  $'\e[27;5;56~' 'fg %8'
    mshex/util/bind 'C-9'  $'\e[27;5;57~' 'fg %9'
    # mshex/util/bind 'M-RET' $'\e\r'     'stty echo'

    # 古い rosaterm の設定 (redundant for ble-bind)
    if ! ((_ble_bash)); then
      bind $'"\e[8;2^":shell-backward-kill-word'    # S-Backspace
      bind $'"\e[13;5^":shell-expand-line'       # C-RET
      mshex/util/bind nil $'\e[48;5^' 'fg %-'
      mshex/util/bind nil $'\e[49;5^' 'fg %1'
      mshex/util/bind nil $'\e[50;5^' 'fg %2'
      mshex/util/bind nil $'\e[51;5^' 'fg %3'
      mshex/util/bind nil $'\e[52;5^' 'fg %4'
      mshex/util/bind nil $'\e[53;5^' 'fg %5'
      mshex/util/bind nil $'\e[54;5^' 'fg %6'
      mshex/util/bind nil $'\e[55;5^' 'fg %7'
      mshex/util/bind nil $'\e[56;5^' 'fg %8'
      mshex/util/bind nil $'\e[57;5^' 'fg %9'
    fi
  fi
}

if ((_ble_bash)); then
  ble/array#push _ble_keymap_default_load_hook mshex/my-key-bindings
else
  mshex/my-key-bindings
fi

#%%)

#==============================================================================
#  shell/terminal settings - prompt

#%%m set_prompt
function mshex/set-prompt {
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
#%%if mode=="zsh"
      local screenWindowTitle='k'"$screenWindowLabel"'\'
#%%else
      local screenWindowTitle='k'"$screenWindowLabel"'\\'
#%%end
      local title="$title1$screenWindowTitle"
      ;;
  *)
      local label='['"$title_host"'] <jobs> <pwd> @ <pwp>'
#%%if mode=="zsh"
      local title="$(mshex/term/set_title "$label")";
#%%else
      local title="$(mshex/term/set_title.escaped "$label")";
#%%end
      ;;
  esac

  export PS1='<A>'"$title"'<Z>'"$_prompt"
#%%if mode=="zsh"
  export RPS1='<pwp>';
#%%end
}
#%%end
#%%if mode=="zsh"
#%%%m set_prompt set_prompt.r/<user>/%n/.r/<host>/%m/.r/<jobs>/%j/.r/<pwd>/%c/.r/<pwp>/%~/.r/<pchar>/%#/
#%%%x set_prompt.r/<A>/%{/.r/<Z>/%}/.r/\[\$\]/$/
#%%else
#%%%m set_prompt set_prompt.r/<user>/\u/.r/<host>/\h/.r/<jobs>/\j/.r/<pwd>/\W/.r/<pwp>/\w/.r/<pchar>/\$/
#%%%x set_prompt.r/<A>/\[/.r/<Z>/\]/.r/\[\$\]//
#%%end

mshex/set-prompt

function mshex/set-window-title {
  SCREEN_WINDOW_TITLE="$*"
}

# old functions
function mwg_bashrc.PS1.set { mshex/set-prompt "$@"; }
function mwg_bashrc_set_prompt2 {
  local A=$1
  local Z=$2
  test -n "$A" || mshex/dict 'A=_mshex_term[fDG]'
  test -n "$Z" || mshex/dict 'Z=_mshex_term[sgr0]'
  mwg_bashrc.PS1.set "$A" "$Z"
}
function mwg.windowtitle { mshex/set-window-title "$@"; }

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
[[ -d $MWGDIR/share/mshex/source-highlight ]] &&
  export SOURCE_HIGHLIGHT_DATADIR=$MWGDIR/share/mshex/source-highlight

#%)
#%[mode="bash"]
#%$>../out/shrc/bashrc_interactive.sh
#%x 1
#%[mode="zsh"]
#%$>../out/shrc/zshrc_interactive.sh
#%x 1
