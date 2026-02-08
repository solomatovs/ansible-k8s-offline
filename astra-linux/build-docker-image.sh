#!/bin/sh

program=$(basename $0)
version=1.0

set -e

pkg_missing=false
# for required_pkg in docker.io debootstrap; do
#     if ! dpkg -l $required_pkg >/dev/null 2>/dev/null; then
#         printf 'Please install %s package\n' $required_pkg
#         pkg_missing=true
#     fi
# done
# if $pkg_missing; then
#     exit 1
# fi

# Check docker can be run without sudo
docker version 2>&1 >/dev/null ||\
    (printf 'Please run with sudo or add your account to `docker` group\n';\
    exit 1)

usage="\
Usage:
    $program -v
        Print program version

    $program -r REPOSITORY [-c CODENAME] -i IMAGE_NAME [-b]

        Create Docker image IMAGE_NAME based on REPOSITORY with CODENAME

        -v                Print version
        -r REPOSITORY     Address of the repository
        -c CODENAME       Codename (specified in $REPOSITORY/dists)
        -i IMAGE_NAME     Name of the image being created
        -b                Install base Astra Linux packages

default CODENAME is \"stable\""

invalid_args() {
      echo "${usage}" 1>&2
      exit 1
}

REPO=$REPO
IMAGE=$IMAGE
CODENAME="${CODENAME:-stable}"
install_base_pkgs=false

while getopts 'r:c:i:vb' option; do
  case $option in
    r)
      REPO=$OPTARG
      ;;
    i)
      IMAGE=$OPTARG
      ;;
    c)
      CODENAME=$OPTARG
      ;;
    b)
      install_base_pkgs=true
      ;;
    v)
      echo $program $version
      ;;
    ?)
      invalid_args
      ;;
  esac
done


if [ -z $REPO ]; then
    echo Please specify -r \(repository\) argument
fi
if [ -z $IMAGE ]; then
    echo Please specify -i \(image\) argument
fi
if [ -z $REPO ] || [ -z $IMAGE ]; then
    invalid_args
fi

ROOTFS_IMAGE="$IMAGE-rootfs"

TMPDIR=`mktemp -d`
cd $TMPDIR

cleanup() {
    cd $HOME
    # debootstrap leaves mounted /proc and /sys folders in chroot
    # when terminated by Ctrl-C
    sudo umount $TMPDIR/proc $TMPDIR/sys >/dev/null 2>/dev/null || true
    # Delete temporary data at exit
    sudo rm -rf $TMPDIR
}
trap cleanup EXIT

sudo -E debootstrap --no-check-gpg --variant=minbase \
    --components=main,contrib,non-free "$CODENAME" ./chroot "$REPO"

echo "deb $REPO $CODENAME contrib main non-free" | sudo tee ./chroot/etc/apt/sources.list

docker rmi "$ROOTFS_IMAGE" 2>/dev/null || true

sudo tar -C chroot -c . | docker import - "$ROOTFS_IMAGE"

docker rmi "$IMAGE" 2>/dev/null || true

if $install_base_pkgs; then
  cmd="echo Installing base packages && apt-get install -y parsec parsec-tests linux-astra-modules-common astra-safepolicy lsb-release acl perl-modules-5.28 ca-certificates"
else
  cmd="true"
fi

docker build --network=host --no-cache=true -t "$IMAGE" - <<EOF
FROM $ROOTFS_IMAGE
ENV TERM xterm-256color
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN $cmd
WORKDIR /
CMD bash
EOF

printf 'Docker image "%s" has been generated\n' "$IMAGE"
exit 0
