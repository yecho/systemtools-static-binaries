#!/bin/sh

# https://github.com/moparisthebest/static-curl/blob/master/build.sh
# to test locally, run one of:
# docker run --rm -v $(pwd):/tmp -w /tmp -e ARCH=amd64 alpine /tmp/build.sh
# docker run --rm -v $(pwd):/tmp -w /tmp -e ARCH=aarch64 multiarch/alpine:aarch64-latest-stable /tmp/build.sh
# docker run --rm -v $(pwd):/tmp -w /tmp -e ARCH=ARCH_HERE ALPINE_IMAGE_HERE /tmp/build.sh

set -exu

#apk add build-base clang openssl-dev nghttp2-dev nghttp2-static libssh2-dev libssh2-static
#apk add openssl-libs-static zlib-static || true

if [ ! -f curl-${CURL_VERSION}.tar.gz ]
then

    wget https://curl.se/download/curl-${CURL_VERSION}.tar.gz \
        https://curl.se/download/curl-${CURL_VERSION}.tar.gz.asc

    echo "$CHECKSUM curl-${CURL_VERSION}.tar.gz" | sha256sum -c
    bbchecksig.sh "mykey.asc" "curl-${CURL_VERSION}.tar.gz.asc" "curl-${CURL_VERSION}.tar.gz"

fi

rm -rf "curl-${CURL_VERSION}/"
tar xzf curl-${CURL_VERSION}.tar.gz

cd curl-${CURL_VERSION}/

# gcc is apparantly incapable of building a static binary, even gcc -static helloworld.c ends up linked to libc, instead of solving, use clang
export CC=clang

ARCH=$ARCH LDFLAGS="-static" PKG_CONFIG="pkg-config --static" ./configure --disable-shared --enable-static \
    --with-openssl \
    --with-zlib \
    --with-zstd \
    --enable-ipv6 \
    --enable-unix-sockets \
    --without-libidn2 \
    --with-nghttp2 \
    --with-pic \
    --enable-websockets \
    --without-libssh2 \
    --without-libpsl \
    --disable-ldap \
    --disable-brotli

ARCH=$ARCH make -j${PARALLEL} V=1 LDFLAGS="-static -all-static"

# binary is ~13M before stripping, 2.6M after
strip src/curl

# exit with error code 1 if the executable is dynamic, not static
ldd src/curl && exit 1 || true

# we only want to save curl here
mv src/curl "/dist/curl.$ARCH"
