#!/bin/bash
exec </dev/null >&2
set -e
version="$1"

[ -n "$version" ] || exit 0
echo "Updating xbootldr for kernel version $version"

rm -f \
    "/boot/efistub/kernel-${version}.efi" \
    "/boot/xbootldr/kernel-${version}.efi" \
    "/boot/xbootldr/loader/entries/mint-${version}.conf"
sync

echo "Updated xbootldr"
exit 0
