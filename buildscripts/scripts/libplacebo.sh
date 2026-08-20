#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf $build
	exit 0
else
	exit 255
fi

unset CC CXX # meson wants these unset

# mpv only uses the OpenGL renderer here; Vulkan and the shader compilers
# would pull in toolchains that are not part of this build.
# Static: bundle_*.sh only ships libmpv.so, and mpv is configured with
# --prefer-static, so libplacebo has to end up inside libmpv.so.
CFLAGS=-fPIC CXXFLAGS=-fPIC meson setup $build --cross-file "$prefix_dir"/crossfile.txt \
	--default-library static \
	-Dopengl=enabled \
	-Dgl-proc-addr=disabled \
	-Dvulkan=disabled \
	-Dvk-proc-addr=disabled \
	-Dd3d11=disabled \
	-Dglslang=disabled \
	-Dshaderc=disabled \
	-Dlcms=disabled \
	-Ddovi=disabled \
	-Dlibdovi=disabled \
	-Dunwind=disabled \
	-Dxxhash=disabled \
	-Ddemos=false \
	-Dtests=false \
	-Dbench=false \
	-Dfuzz=false

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install
