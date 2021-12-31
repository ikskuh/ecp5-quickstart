FROM ubuntu:20.04

RUN ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get -y install \
    make pkg-config sudo  \
    python3-dev git cmake \
    g++ libboost-all-dev libeigen3-dev \
    build-essential clang bison flex \
    libreadline-dev gawk tcl-dev libffi-dev git \
    graphviz xdot pkg-config python3 libboost-system-dev \
    libboost-python-dev libboost-filesystem-dev zlib1g-dev \
    jq iverilog

RUN groupadd wheel
RUN useradd -m dev -g users -G wheel -G sudo

RUN echo 'dev:dev' | chpasswd
RUN echo 'root:root' | chpasswd

RUN echo "dev ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers.d/container
RUN echo "%wheel ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers.d/container
RUN echo "%sudo ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers.d/container

WORKDIR /opt

RUN git clone --recursive https://github.com/YosysHQ/prjtrellis
RUN cd /opt/prjtrellis/libtrellis  \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local . \
  && make -j8 \
  && sudo make install

RUN git clone --recursive https://github.com/YosysHQ/nextpnr
RUN cd /opt/nextpnr \
  && cmake . -DARCH=ecp5 -DTRELLIS_INSTALL_PREFIX=/usr/local \
  && make -j$(nproc) \
  && sudo make install

RUN git clone --recursive https://github.com/YosysHQ/yosys
RUN cd /opt/yosys \
  && make config-gcc \
  && make -j$(nproc) \
  && sudo make install

RUN git clone --recursive https://git.code.sf.net/p/openocd/code openocd
RUN cd /opt/openocd \
  && ./bootstrap \
  && ./configure \
  && make -j$(nproc) \
  && sudo make install

WORKDIR /mnt
ENTRYPOINT []
CMD /bin/bash