#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	make clean
	exit 0
else
	exit 255
fi

$0 clean # separate building not supported, always clean

# ffmpeg >= 7 calls psa_crypto_init() on every TLS connection, and mpv opens
# the playlist, the subtitle rendition and the segments from several threads at
# once. PSA's global init is only thread-safe when MBEDTLS_THREADING_C is on
# (see docs/architecture/psa-thread-safety); both options ship commented out,
# and without them the concurrent init double-frees inside the entropy code.
python3 scripts/config.py set MBEDTLS_THREADING_C
python3 scripts/config.py set MBEDTLS_THREADING_PTHREAD

make CFLAGS=-fPIC CXXFLAGS=-fPIC -j$cores lib

# Not `make install`: that depends on the demo programs, and with threading
# enabled they link -lpthread, which bionic does not ship as a separate
# library. Install what this build actually consumes.
mkdir -p "$prefix_dir/include" "$prefix_dir/lib"
cp -rp include/mbedtls include/psa "$prefix_dir/include/"
cp -RP library/libmbedtls.a library/libmbedx509.a library/libmbedcrypto.a "$prefix_dir/lib/"
