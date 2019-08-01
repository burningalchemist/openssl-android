#!/bin/bash
#
# http://wiki.openssl.org/index.php/Android
#

set -e
rm -rf prebuilt
mkdir prebuilt

OPENSSL_VERSION="openssl-1.0.2s"
#OPENSSL_VERSION="openssl-1.1.1c"

if [ ! -f "${OPENSSL_VERSION}.tar.gz" ]; then
  curl -O "https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz"
fi
tar xfz "${OPENSSL_VERSION}.tar.gz"

archs=(armeabi-v7a arm64-v8a)

for arch in ${archs[@]}; do
    xLIB="/lib"
    case ${arch} in
        "armeabi-v7a")
            _ANDROID_TARGET_SELECT=arch-arm
            _ANDROID_ARCH=arch-arm
            _ANDROID_API=android-14
            _ANDROID_EABI=arm-linux-androideabi-4.9
            configure_platform="android-armv7" ;;
        "arm64-v8a")
            _ANDROID_TARGET_SELECT=arch-arm64-v8a
            _ANDROID_ARCH=arch-arm64
            _ANDROID_API=android-21
            _ANDROID_EABI=aarch64-linux-android-4.9
            #no xLIB="/lib64"
            configure_platform="linux-generic64 -DL_ENDIAN" ;;
       "x86")
            _ANDROID_TARGET_SELECT=arch-x86
            _ANDROID_ARCH=arch-x86
            _ANDROID_EABI=x86-4.9
            configure_platform="android-x86" ;;
        "x86_64")
            _ANDROID_TARGET_SELECT=arch-x86_64
            _ANDROID_ARCH=arch-x86_64
            _ANDROID_EABI=x86_64-4.9
            xLIB="/lib64"
            configure_platform="linux-generic64" ;;
        *)
            configure_platform="linux-elf" ;;
    esac

    mkdir prebuilt/${arch}

    . ./setenv-android-mod.sh

    echo "CROSS COMPILE ENV : $CROSS_COMPILE"
    cd "${OPENSSL_VERSION}"

    xCFLAGS="-fPIC -DOPENSSL_PIC -DDSO_DLFCN -DHAVE_DLFCN_H -mandroid -I$ANDROID_DEV/include -B$ANDROID_DEV/$xLIB -O3 -fomit-frame-pointer -Wall"

    perl -pi -e 's/install: all install_docs install_sw/install: install_docs install_sw/g' Makefile.org
    ./Configure no-shared threads no-comp no-engine no-ssl2 no-ssl3 no-hw no-idea no-bf no-cast no-seed no-md2 $configure_platform $xCFLAGS
    # patch SONAME
    perl -pi -e 's/SHLIB_EXT=\.so\.\$\(SHLIB_MAJOR\)\.\$\(SHLIB_MINOR\)/SHLIB_EXT=\.so/g' Makefile
    perl -pi -e 's/SHARED_LIBS_LINK_EXTS=\.so\.\$\(SHLIB_MAJOR\) \.so//g' Makefile
    # quote injection for proper SONAME
    perl -pi -e 's/SHLIB_MAJOR=1/SHLIB_MAJOR=`/g' Makefile
    perl -pi -e 's/SHLIB_MINOR=0.0/SHLIB_MINOR=`/g' Makefile
    make clean
    make depend -j2
    make build_libs -j2

    file libcrypto.a
    file libssl.a
    cp libcrypto.a ../prebuilt/${arch}/libcrypto.a
    cp libssl.a ../prebuilt/${arch}/libssl.a

#   file libcrypto.so
#   file libssl.so
#   cp libcrypto.so ../prebuilt/${arch}/libcrypto.so
#   cp libssl.so ../prebuilt/${arch}/libssl.so
    cd ..
done
exit 0

