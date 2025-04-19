#!/usr/bin/env bash
set -euo pipefail

# Simple flag parser
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      export FORCE_BUILD=1
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

ROUTER_HOST="${ROUTER_HOST:-$ROUTER_HOST}"
TARGET="${TARGET:-$TARGET}"
PROFILE="${PROFILE:-$PROFILE}"
CUSTOM_PACKAGES_FILE="${CUSTOM_PACKAGES_FILE:-$CUSTOM_PACKAGES_FILE}"
EXCLUDE_PACKAGES_FILE="${EXCLUDE_PACKAGES_FILE:-$EXCLUDE_PACKAGES_FILE}"
FORCE_BUILD="${FORCE_BUILD:-0}"
BASE_URL="https://downloads.openwrt.org/releases"

fetch_latest_version() {
  curl -s "$BASE_URL/" |
    grep -Eo 'href="[0-9]+\.[0-9]+\.[0-9]+/' |
    sed 's/href="//;s|/||' |
    sort -V |
    tail -n 1
}

get_installed_version() {
  if VERSION=$(ssh "$ROUTER_HOST" ". /etc/os-release && echo \$VERSION"); then
    echo $VERSION
  else
    echo "Latest installed version unknown."
    exit 1
  fi
}

download_imagebuilder() {
  local version="$1"
  echo "Version: $version"
  local target_arch="${TARGET//\//-}"
  echo "Target Arch: $target_arch"

  echo "🔽 Downloading ImageBuilder for OpenWrt $version..."

  local listing_url="${BASE_URL}/${version}/targets/${TARGET}/"
  archive_name=$(curl -s "$listing_url" | grep -oE "openwrt-imagebuilder-${version}-${target_arch}[^\"']+\.tar\.zst" | head -n1)

  if [[ -z "$archive_name" ]]; then
    echo "❌ Could not find ImageBuilder for version $version at $listing_url"
    exit 1
  fi

  mkdir -p imagebuilder
  wget -q "${listing_url}${archive_name}" -O "imagebuilder/${archive_name}"
  tar -xf "imagebuilder/${archive_name}" -C imagebuilder/
}

build_image() {
  local version="$1"
  local builder_dir
  builder_dir=$(find imagebuilder -type d -name "openwrt-imagebuilder-*${version}*" | head -n1)

  if [[ -z "$builder_dir" ]]; then
    echo "❌ ImageBuilder directory not found after extraction"
    exit 1
  fi

  echo "🏗️  Building custom image for version ${version}..."

  echo ""
  echo "Using config:"
  echo "  ROUTER_HOST = $ROUTER_HOST"
  echo "  TARGET = $TARGET"
  echo "  PROFILE = $PROFILE"
  echo "  CUSTOM_PACKAGES_FILE = $CUSTOM_PACKAGES_FILE"
  echo "  EXCLUDE_PACKAGES_FILE = $EXCLUDE_PACKAGES_FILE"

  local custom_packages=""
  custom_packages=$(tr '\n' ' ' < "$CUSTOM_PACKAGES_FILE")
  local exclude_package=""
  exclude_packages=$(awk ' { for(i=1;i<=NF;i++) printf "-%s ", $i } ' "$EXCLUDE_PACKAGES_FILE" | sed 's/ $//')

  pushd "$builder_dir" > /dev/null

  make image PROFILE="$PROFILE" PACKAGES="$custom_packages $exclude_packages"

  popd > /dev/null
  OUTFILE=$(find imagebuilder/openwrt-imagebuilder-"$version"-mvebu-cortexa9.Linux-x86_64/bin/targets/"$TARGET" -name *sysupgrade*  2>/dev/null | head -n1 )
  cp "$OUTFILE" ~/Downloads

  echo "✅ Build complete. Check your downloads folder!"
}

main() {
  echo "🔍 Checking latest available version from OpenWRT..."
  latest_version=$(fetch_latest_version)
  echo "🔍 Checking installed version on ${ROUTER_HOST}..."
  installed_version=$(get_installed_version)

  echo "🆕 Latest version:    ${latest_version}"
  echo "📦 Installed version: ${installed_version}"

  if [[ "$installed_version" =~ $latest_version ]] && [[ "$FORCE_BUILD" = "0" ]]; then
    echo "✅ Already running the latest OpenWrt version (${latest_version}). Skipping build."
    echo "To build an image anyway, use the --force flag (Luke), e.g: nix run . -- --force"
    exit 0
  fi

  echo "🚧 Proceeding to build for ${ROUTER_HOST}..."
  download_imagebuilder "$latest_version"
  build_image "$latest_version"
}

main "$@"
