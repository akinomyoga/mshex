#!/usr/bin/env bash

function main {
  if [[ $1 != *:* ]]; then
    return 1
  fi
  local host=${1%%:*} path=${1#*:} ntry=0
  rsync -avz "$1" "$2"
  while
    rsync -avz "$1" "$2" --rsync-path="inotifywait -q -e modify -e moved_to '$path' >/dev/null; sleep 3; rsync" && ((ntry=0))
    ((ntry++<5)) # 5回連続で失敗したら終了
  do
    sleep 1
  done
  return 1
}
main "$@"
