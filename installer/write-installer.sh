usage() {
  cat <<EOF
Usage: write-installer [--force] [device]

Build the installer ISO from this flake.
If a block device is given, write the ISO to that USB stick.

  --force   Write even if the device is not marked removable
EOF
}

flake_root=$(git rev-parse --show-toplevel)

force=0
if [[ ${1:-} == --force ]]; then
  force=1
  shift
fi

if [[ ${1:-} == -h || ${1:-} == --help ]]; then
  usage
  exit 0
fi

device=${1:-}

if [[ -n $device ]]; then
  if [[ $device != /dev/* && -b /dev/$device ]]; then
    device=/dev/$device
  fi
  if [[ ! -b $device ]]; then
    echo "Not a block device: $device" >&2
    exit 1
  fi

  base=$(basename "$device")
  if [[ -e /sys/class/block/$base/partition ]]; then
    echo "Refusing to write to partition $device; pass the whole disk (e.g. /dev/sdb)." >&2
    exit 1
  fi

  if [[ -f /sys/block/$base/removable && $(<"/sys/block/$base/removable") != 1 && $force -ne 1 ]]; then
    echo "$device is not marked removable. Re-run with --force if that is intentional." >&2
    lsblk "$device" >&2
    exit 1
  fi

  if mounted=$(lsblk -nlo MOUNTPOINT "$device" | awk 'NF') && [[ -n $mounted ]]; then
    echo "Unmount all filesystems on $device first:" >&2
    lsblk "$device" >&2
    exit 1
  fi

  echo "This will DESTROY all data on $device:"
  lsblk "$device"
  echo
  read -r -p "Write installer ISO to $device? Type yes to continue: " answer
  if [[ $answer != yes ]]; then
    echo "Aborted."
    exit 1
  fi

  if [[ $(id -u) -ne 0 ]]; then
    sudo -v
  fi
fi

echo "Building installer ISO..."
out=$(nix build --no-link --print-out-paths "$flake_root#installer")
shopt -s nullglob
isos=("$out"/iso/*.iso)
if [[ ${#isos[@]} -ne 1 ]]; then
  echo "Expected one ISO in $out/iso, found ${#isos[@]}" >&2
  exit 1
fi
iso=${isos[0]}
echo "ISO: $iso"

if [[ -z $device ]]; then
  echo
  echo "No device given. Write it with:"
  echo "  write-installer /dev/sdX"
  echo
  echo "Removable disks:"
  lsblk -d -o NAME,SIZE,MODEL,TRAN,RM
  exit 0
fi

run() {
  if [[ $(id -u) -ne 0 ]]; then
    sudo "$@"
  else
    "$@"
  fi
}

echo "Writing $iso to $device (sudo may ask for a password)..."
run dd "if=$iso" "of=$device" bs=4M status=progress conv=fsync
# Kill a leftover backup GPT past the ISO so firmware does not prefer it
# over the hybrid MBR. Do this after dd so a failed write cannot blank the stick.
iso_bytes=$(stat -c%s "$iso")
run dd if=/dev/zero "of=$device" bs=1M seek="$((iso_bytes / 1024 / 1024 + 1))" count=2 conv=fsync status=none || true
sync
run blockdev --rereadpt "$device" || true

if ! run fdisk -l "$device" | grep -q 'EFI'; then
  echo "Write finished but $device does not look like a hybrid ISO (no EFI partition)." >&2
  run fdisk -l "$device" >&2 || true
  exit 1
fi

mapfile -t mountpoints < <(lsblk -nrpo MOUNTPOINT "$device" | awk 'NF')
if [[ ${#mountpoints[@]} -gt 0 ]]; then
  echo "Unmounting ${mountpoints[*]}..."
  for mountpoint in "${mountpoints[@]}"; do
    run umount "$mountpoint"
  done
fi

echo "Wrote installer to $device ($(run blkid -o value -s LABEL "$device")). It is safe to remove."
