# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working in this repository.

## What this is

`ister-app`'s fork of `media-kit/libmpv-android-video-build`, which is itself a fork of
`jarnedemeulemeester/libmpv-android`. It cross-compiles libmpv for the four Android ABIs and
packages `libmpv.so` (plus media-kit's JNI helper) into per-ABI jars that
`ister-app/media-kit`'s `libs/android/media_kit_libs_android_video` downloads by URL + md5.

Upstream `jarnedemeulemeester/libmpv-android` is actively maintained (renovate keeps mpv, ffmpeg,
libplacebo and the NDK current) — **merge from it rather than bumping dependencies by hand**;
`git remote add upstream https://github.com/jarnedemeulemeester/libmpv-android.git`.

## What this fork keeps on top of upstream

- `buildscripts/flavors/{default,full,encoders-gpl}.sh` — the ffmpeg configurations. `bundle_*.sh`
  copies the chosen flavor to `scripts/ffmpeg.sh` before building. The player uses **default**.
- `mpv.sh` with `--prefer-static`, `--default-library shared` and `-Dgpl=false`: media_kit ships
  one LGPL `libmpv.so` with everything linked into it.
- `patches/mpv/mpv_lavc_set_java_vm.patch`, which exports `mpv_lavc_set_java_vm` so the JNI
  environment reaches libavcodec's mediacodec support. `patches-encoders-gpl/mpv/` symlinks it.
- The jar packaging and the release workflow; upstream's `libmpv/` Android module is deleted here.

## Build

CI (`.github/workflows/build.yaml`, `ubuntu-22.04`) installs the toolchain, then runs
`bundle_default.sh`, `bundle_full.sh` and `bundle_encoders-gpl.sh`. A push to `main` publishes a
**draft** release tagged `vnext`; promote it with
`gh release edit vnext --tag vX.Y.Z --draft=false` and then update the md5s in the consuming
`build.gradle`.

## Things that cost time to find out

- **API level is 24** (`build.sh`: `local apilvl=24`). NDK r29 no longer supports 21, and 24 is
  the Flutter default `minSdk` the player uses — do not raise it to upstream's 26 without also
  raising the app's `minSdk`, or older devices link and then fail at runtime.
- **mbedtls needs `MBEDTLS_THREADING_C`** (set through `scripts/config.py` in `mbedtls.sh`).
  ffmpeg ≥ 7 calls `psa_crypto_init()` on every TLS connection and mpv opens playlist, subtitles
  and segments concurrently; without the option the process aborts on the first https stream with
  `hardened_malloc: fatal allocator error: double free`, deep inside `mbedtls_entropy_func`.
- **Build `lib`, not `no_test`.** With threading enabled mbedtls' demo programs link `-lpthread`,
  which bionic does not ship separately, and `make install` depends on those programs. `mbedtls.sh`
  therefore copies the headers and static libraries itself.
- **ffmpeg 9 removed libpostproc**; `--disable-postproc` is now an unknown option.
- **fftools-ffi does not compile against ffmpeg 9** and has no newer revision, so the
  encoders-gpl flavor no longer links it.
- The CI installs meson/ninja/nasm/gperf/jinja2 itself and sets `IN_CI=1`; `download-sdk.sh`
  skips its own installation then.

## Debugging a crash on device

`gh run download <run-id> -n artifact` also yields `debug-symbols-*.zip`. Feed a logcat capture to
`ndk-stack -sym <dir with the unstripped libmpv.so> -dump crash.log` — that turns the tombstone
into file-and-line, which is how the mbedtls double free was pinned down.
