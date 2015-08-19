### PAR2CMDLINE ###
_build_par2cmdline() {
local VERSION="0.6.14"
local FOLDER="par2cmdline-${VERSION}"
local FILE="v${VERSION}.tar.gz"
local URL="https://github.com/Parchive/par2cmdline/archive/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
#patch "target/${FOLDER}/reedsolomon.cpp" src/reedsolomon.cpp.patch
pushd "target/${FOLDER}"
aclocal
automake --add-missing
autoconf
./configure --host="${HOST}" --prefix="${DEST}"
make
make install
popd
}

### BUILD ###
_build() {
  _build_par2cmdline
  _package
}
