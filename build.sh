#!/usr/bin/env bash

### bash best practices ###
# exit on error code
set -o errexit
# exit on unset variable
set -o nounset
# return error of last failed command in pipe
set -o pipefail
# expand aliases
shopt -s expand_aliases
# print trace
set -o xtrace

### logfile ###
timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
logfile="logfile_${timestamp}.txt"
echo "${0} ${@}" > "${logfile}"
# save stdout to logfile
exec 1> >(tee -a "${logfile}")
# redirect errors to stdout
exec 2> >(tee -a "${logfile}" >&2)

### environment variables ###
. crosscompile.sh
export NAME="par2"
export DEST="/mnt/DroboFS/Shares/DroboApps/${NAME}"
export DEPS="${PWD}/target/install"
export CFLAGS="$CFLAGS -Os -fPIC"
export CXXFLAGS="$CXXFLAGS $CFLAGS"
export CPPFLAGS="-I${DEPS}/include"
export LDFLAGS="${LDFLAGS:-} -Wl,-rpath,${DEST}/lib -L${DEST}/lib"
alias make="make -j8 V=1 VERBOSE=1"

# $1: file
# $2: url
# $3: folder
_download_tgz() {
  [[ ! -f "download/${1}" ]] && wget -O "download/${1}" "${2}"
  [[ -d "target/${3}" ]] && rm -v -fr "target/${3}"
  [[ ! -d "target/${3}" ]] && tar -zxvf "download/${1}" -C target
}

# $1: folder
# $2: url
_download_git() {
  [[ -d "target/${1}" ]] && rm -v -fr "target/${1}"
  [[ ! -d "target/${1}" ]] && git clone "${2}" "target/${1}"
}

### PAR2CMDLINE ###
_build_par2cmdline() {
local VERSION="0.4"
local FOLDER="par2cmdline-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://switch.dl.sourceforge.net/project/parchive/par2cmdline/0.4/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
patch target/"${FOLDER}"/reedsolomon.cpp src/reedsolomon.cpp.patch
pushd target/"${FOLDER}"
./configure --host=arm-none-linux-gnueabi --prefix="${DEST}"
make
make install
popd
}

### BUILD ###
_build() {
  _build_par2cmdline
  _package
}

_create_tgz() {
  local appfile="${PWD}/${NAME}.tgz"

  if [[ -f "${appfile}" ]]; then
    rm -v "${appfile}"
  fi

  pushd "${DEST}"
  tar --verbose --create --numeric-owner --owner=0 --group=0 --gzip --file "${appfile}" *
  popd
}

_package() {
  cp -v -aR src/dest/* "${DEST}"/
  find "${DEST}" -name "._*" -print -delete
  _create_tgz
}

_clean() {
  rm -v -fr "${DEPS}"
  rm -v -fr "${DEST}"
  rm -v -fr target/*
}

_dist_clean() {
  _clean
  rm -v -f logfile*
  rm -v -fr download/*
}

case "${1:-}" in
  clean)     _clean ;;
  distclean) _dist_clean ;;
  package)   _package ;;
  "")        _build ;;
  *)         _build_${1} ;;
esac
