#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
COMPILER_DIR=/usr/local/arm-cross-compiler/install/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git remote -v
    git branch
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    ARCH=arm64
    CROSS_COMPILE=aarch64-none-linux-gnu-
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    make -j $(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
    make  ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    make  ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs
    
fi

echo "Adding the Image in outdir"
if [ -f ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
  sudo cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image $OUTDIR
  sudo chown root:root ${OUTDIR}/Image
  sudo chmod 644 ${OUTDIR}/Image
else
  echo "There is no Image created. Exiting."
  exit 
fi

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
  echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
  sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir -p rootfs/{bin,sbin,etc,proc,sys,dev,tmp,usr/{bin,sbin},lib,lib64,var,home}

if [ ! -d "${OUTDIR}/busybox" ]
then
    git clone https://git.busybox.net/busybox   
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make distclean
    make defconfig
    sed -i 's/^CONFIG_TC=y$/# CONFIG_TC is not set/' .config
else
    cd busybox
fi

# TODO: Make and install busybox
  make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu-  -j$(nproc)
  make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu-  CONFIG_PREFIX=${OUTDIR}/rootfs install
echo "Library dependencies"

interp="$(${CROSS_COMPILE}readelf -a busybox | grep 'program interpreter' |  sed -n 's/.*: \(.*\)]/\1/p' )"
SHARED=($(${CROSS_COMPILE}readelf -d busybox | awk -F'[][]' '/NEEDED/ {print $2}'))

# TODO: Add library dependencies to rootfs
if [ -f ${COMPILER_DIR}${interp} ]
then
  echo "Copying ${interp} in  ${OUTDIR}/rootfs/lib"
  sudo cp ${COMPILER_DIR}${interp}  ${OUTDIR}/rootfs/lib
else
  echo "Error file ${COMPILER_DIR}${interp}not found"
fi

for lib in "${SHARED[@]}"; do
  src=$(find  ${COMPILER_DIR} -type f -name *$lib* 2>/dev/null | head -n1)
  echo $src
  if [ -n "$src" ]; then
    echo "Copying $src -> ${OUTDIR}/rootfs/lib64"
    sudo cp -a "$src" "${OUTDIR}/rootfs/lib64"
  else
    echo "ERROR: cannot find $lib under ${OUTDIR}/rootfs/lib64 src:$src" >&2
  fi
done

# TODO: Make device nodes
cd ${OUTDIR}/rootfs/dev
sudo mknod -m 666 null c 1 3
sudo mknod -m 600 console c 5 1
# TODO: Clean and build the writer utility
cd ${FINDER_APP_DIR}
make clean
make CROSS_COMPILE=${CROSS_COMPILE} writer
sudo cp writer ${OUTDIR}/rootfs/home
sudo cp Makefile ${OUTDIR}/rootfs/home
# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
sudo cp finder.sh ${OUTDIR}/rootfs/home
sed -i '1s|^#!/bin/bash|#!/bin/sh|' ${OUTDIR}/rootfs/home/finder.sh
sudo cp -r ../conf ${OUTDIR}/rootfs/home
sudo cp finder-test.sh ${OUTDIR}/rootfs/home
sed -i 's|\.\./conf/assignment.txt|conf/assignment.txt|g' ${OUTDIR}/rootfs/home/finder-test.sh
sudo cp start-qemu-app.sh ${OUTDIR}/rootfs/home
sudo cp start-qemu-terminal.sh ${OUTDIR}/rootfs/home
sudo cp autorun-qemu.sh ${OUTDIR}/rootfs/home
# TODO: Chown the root directory
sudo chown -R root:root ${OUTDIR}/rootfs
# TODO: Create initramfs.cpio.gz
cd ${OUTDIR}/rootfs
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
gzip -f ${OUTDIR}/initramfs.cpio

