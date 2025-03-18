ARG BASEIMAGE
FROM ${BASEIMAGE}

ARG socatversion=1.8.0.3
ARG ncurses_version=6.5
ARG readline_version=8.2
ARG openssl_version=3.4.1
ARG ARCH=amd64
ARG PARALLEL=4
ARG CHECKSUM=a9f9eb6cfb9aa6b1b4b8fe260edbac3f2c743f294db1e362b932eb3feca37ba4

RUN apk add --no-cache libcap-dev libcap-static sudo ncurses ncurses-static ncurses-dev
RUN echo "builduser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER builduser

RUN wget http://invisible-mirror.net/archives/ncurses/ncurses-${ncurses_version}.tar.gz && \
    tar zxf ncurses-${ncurses_version}.tar.gz && \
    pushd ncurses-${ncurses_version} && \
    CC='/usr/bin/gcc -static' CFLAGS='-fPIC' ./configure --disable-shared --enable-static && \
    make -j${PARALLEL} && \
    sudo apk del ncurses ncurses-dev && \
    popd

RUN wget ftp://ftp.cwru.edu/pub/bash/readline-${readline_version}.tar.gz && \
    tar xzvf readline-${readline_version}.tar.gz && \
    pushd readline-${readline_version} && \
    CC='/usr/bin/gcc -static' CFLAGS='-fPIC' ./configure --disable-shared --enable-static && \
    make -j${PARALLEL} && \
    popd

RUN wget https://github.com/openssl/openssl/releases/download/openssl-${openssl_version}/openssl-${openssl_version}.tar.gz && \
    tar zxvf openssl-${openssl_version}.tar.gz && \
    pushd openssl-${openssl_version} && \
    CC='/usr/bin/gcc -static' ./Configure no-shared no-async linux-${ARCH} && \
    make -j${PARALLEL} && \
    popd

RUN wget http://www.dest-unreach.org/socat/download/socat-${socatversion}.tar.gz && \
    echo "$CHECKSUM socat-${socatversion}.tar.gz" | sha256sum -c && \
    tar xzf socat-${socatversion}.tar.gz && \
    pushd socat-${socatversion} && \
    CC='/usr/bin/gcc -static' \
        CFLAGS='-fPIC' \
        CPPFLAGS="-I/src -I/src/openssl-${openssl_version}/include -DNETDB_INTERNAL=-1" \
        LDFLAGS="-L/src/readline-${readline_version} -L/src/ncurses-${ncurses_version}/lib -L/src/openssl-${openssl_version}" \
        ./configure && \
    make -j${PARALLEL} && \
    mv socat /dist/socat.$ARCH && \
    strip /dist/socat.$ARCH && \
    popd

RUN chmod a+x /dist/socat.$ARCH && \
    /dist/socat.$ARCH -V | head -2 | tail -1 > /dist/.version-socat.$ARCH && \
    /dist/socat.$ARCH -V
