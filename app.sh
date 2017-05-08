### PAR2CMDLINE ###
_build_par2cmdline() {
local VERSION="mt"
local FOLDER="par2cmdline-${VERSION}"
local FILE="v${VERSION}.tar.gz"
local URL="https://github.com/Parchive/par2cmdline/archive/${FILE}"

git clone https://github.com/jkansanen/par2cmdline-mt.git
cd par2cmdline-mt
#patch "target/${FOLDER}/reedsolomon.cpp" src/reedsolomon.cpp.patch

aclocal
automake --add-missing
autoconf
./configure --host="${HOST}" --prefix="${DEST}" --mandir="${DEST}/man"
make
make install
popd
}

### BUILD ###
_build() {
  _build_par2cmdline
  _package
}
