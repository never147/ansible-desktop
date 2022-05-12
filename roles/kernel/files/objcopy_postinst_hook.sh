#!/bin/bash
exec </dev/null >&2

set -e
echo "Running hook objcopy_update_hook for PACKAGE $DPKG_MAINTSCRIPT_PACKAGE"

# installkernel script calls postinst.d without any DEB_MAINT_PARAMS set
# linux-image-* postinst calls postinst.d with DEB_MAINT_PARAMS set
# do nothing in case linux-image-* calls this, as it already calls `linux-update-symlinks`
#[ -z "$DEB_MAINT_PARAMS" ] || exit 0

# installkernel must call postinst.d with two args, version & image_path
version="$1"
image_path="$2"
echo "Version: $version"
echo "Image: $image_path"

[ -n "$version" ] || exit 0
[ -n "$image_path" ] || exit 0

out_file_efi="/boot/efistub/kernel-${version}.efi"

echo "Updating xbootldr for kernel version $version"

#if echo "$DPKG_MAINTSCRIPT_PACKAGE" | grep -q "linux-image-" ;then
#    cp -f /boot/efistub/kernel.efi /boot/efistub/kernel.$(uname -r).efi
#    cp -f /boot/xbootldr/kernel.efi /boot/xbootldr/kernel.second.last.efi
#    echo "PACKAGE $DPKG_MAINTSCRIPT_PACKAGE matches pattern 'linux-image-' ... kernel warehouse & second last boot kernel updated"
#fi

objcopy --add-section .osrel=/etc/os-release \
    --change-section-vma .osrel=0x20000 \
    --add-section .cmdline=/boot/efistub/cmdline.txt \
    --change-section-vma .cmdline=0x30000 \
    --add-section .linux=/boot/vmlinuz \
    --change-section-vma .linux=0x40000 \
    --add-section .initrd=/boot/initrd.img \
    --change-section-vma .initrd=0x3000000 \
    -S /usr/lib/systemd/boot/efi/linuxx64.efi.stub "$out_file_efi"

if [ -d "/boot/efikeys" ] ;then
    sbsign --key /boot/efikeys/db.key \
        --cert /boot/efikeys/db.crt \
        --output /boot/efistub/kernel.efi \
        out_file_efi
    sbverify --cert /boot/efikeys/db.crt "${out_file_efi}"
fi

cp -f "${out_file_efi}" "/boot/xbootldr/kernel-${version}.efi"
sync

# Update loader menu
cat >"/boot/xbootldr/loader/entries/mint-${version}.conf" <<EOF
title     Linux Mint $version
efi       /kernel-${version}.efi
EOF

echo "Updated xbootldr"
exit 0
