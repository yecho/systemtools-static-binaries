ARG BASEIMAGE
FROM ${BASEIMAGE}

ARG htopversion=3.3.0
ARG ARCH=amd64
ARG PARALLEL=4
ARG CHECKSUM=a69acf9b42ff592c4861010fce7d8006805f0d6ef0e8ee647a6ee6e59b743d5c

RUN apk add --no-cache libcap-dev libcap-static lm-sensors lm-sensors-dev sudo ncurses ncurses-static ncurses-dev
RUN echo "builduser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER builduser

RUN git clone https://github.com/mirror/ncurses.git && \
    pushd ncurses && \
    ./configure --without-database --with-fallbacks=screen-256color,xterm-256color,xterm,vt100 --without-xterm-new --disable-home-terminfo --with-termlib --enable-termcap --disable-database --host=arm-linux-gnue --enable-pc-files --enable-widec && \
    make -j${PARALLEL} && \
    sudo apk del ncurses ncurses-dev && \
    sudo make install && \
    popd

RUN wget https://github.com/htop-dev/htop/releases/download/${htopversion}/htop-${htopversion}.tar.xz && \
    echo "$CHECKSUM htop-${htopversion}.tar.xz" | sha256sum -c && \
    tar xvf htop-${htopversion}.tar.xz && \
    pushd htop-${htopversion} && \
    ./configure --enable-static --enable-unicode --enable-affinity --enable-capabilities --enable-sensors && \
    make -j${PARALLEL} && \
    mv htop /dist/htop.$ARCH && \
    strip /dist/htop.$ARCH && \
    popd

RUN chmod a+x /dist/htop.$ARCH && \
    /dist/htop.$ARCH --version | head -n 1 > /dist/.version-htop.$ARCH && \
    /dist/htop.$ARCH --version && \
    /dist/htop.$ARCH --help
