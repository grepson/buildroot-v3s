# Buildroot External Tree for Allwinner V3S Patches

This repository contains patches that fix compilation issues for the Allwinner V3S on the Sipeed LicheePi Zero board.

If you don't have a lot of idea what are you doing go to: [Sunxi Wiki](https://linux-sunxi.org/Main_Page "Unofficial wiki for allwinner CPU's")

## Usage

1. Clone this repository (prefereably outside buildroot root directory): `https://github.com/grepson/buildroot-v3s.git`
2. Configure your board in buildroot with environment variable:
``` bash
BR2_EXTERNAL=/path/to/cloned/repository
```

3. Load defconfig file: `make <defconfig_name>`

4. Run `make` with your desired params to build the image. NOTE: be sure to use GCC 12 not 13, since it is crashing on this grandpa hardware :D

## Examples

My command to run compilation of all the code to generate .iso image (FORCE_UNSAFE_CONFIGURE because I'm running within docker):

``` bash
CROSS_COMPILE=arm-linux-gnueabihf- FORCE_UNSAFE_CONFIGURE=1 make -j8
```

## Fixes included:

### libcedarc Fixes for V3S Platform

This patch addresses several potential issues in the libcedarc library that could cause problems particularly on the V3S platform:

1. **Fixed null pointer dereference in sbmStream.c**:
   - Added `pSbm = NULL` after freeing to prevent potential use-after-free bugs
   
2. **Ensured proper string null-termination**:
   - Added explicit null termination after `strncpy()` in omx_venc.c and omx_vdec.c
   - This prevents potential buffer overruns when strings are exactly OMX_MAX_STRINGNAME_SIZE in length

These fixes improve stability and prevent potential crashes during video encoding/decoding operations.

### Linux kernel (tested on 5.3.5)

This patch modifies assembly syntax in the Linux kernel to replace Solaris-style section directives with GNU-style equivalents. This ensures compatibility with Clang's integrated assembler, which does not support Solaris-style section flags.

1. Section directives using Solaris-style flags (e.g., #alloc, #execinstr) are replaced with GNU-style syntax (e.g., "ax" for executable and allocated sections).

2. The .type directive is updated from #object to %object for consistency with GNU assembly syntax.

## Known issues:

### RootFS to small

Error:

``` text
>>>   Generating filesystem image rootfs.ext2
mkdir -p /kernel/buildroot/output/images
rm -rf /kernel/buildroot/output/build/buildroot-fs/ext2
mkdir -p /kernel/buildroot/output/build/buildroot-fs/ext2
rsync -auH --exclude=/THIS_IS_NOT_YOUR_ROOT_FILESYSTEM /kernel/buildroot/output/target/ /kernel/buildroot/output/build/buildroot-fs/ext2/target
echo '#!/bin/sh' > /kernel/buildroot/output/build/buildroot-fs/ext2/fakeroot
echo "set -e" >> /kernel/buildroot/output/build/buildroot-fs/ext2/fakeroot
echo "chown -h -R 0:0 /kernel/buildroot/output/build/buildroot-fs/ext2/target" >> /kernel/buildroot/output/build/buildroot-fs/ext2/fakeroot
PATH="/kernel/buildroot/output/host/bin:/kernel/buildroot/output/host/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" /kernel/buildroot/support/scripts/mkusers /kernel/buildroot/output/build/buildroot-fs/full_users_table.txt /kernel/buildroot/output/build/buildroot-fs/ext2/target >> /kernel/buildroot/output/build/buildroot-fs/ext2/fakeroot
echo "/kernel/buildroot/output/host/bin/makedevs -d /kernel/buildroot/output/build/buildroot-fs/full_devices_table.txt /kernel/buildroot/output/build/buildroot-fs/ext2/target" >> /kernel/buildroot/output/build/buildroot-fs/ext2/fakeroot
printf '   	rm -rf /kernel/buildroot/output/build/buildroot-fs/ext2/target/usr/lib/udev/hwdb.d/ /kernel/buildroot/output/build/buildroot-fs/ext2/target/etc/udev/hwdb.d/\n' >> /kernel/buildroot/output/build/buildroot-fs/ext2/fakeroot
echo "find /kernel/buildroot/output/build/buildroot-fs/ext2/target/run/ -mindepth 1 -prune -print0 | xargs -0r rm -rf --" >> /kernel/buildroot/output/build/buildroot-fs/ext2/fakeroot
echo "find /kernel/buildroot/output/build/buildroot-fs/ext2/target/tmp/ -mindepth 1 -prune -print0 | xargs -0r rm -rf --" >> /kernel/buildroot/output/build/buildroot-fs/ext2/fakeroot
printf '   \n' >> /kernel/buildroot/output/build/buildroot-fs/ext2/fakeroot
printf '   \n' >> /kernel/buildroot/output/build/buildroot-fs/ext2/fakeroot
printf '   	rm -f /kernel/buildroot/output/images/rootfs.ext2\n	/kernel/buildroot/output/host/sbin/mkfs.ext4 -d /kernel/buildroot/output/build/buildroot-fs/ext2/target -N 0 -m 5 -L "rootfs" -I 256 -O ^64bit /kernel/buildroot/output/images/rootfs.ext2 "60M" || { ret=$?; echo "*** Maybe you need to increase the filesystem size (BR2_TARGET_ROOTFS_EXT2_SIZE)" 1>&2; exit $ret; }\n' >> /kernel/buildroot/output/build/buildroot-fs/ext2/fakeroot
chmod a+x /kernel/buildroot/output/build/buildroot-fs/ext2/fakeroot
PATH="/kernel/buildroot/output/host/bin:/kernel/buildroot/output/host/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" FAKEROOTDONTTRYCHOWN=1 /kernel/buildroot/output/host/bin/fakeroot -- /kernel/buildroot/output/build/buildroot-fs/ext2/fakeroot
rootdir=/kernel/buildroot/output/build/buildroot-fs/ext2/target
table='/kernel/buildroot/output/build/buildroot-fs/full_devices_table.txt'
mke2fs 1.47.2 (1-Jan-2025)
Creating regular file /kernel/buildroot/output/images/rootfs.ext2
64-bit filesystem support is not enabled.  The larger fields afforded by this feature enable full-strength checksumming.  Pass -O 64bit to rectify.
Creating filesystem with 61440 1k blocks and 15360 inodes
Filesystem UUID: 88fa594c-91d0-48b0-a977-5e93f726dfbc
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Copying files into the device: __populate_fs: Could not allocate block in ext2 filesystem while writing file "magic.mgc"
mkfs.ext4: Could not allocate block in ext2 filesystem while populating file system
*** Maybe you need to increase the filesystem size (BR2_TARGET_ROOTFS_EXT2_SIZE)
make: *** [fs/ext2/ext2.mk:65: /kernel/buildroot/output/images/rootfs.ext2] Error 1
```

Default settings for v3s defconfig included in buildroot itself has too small rootfs (60mb) I've changed this limit in the included: `licheepi_zero_v3s_defconfig` to 100mb.
To fix this problem in the defconfig provided by buildroot just increase it's size in `make menucionfig`

```
Filesystem images  --->
    (60M) Size of the filesystem in bytes
```

Set it to 100mb or something that will fit `magic.mgc` into rootfs.
