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
alias grep='grep --color=auto'
function rmgomi { rm -rf gomi; }

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

if type -t psforest &>/dev/null; then
  if [[ $(tput colors) -ge 256 ]]; then
    alias p='psforest'
  else
    alias p='psforest --color=never'
  fi
elif [[ $OSTYPE == linux-gnu ]]; then
  alias p='ps uaxf'
else
  alias p='ps uax'
fi

if type -t colored &>/dev/null; then
  if [[ $OSTYPE == freebsd* || $OSTYPE == darwin* || $OSTYPE == bsd* ]]; then
    alias ls='colored ls'
  else
    alias ls='colored ls --show-control-chars'
  fi
elif [[ $OSTYPE == cygwin || $OSTYPE == msys* ]]; then
  alias ls='ls --color=auto --show-control-chars'
elif [[ $OSTYPE == linux-gnu ]]; then
  alias ls='ls --color=auto'
elif [[ $OSTYPE == darwin* || $OSTYPE == freebsd*|| $OSTYPE == bsd* ]]; then
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

if ((mshex_bash>=40200)); then
  function mshex/alias:date { printf $'%(\e[94m%F (%a) %T %Z\e[m\n\e[32m%x %r\e[m\n%Y%m%d-%H%M%S)T\n\n' -1; cal; }
else
  function mshex/alias:date { date +$'\e[94m%F (%a) %T %Z\e[m\n%Y%m%d-%H%M%S'; echo; cal; }
fi
alias d=mshex/alias:date

if type source-highlight &>/dev/null; then
  function mshex/alias:view/less-highlight { source-highlight -o STDOUT -f esc256-light_background --style-file=my.style "$@" | less -SRFX; }
else
  function mshex/alias:view/less-highlight { less -SRFX; }
fi
function mshex/alias:view {
  if (($#==1)) && [[ ( $1 == *.o || $1 == *.obj || $1 == *.exe ) && -f $1 ]]; then
    #objdump -CDM intel "$1" | mshex/alias:view/less-highlight -s asm
    objdump -CDM intel "$1" | mshex/alias:view/less-highlight --lang-def=$HOME/.mwg/share/mshex/source-highlight/x86.lang
  fi
}
alias v=mshex/alias:view

function mshex/alias:make/nproc {
  ret=
  if [[ -e /proc/cpuinfo ]]; then
    # /proc/cpuinfo がある時はそれを読む
    local -a buffer
    if declare -f ble/util/mapfile &>/dev/null; then
      ble/util/mapfile buffer < /proc/cpuinfo
    elif type -t mapfile &>/dev/null; then
      mapfile buffer < /proc/cpuinfo
    else
      buffer=$(< /proc/cpuinfo)
      IFS=$'\n' eval 'buffer=($buffer)'
    fi
    local line count=0
    for line in "${buffer[@]}"; do
      [[ $line == 'processor'[$' \t']* ]] || continue
      ((count++))
    done
    ret=$count
  elif type -t nproc &>/dev/null; then
    # nproc がある時はそれを実行する
    if declare -f ble/util/assign &>/dev/null; then
      ble/util/assign ret nproc
    else
      ret=$(nproc)
    fi 
  else
    # 他の時は不明なので 1
    ret=1
  fi
}
function mshex/alias:make/sub:t {
  sed -n '/^\.PHONY:/ { s/\.PHONY:[[:space:]]*\|[[:space:]]$//g ; s/[[:space:]]\{1,\}/\n/g ; p }' "$1" | sort -u
}

function mshex/alias:make/update-makefile-pp {
  local name=$1
  if [[ $name -ot $name.pp ]]; then
    if type mwg_pp.awk &>/dev/null; then
      mwg_pp.awk "$name.pp" > "$name" || return
    else
      echo "$name.pp: mwg_pp.awk is not found" &>/dev/null
    fi
  fi
}
function mshex/alias:make {
  local fHere= arg regex
  for arg in "$@"; do
    regex='^(-C|-f)' && [[ $arg =~ $regex ]] && fHere=1
  done

  local make=make
  type gmake &>/dev/null && make=gmake
  local -a make_options=()
  local ret; mshex/alias:make/nproc; local nproc=$ret
  mshex/array#push make_options -j $((nproc*3/2))

  if [[ $fHere || -f Makefile || -f Makefile.pp || -f GNUmakefile || -f GNUmakefile.pp ]]; then
    mshex/alias:make/update-makefile-pp Makefile
    mshex/alias:make/update-makefile-pp GNUmakefile

    local makefile=
    if [[ -f GNUmakefile ]]; then
      makefile=GNUmakefile
    elif [[ -f Makefile ]]; then
      makefile=Makefile
    fi

    if [[ $makefile && $1 == ? ]] && declare -f mshex/alias:make/"sub:$1" >/dev/null; then
      mshex/alias:make/"sub:$1" "$makefile" "${@:2}"
    else
      "$make" "${make_options[@]}" "$@"
    fi
  else
    local dir=${PWD%/}
    while :; do
      local makefile=
      if [[ -f $dir/GNUmakefile ]]; then
        makefile=$dir/GNUmakefile
      elif [[ -f $dir/Makefile ]]; then
        makefile=$dir/Makefile
      fi

      if [[ $makefile ]]; then
        if [[ $1 == ? ]] && declare -f mshex/alias:make/"sub:$1" >/dev/null; then
          mshex/alias:make/"sub:$1" "$makefile" "${@:2}"
        else
          "$make" "${make_options[@]}" -C "${dir:-/}" "$@"
        fi
        return
      elif [[ $dir != */* ]]; then
        "$make" "${make_options[@]}" "$@"
        return
      else
        dir=${dir%/*}
      fi
    done
  fi
}
alias m=mshex/alias:make
function ble/cmdinfo/complete:m { ble/complete/progcomp make; }

function mshex/alias:history {
  if (($#)); then
    history "$@"
  else
    history 10 | awk '{printf("!%-3d !%s\n", NR - 11, $0);}'
  fi
}
alias h=mshex/alias:history

function mshex/alias:git/apply-commit-time-to-mtime {
  # modified version from http://stackoverflow.com/questions/2458042/restore-files-modification-time-in-git
  git log --pretty=%at --name-status |
    perl -ane '($x,$f)=@F;next if !$x;$t=$x,next if !defined($f);next if $s{$f};$s{$f}=utime($t,$t,$f),next if $x=~/[AM]/;'
}

function mshex/alias:git/check-commit-arguments {
  while (($#)); do
    local arg="$1"; shift
    local msg=
    case "$arg" in
    (-m)  msg="$1"; shift ;;
    (-m*) msg="${arg:2}"  ;;
    esac

    if [[ $msg == COMMIT || $msg != *' '* && -f $msg ]]; then
      #  誤って g commit -F file を g commit -m file とする事が頻発なのでチェックする。
      echo "mshex/alias:g: The commit message is too simple, and there is a file with that name. Did you mean \`-F $msg' (but not \`-m $msg')?" >&2
      return 1
    fi
  done

  return
}
function mshex/alias:git {
  if (($#==0)); then
    # printf '\e[1m$ git status\e[m\n'
    git -c color.status=always status || return 1
    printf '\n\e[1m$ git branch\e[m\n'
    git -c color.ui=always branch -vv
    printf '\n\e[1m$ git remote\e[m\n'
    git -c color.ui=always remote -v
    printf '\n\e[1m$ git log -n 5\e[m\n'
    mshex/alias:git t -n 5
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
      (
        cd "$(git rev-parse --show-toplevel)"
        local name=${PWD##*/}
        [[ -d dist ]] || mkdir -p dist
        local archive="dist/$name-$(date +%Y%m%d).tar.xz"
        git archive --format=tar --prefix="./$name/" HEAD | xz > "$archive"
      ) ;;

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

    (commit) mshex/alias:git/check-commit-arguments && git "$@" ;;

    (set-mtime)
      mshex/alias:git/apply-commit-time-to-mtime ;;

    (*) default=1 ;;
    esac

    [[ ! $default ]] || git "$@"
  fi
}
alias g=mshex/alias:git
function ble/cmdinfo/complete:g { ble/complete/progcomp git; }

function mshex/alias:yes {
  local opt_help= arg
  for arg in "$@"; do
    [[ $arg == --version || $arg == --help ]] || continue
    opt_help=1
    break
  done

  if [[ $opt_help || ! -t 1 ]]; then
    command yes "$@"
  else
    echo "yes: trying to output strings to terminal. canceled." >&2
    return 1
  fi
}
alias yes=mshex/alias:yes

function mshex/mkd {
  [[ -d "$1" ]] || mkdir -p "$1"
}
mshex_tmpdir="$MWGDIR/tmp"
mshex/mkd "$mshex_tmpdir"

# setup DISPLAY

function mshex/display {
  local fsshtty="$mshex_tmpdir/SSH_TTY"
  if [[ -s $fsshtty ]]; then
    export DISPLAY=$(< "$fsshtty")
  fi
}

function mshex/display/save {
  if [[ ! $STY && $SSH_TTY && $DISPLAY ]]; then
    if [[ $(tty) == "$SSH_TTY" ]]; then
      <<< "$DISPLAY" sed 's/^127\.0\.0\.1:/:/;s/^localhost:/:/' > "$mshex_tmpdir/SSH_TTY"
    fi
  fi
}

function mshex/display/.login {
  [[ ! $STY && $DISPLAY ]] && mshex/display/save
  [[ $STY && ! $DISPLAY ]] && mshex/display
}

mshex/display/.login

# old names
function mwg/display { mshex/display; }
function mwg/display/.save { mshex/display/save; }

#------------------------------------------------------------------------------
#%%if mode=="zsh" (
mshex_bind_fg () {
  echo -n $'\e['"${COLUMNS:-80}"'D\e[2K'
  setopt no_beep
  fg "$@" ; local r=$?
  setopt beep
  if ((r==18)); then
    # suspended
    #echo -n $'\e[3A\e[2M\e[1B'
  elif ((r==1)); then
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
declare -i _mshex_bindx_count=0
declare "${_mshex_dict_declare[@]//DICTNAME/mshex_bashrc_bindx_dict}"

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
      local id; mshex/dict "id=mshex_bashrc_bindx_dict[$cmd]"
      if [[ ! $id ]]; then
        ((_mshex_bindx_count++))
        if ((_mshex_bindx_count==10)); then
          ((_mshex_bindx_count++))
        fi
        id=$_mshex_bindx_count
        mshex/dict "mshex_bashrc_bindx_dict[$cmd]=$id"
      fi

      local hex seq2
      if ((mshex_bash>=40100)); then
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
  # mshex/util/bind M-l $'\el' l

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

function mshex/util/eval-after-load {
  local function_name=$1
  if ((_ble_bash)); then
    if ((_ble_version>=400)); then
      blehook/eval-after-load keymap "$function_name"
    else
      ble/array#push _ble_keymap_load_hook "$function_name"
    fi
  else
    "$function_name"
  fi
}
mshex/util/eval-after-load mshex/my-key-bindings

#%%)

#==============================================================================
#  shell/terminal settings - prompt

function ble/prompt/backslash:mshex/screen-pwd {
  if ble/is-function ble/contrib/prompt-git/initialize; then
    local "${_ble_contrib_prompt_git_vars[@]}"
    if ble/contrib/prompt-git/initialize; then
      ble/prompt/print '('
      ble/prompt/backslash:contrib/git-name
      ble/prompt/print ') '
    fi
  fi
  ble/prompt/backslash:W
  ble/prompt/print ' @ '
  ble/prompt/backslash:w
}

#%%m set_prompt
function mshex/set-prompt {
  # prompt
  if [[ $1 && $2 ]]; then
    local A='<A>'"$1"'<Z>';
    local Z='<A>'"$2"'<Z>';
  else
    local A=''
    local Z=''
  fi
  local _prompt='['"$A"'<user>@<host>'"$Z"' <jobs> <pwd>]<pchar> '

  # title_host
  if [[ ! $SSH_CLIENT ]]; then
    local title_host=''
  elif [[ $PROGRAMFILES ]]; then
    local title_host='<host>'
  else
    local title_host='<user>@<host>'
  fi

  local spec_pwd='<pwd> @ <pwp>'
  [[ $BLE_VERSION ]] && spec_pwd='\q{mshex/screen-pwd}'
  local label1='['$title_host'] <jobs> '$spec_pwd
  local label2='${SCREEN_WINDOW_TITLE}${SCREEN_WINDOW_TITLE:+ }['${title_host:+'<host>'}'] <jobs> '$spec_pwd

  if [[ $BLE_VERSION ]]; then
    bleopt prompt_xterm_title="$label1"
    bleopt prompt_screen_title="$label2"
    export PS1=$_prompt
  else
    # title
    case "$TERM" in
    (screen*)
#%%if mode=="zsh"
      local title=$'\e]0;'$label1$'\a\ek'$label2$'\e\\'
#%%else
      local title=$'\e]0;'$label1$'\a\ek'$label2$'\e\\\\'
#%%end
      ;;
    (*)
#%%if mode=="zsh"
      local title=$(mshex/term/set_title "$label1")
#%%else
      local title=$(mshex/term/set_title.escaped "$label1")
#%%end
      ;;
    esac

    export PS1='<A>'"$title"'<Z>'"$_prompt"
#%%if mode=="zsh"
    export RPS1='<pwp>';
#%%end
  fi
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
  [[ $A ]] || mshex/dict 'A=_mshex_term[fDG]'
  [[ $Z ]] || mshex/dict 'Z=_mshex_term[sgr0]'
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
shopt -u hostcomplete
shopt -s failglob
((_ble_bash)) ||
  shopt -s no_empty_cmd_completion

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
