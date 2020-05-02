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

disks=()
ndisk_per_line=5
function initialize {
  disks=()

  local -a disk_names
  disk_names=(/sys/block/*/stat)
  disk_names=("${disk_names[@]%/stat}")
  disk_names=("${disk_names[@]#/sys/block/}")

  local i=0 sec disk
  local -a out=()
  for disk in "${disk_names[@]}"; do
    [[ $disk == loop* ]] && continue

    read sec < /sys/block/$disk/queue/physical_block_size
    sector_size[i]=$sec

    local "${varnames[@]}"
    load-stat "$disk"
    ((rprev[i]!=0&&wprev[i]!=0)) || continue
    disks+=("$disk")
    ((i++))
  done

  local w=$(((COLUMNS-1)/14))
  local nline=$(((${#disks[@]}+w-1)/w))
  ndisk_per_line=$(((${#disks[@]}+nline-1)/nline))
}

function hread {
  local value=$1
  ret=${value}B sgr=
  ((${#ret}<=6)) && return
  ret=$((value/=1024))KB sgr=$'\e[34m'
  ((${#ret}<=6)) && return
  ret=$((value/=1024))MB sgr=$'\e[32m'
  ((${#ret}<=6)) && return
  ret=$((value/=1024))GB sgr=$'\e[31m'
  ((${#ret}<=6)) && return
  ret=$((value/=1024))TB sgr=$'\e[91m'
}
function print-disk-line {
  local i disk out=
  for ((i=0;i<${#disks[@]};i++)); do
    local disk=${disks[i]}
    printf -v disk '%6s' "$disk"
    printf -v disk '%-13s' "$disk"
    out=$out"$disk "
    (((i+1)%ndisk_per_line==0)) && out=$out$'\n'
  done
  out=$out
  if ((${#disks[@]}%ndisk_per_line!=0)); then
    out=$out$'\n'
  fi

  local line=${out%%$'\n'*}; line=${line//?/-}
  echo "$line"
  printf %s "$out"
}

update_count=0
function update {
  local i disk ret sgr sgr0=$'\e[m'

  ((update_count++%20==0)) &&
    print-disk-line

  local read write out=
  for ((i=0;i<${#disks[@]};i++)); do
    disk=${disks[i]}

    local "${varnames[@]}"
    load-stat "$disk"
    hread $((rs*sector_size[i])); printf -v read '%s%6s%s' "$sgr" "$ret" "$sgr0"
    hread $((ws*sector_size[i])); printf -v write '%s%-6s%s' "$sgr" "$ret" "$sgr0"
    out=$out"$read/$write "
    (((i+1)%ndisk_per_line==0)) && out=$out$'\n'
  done
  if ((${#disks[@]}%ndisk_per_line!=0)); then
    out=$out$'\n'
  fi
  printf %s "$out"
}

initialize
while :; do
  sleep ${1:-1}
  update
done
