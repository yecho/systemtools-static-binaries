ARG BASEIMAGE
FROM ${BASEIMAGE}

ARG htopversion=3.4.0
ARG ncurses_version=6.5
ARG ARCH=amd64
ARG PARALLEL=4
ARG CHECKSUM=feaabd2d31ca27c09c367a3b1b547ea9f96105fc41f4dfa799e2f49daad5de29

RUN apk add --no-cache libcap-dev libcap-static lm-sensors lm-sensors-dev sudo ncurses ncurses-static ncurses-dev
RUN echo "builduser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER builduser


RUN wget https://invisible-island.net/archives/ncurses/ncurses-${ncurses_version}.tar.gz && \
    tar zxf ncurses-${ncurses_version}.tar.gz && \
    pushd ncurses-${ncurses_version} && \
    ./configure --without-database --with-fallbacks=screen-256color,xterm-256color,xterm,vt100 --without-xterm-new --disable-home-terminfo --with-termlib --enable-termcap --disable-database --host=arm-linux-gnue --enable-pc-files --enable-widec && \
    make -j${PARALLEL} && \
    sudo apk del ncurses ncurses-dev && \
    sudo make install && \
    popd

RUN wget https://github.com/htop-dev/htop/releases/download/${htopversion}/htop-${htopversion}.tar.xz && \
    echo "$CHECKSUM htop-${htopversion}.tar.xz" | sha256sum -c && \
    tar xvf htop-${htopversion}.tar.xz && \
    pushd htop-${htopversion} && \
    sed -i'' "s/^ VERSION='3.4.0-dev-3.4.0'$/ VERSION='3.4.0-android-compat-yanni'/" configure && chmod +x configure && \
    ./configure --enable-static --enable-unicode --enable-affinity --enable-capabilities --enable-sensors && \
    make -j${PARALLEL} && \
    mv htop /dist/htop.$ARCH && \
    strip /dist/htop.$ARCH && \
    popd

RUN chmod a+x /dist/htop.$ARCH && \
    /dist/htop.$ARCH --version | head -n 1 > /dist/.version-htop.$ARCH && \
    /dist/htop.$ARCH --version && \
    /dist/htop.$ARCH --help
