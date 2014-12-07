FROM debian:jessie
MAINTAINER Sébastien NEDJAR <sebastien@labaixbidouille.com>

RUN apt-get update -q \
    && apt-get install -y \
		libhidapi-hidraw0 \
		libusb-0.1-4 \
		libusb-1.0-0 \
		libhidapi-dev \
                libusb-1.0-0-dev \
		libusb-dev \
		libtool \ 
		make \
		automake \
		pkg-config \
		gcc-arm-none-eabi \
		gdb-arm-none-eabi \
                git \ 
    && mkdir /usr/src/; cd /usr/src/ \ 
    && git clone --depth 1 https://github.com/ntfreak/openocd.git \
    && cd openocd \ 
    && ./bootstrap \ 
    && ./configure --enable-stlink --enable-jlink --enable-ftdi --enable-cmsis-dap \
    && make -j"$(nproc)" \
    && make install-strip \
    && cd .. \
    && rm -rf openocd \
    && apt-get purge -y --auto-remove \ 
		libhidapi-dev \
                libusb-1.0-0-dev \
                libusb-dev \
                libtool \
                make \
                automake \
                pkg-config \
		git \
		gcc-arm-none-eabi \
                gdb-arm-none-eabi \ 
    && rm -rf /var/lib/apt/lists/*

RUN cp /usr/local/share/openocd/contrib/99-openocd.rules /etc/udev/rules.d/99-openocd.rules
ENTRYPOINT ["/usr/local/bin/openocd"]
