#!/usr/bin/env bash

function main {
  if [[ $1 != *:* ]]; then
    return 1
  fi
  local host=${1%%:*} path=${1#*:} ntry=0
  rsync -avz "$1" "$2"
  while
    rsync -avz "$1" "$2" --rsync-path="inotifywait -q -e modify -e moved_to '$path' >/dev/null; sleep 3; rsync"
    local ext=$?

    # SIGINT: rsync seems to exit with status 20 when it receive SIGINT,
    # SIGTERM, or SIGHUP.  Also, for the most cases, it somehow returns 255
    # (unexplained error) for SIGINT.
    ((ext==130||ext==20||ext==255)) && return 130

    ((ext==0)) && ((ntry=0))
    ((ntry++<5)) # 5回連続で失敗したら終了
  do
    echo "sync.sh: rsync exit=$ext" >&2
    sleep 1
  done
  return 1
}
main "$@"
