#!/bin/bash -e

## Dependency versions

v_platform=android-36
v_sdk=14742923_latest
v_ndk=29.0.14206865
v_sdk_build_tools=37.0.0
v_cmake=4.1.2

v_libunibreak=7_0
v_libass=0.17.5
v_harfbuzz=14.3.1
v_fribidi=1.0.16
v_freetype=2-14-3
v_libxml2=2.15.3
v_fontconfig=2.18.3
v_mbedtls=3.6.7
v_libplacebo=7.360.1
v_dav1d=1.5.4
v_ffmpeg=9.0.1
v_mpv=0.41.0

# Only used by the full / encoders-gpl flavors, which upstream does not build.
v_libogg=1.3.5
v_libvorbis=1.3.7
v_libvpx=1.13


## Dependency tree
# I would've used a dict but putting arrays in a dict is not a thing

dep_mbedtls=()
dep_dav1d=()
dep_libvorbis=(libogg)
if [ -n "${ENCODERS_GPL+x}" ]; then
	dep_ffmpeg=(mbedtls dav1d libxml2 libvorbis libvpx libx264)
else
	dep_ffmpeg=(mbedtls dav1d libxml2)
fi
dep_freetype2=()
dep_fontconfig=(libxml2 freetype)
dep_fribidi=()
dep_harfbuzz=()
dep_libunibreak=()
dep_libass=(freetype fontconfig fribidi harfbuzz libunibreak)
dep_lua=()
dep_libplacebo=()
dep_shaderc=()
# lua is left out on purpose: mpv.sh builds with -Dlua=disabled.
if [ -n "${ENCODERS_GPL+x}" ]; then
	dep_mpv=(ffmpeg libplacebo libass fftools_ffi)
else
	dep_mpv=(ffmpeg libplacebo libass)
fi
