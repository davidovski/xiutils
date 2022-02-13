#!/bin/bash
# This script is intended for root users to automatically mount requried dirs and chroot into an installed system
# simplifed version of arch-chroot from <https://github.com/archlinux/arch-install-scripts>

args=$@
target=$1

die() { printf "$@\n"; exit 1;}

ignore_error() {
  "$@" 2>/dev/null
  return 0
}

chroot_add_mount() {
  mount "$@" && CHROOT_ACTIVE_MOUNTS=("$2" "${CHROOT_ACTIVE_MOUNTS[@]}")
}

chroot_maybe_add_mount() {
  local cond=$1; shift
  if eval "$cond"; then
    chroot_add_mount "$@"
  fi
}

chroot_setup() {
  CHROOT_ACTIVE_MOUNTS=()
  [[ $(trap -p EXIT) ]] && die '(BUG): attempting to overwrite existing EXIT trap'
  trap 'chroot_teardown' EXIT

  chroot_add_mount proc "$target/proc" -t proc -o nosuid,noexec,nodev 
  chroot_add_mount sys "$target/sys" -t sysfs -o nosuid,noexec,nodev,ro 
  ignore_error chroot_maybe_add_mount "[[ -d '$1/sys/firmware/efi/efivars' ]]" \
      efivarfs "$target/sys/firmware/efi/efivars" -t efivarfs -o nosuid,noexec,nodev 
  chroot_add_mount udev "$target/dev" -t devtmpfs -o mode=0755,nosuid 
  chroot_add_mount devpts "$target/dev/pts" -t devpts -o mode=0620,gid=5,nosuid,noexec 
  chroot_add_mount shm "$target/dev/shm" -t tmpfs -o mode=1777,nosuid,nodev 
  chroot_add_mount /run "$target/run" --bind 
  chroot_add_mount tmp "$target/tmp" -t tmpfs -o mode=1777,strictatime,nodev,nosuid
}

chroot_teardown() {
  if (( ${#CHROOT_ACTIVE_MOUNTS[@]} )); then
    umount "${CHROOT_ACTIVE_MOUNTS[@]}"
  fi
  unset CHROOT_ACTIVE_MOUNTS
}

[ "$EUID" -eq 0 ] || die "Please run this as root"
[[ -d $target ]] || die "$target is not a directory; cannot chroot!"

chroot_setup $@

if [ $# -gt 1 ]; then
    chroot $@ 
else
    chroot $@ /bin/sh -l
fi
