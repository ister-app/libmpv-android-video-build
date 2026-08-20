#!/bin/bash -e

## Dependency versions

v_sdk=9123335_latest
v_ndk=27.3.13750724
v_sdk_build_tools=33.0.2

v_libass=0.17.1
v_harfbuzz=7.2.0
v_fribidi=1.0.12
v_freetype=2-13-0
v_mbedtls=3.6.7
v_dav1d=1.2.0
v_libxml2=2.10.3
v_ffmpeg=9.0.1
# mpv v0.41.0
v_mpv=41f6a645068483470267271e1d09966ca3b9f413
# libplacebo has been a hard mpv dependency since v0.37
v_libplacebo=7.360.1
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
dep_libplacebo=()
dep_freetype2=()
dep_fribidi=()
dep_harfbuzz=()
dep_libass=(freetype fribidi harfbuzz)
dep_lua=()
dep_shaderc=()
if [ -n "${ENCODERS_GPL+x}" ]; then
	dep_mpv=(ffmpeg libplacebo libass fftools_ffi)
else
	dep_mpv=(ffmpeg libplacebo libass)
fi
