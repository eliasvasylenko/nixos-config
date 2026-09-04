usage() {
  cat <<EOF
Usage: install-host <host> <target> [nixos-anywhere-args...]

Install a host from this flake onto a running installer over SSH.
Example: install-host clear-air-turbulence nixos@192.168.10.20
EOF
}

if [[ $# -lt 2 || $1 == -h || $1 == --help ]]; then
  usage
  exit 0
fi

host=$1
target=$2
shift 2

flake_root=$(git rev-parse --show-toplevel)

if [[ ! -d $flake_root/hosts/$host ]]; then
  echo "Unknown host: $host" >&2
  echo "Available:" >&2
  for host_dir in "$flake_root"/hosts/*/; do
    printf '  %s\n' "$(basename "$host_dir")" >&2
  done
  exit 1
fi

args=(
  --flake "$flake_root#$host"
  --target-host "$target"
)

# Disko owns filesystems. Probe modules/platform on the target and write
# hosts/<name>/hardware-configuration.nix before the system is built.
if [[ -f $flake_root/hosts/$host/disk.nix ]]; then
  args+=(
    --generate-hardware-config
    nixos-generate-config
    "$flake_root/hosts/$host/hardware-configuration.nix"
  )
fi

exec nixos-anywhere "${args[@]}" "$@"
