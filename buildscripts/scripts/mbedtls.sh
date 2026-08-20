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

make CFLAGS=-fPIC CXXFLAGS=-fPIC -j$cores no_test
make CFLAGS=-fPIC CXXFLAGS=-fPIC DESTDIR="$prefix_dir" install
