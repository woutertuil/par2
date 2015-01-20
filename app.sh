### PAR2CMDLINE ###
_build_par2cmdline() {
local VERSION="0.4"
local FOLDER="par2cmdline-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://switch.dl.sourceforge.net/project/parchive/par2cmdline/0.4/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
patch "target/${FOLDER}/reedsolomon.cpp" src/reedsolomon.cpp.patch
pushd "target/${FOLDER}"
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
