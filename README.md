# Buildroot External Tree for Allwinner V3S Patches

This repository contains patches that fix compilation issues for the Allwinner V3S on the Sipeed LicheePi Zero board.

If you don't have a lot of idea what are you doing go to: [Sunxi Wiki](https://linux-sunxi.org/Main_Page "Unofficial wiki for allwinner CPU's")

## Usage

1. Clone this repository (prefereably outside buildroot root directory): `https://github.com/grepson/buildroot-v3s.git`
2. Configure your board in buildroot with environment variable:
``` bash
BR2_EXTERNAL=/path/to/cloned/repository
```
3. run `make` with your desired params to build the image. NOTE: be sure to use GCC 12 not 13, since it is crashing on this grandpa hardware :D

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

