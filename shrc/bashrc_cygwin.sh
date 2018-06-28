# bashrc for cygwin -*- mode: sh; mode: sh-bash -*-

# Paths & Envs
#export CYGWIN='server error_start=dumper'
export CYGWIN='server'
: ${DISPLAY:=:0.0}
export DISPLAY
export EXEEXT='.exe'

#------------------------------------------------------------------------------
# interactive
if [[ $- == *i* ]]; then
  # setting PS1
  # mshex/set-prompt '\e[34m' '\e[m'

  # aliases
  alias ls='ls --color=auto --show-control-chars'
  shopt -s completion_strip_exe &>/dev/null

  if type psforest &>/dev/null; then
    alias p='psforest'
  else
    alias p='ps uax'
  fi

  # emacs
  if [[ $TERM == cygwin && ! $ROSATERM ]]; then
    function emacs() (
      CYGWIN=tty /bin/emacs -nw "$@"
      local ret=$?
      stty echo -nl
      return "$ret"
    )
  fi

  # #mwg_bashrc_ecl_sock="/tmp/emacs$(id -u)/server"
  # mwg_bashrc_ecl_sock="/tmp/emacs$UID/server"
  # function ecl(){
  #   if test ! -e "$mwg_bashrc_ecl_sock"; then
  #     emacs --daemon
  #   fi
  #   emacsclient -nw "$@"
  # }

  function cygpath {
    if (($#)); then
      command cygpath "$@"
    else
      command cygpath -w "$PWD"
    fi
  }

  # --action=runas from http://inaz2.hatenablog.com/entry/2015/11/12/233356
  _mshex_cygwin_sudo_bash=$(cygpath -w /bin/bash)
  function sudo {
    if (($#==0)); then
      /usr/bin/cygstart --action=runas cmd /C "$_mshex_cygwin_sudo_bash" --login
    else
      local script=/tmp/$$.sudo.sh
      { [[ ! -e $script ]] || /bin/rm "$script"; } &&
        (umask 077; printf '%q ' "$@" > "$script") &&
        /usr/bin/cygstart --action=runas cmd /C "$_mshex_cygwin_sudo_bash --login $script & pause"
    fi
  }

  export LS_COLORS='rs=0:di=94:ln=96:mh=00:pi=40;33:so=95:do=95:bd=40;93:cd=40;93:or=40;91:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=92:*.tar=91:*.tgz=91:*.arj=91:*.taz=91:*.lzh=91:*.lzma=91:*.tlz=91:*.txz=91:*.zip=91:*.z=91:*.Z=91:*.dz=91:*.gz=91:*.lz=91:*.xz=91:*.bz2=91:*.bz=91:*.tbz=91:*.tbz2=91:*.tz=91:*.deb=91:*.rpm=91:*.jar=91:*.war=91:*.ear=91:*.sar=91:*.rar=91:*.ace=91:*.zoo=91:*.cpio=91:*.7z=91:*.rz=91:*.jpg=95:*.jpeg=95:*.gif=95:*.bmp=95:*.pbm=95:*.pgm=95:*.ppm=95:*.tga=95:*.xbm=95:*.xpm=95:*.tif=95:*.tiff=95:*.png=95:*.svg=95:*.svgz=95:*.mng=95:*.pcx=95:*.mov=95:*.mpg=95:*.mpeg=95:*.m2v=95:*.mkv=95:*.webm=95:*.ogm=95:*.mp4=95:*.m4v=95:*.mp4v=95:*.vob=95:*.qt=95:*.nuv=95:*.wmv=95:*.asf=95:*.rm=95:*.rmvb=95:*.flc=95:*.avi=95:*.fli=95:*.flv=95:*.gl=95:*.dl=95:*.xcf=95:*.xwd=95:*.yuv=95:*.cgm=95:*.emf=95:*.axv=95:*.anx=95:*.ogv=95:*.ogx=95:*.aac=36:*.au=36:*.flac=36:*.mid=36:*.midi=36:*.mka=36:*.mp3=36:*.mpc=36:*.ogg=36:*.ra=36:*.wav=36:*.axa=36:*.oga=36:*.spx=36:*.xspf=36:';

  export ICONV='iconv -c -f cp932 -t utf-8'
fi
