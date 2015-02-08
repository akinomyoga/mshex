#!/bin/sh

src="$1"
dst="$2"

sedrules=
ascii_nl='
'

if test ! -x /bin/bash; then
  # Android など /bin/... が異なる場所にある環境がある

  bash_path="$BASH"
  if test ! -x "$bash_path"; then
    bash_path="$(type -p bash 2>/dev/null)"
    if test ! -x "$bash_path"; then
      bash_path="$(which bash 2>/dev/null)"
      if test ! -x "$bash_path"; then
        bash_path=''
      fi
    fi
  fi
  
  if test -n "$bash_path"; then
    sedrules="$sedrules"'1{s:/bin/bash:'"${bash_path//:/\\:}"':}'"$ascii_nl"
  fi
fi

if test -n "$sedrules"; then
  sed '1{s:/bin/bash:'"${bash_path//:/\\:}"':}' "$src" > "$dst"

  # touch -r reference file に対応していない場合もある
  touch -r "$src" "$dst" 2>/dev/null

  chmod 755 "$dst"
else
  cp -p "$src" "$dst"
fi
