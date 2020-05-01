#!/usr/bin/env bash

# /sys/block/sda/stat
# http://akuwano.hatenablog.jp/entry/20120223/1330016926 より。
#
# Name            units         description
# ----            -----         -----------
# read I/Os       requests      読み込みの I/O 処理数
# read merges     requests      I/Oキューも含めた読み込みの I/O 処理数
# read sectors    sectors       読まれたセクタの数
# read ticks      milliseconds  読み込みリクエストの待ち時間
# write I/Os      requests      書き込みの I/O 処理数
# write merges    requests      I/Oキューも含めた書き込みの I/O 処理数
# write sectors   sectors       書かれたセクタの数
# write ticks     milliseconds  書き込みリクエストの待ち時間
# in_flight       requests      デバイスドライバに対して発行されているが処理されていないリクエスト数
# io_ticks        milliseconds  デバイスドライバにへのリクエストがキューに入っていたトータル時間
# time_in_queue   milliseconds  全リクエストのトータル待ち時間

varnames=(r rm rs rt w wm ws wt q qw qt)
function load-stat {
  local disk=$1 rest name
  read "${varnames[@]}" rest < "/sys/block/$disk/stat"
  for name in "${varnames[@]}"; do
    (($name-=${name}prev[i],${name}prev[i]+=$name))
  done
}

function initialize {
  disks=(/sys/block/*/stat)
  disks=("${disks[@]%/stat}")
  disks=("${disks[@]#/sys/block/}")

  local i sec
  for ((i=0;i<${#disks[@]};i++)); do
    local disk=${disks[i]}
    read sec < /sys/block/$disk/queue/physical_block_size
    sector_size[i]=$sec

    local "${varnames[@]}"
    load-stat "$disk"
  done
}

function hread {
  local value=$1
  ret=${value}B
  ((${#ret}<=6)) && return
  ret=$((value/=1024))KB
  ((${#ret}<=6)) && return
  ret=$((value/=1024))MB
  ((${#ret}<=6)) && return
  ret=$((value/=1024))GB
}

function update {
  local i disk ret
  printf '%s\n' --------------------
  for ((i=0;i<${#disks[@]};i++)); do
    disk=${disks[i]}

    local "${varnames[@]}"
    load-stat "$disk"
    hread $((rs*sector_size[i])); local read=$ret
    hread $((ws*sector_size[i])); local write=$ret
    [[ $disk != loop* ]] && ((rprev[i]!=0&&wprev[i]!=0)) &&
      printf '%5s R/W %6s/%-6s\n' "$disk" "$read" "$write" #"$q:$qw:$qt,$rt/$wt,(rw=$r/$w,m=$rm/$wm)"
  done
}

initialize
while :; do
  sleep ${1:-1}
  update
done
