MACHINE := 'ucm-imx8m-plus'

default:
  just --list

generate-defconfig:
  make "${MACHINE}_defconfig"

build-flash-bin:
  make -j$(nproc) CC=$CC LD=$LD AR=$AR OBJCOPY=$OBJCOPY flash.bin

build-bootloader:
  just generate-defconfig
  just build-flash-bin
