FROM alpine:3.8

# Modified version of https://github.com/jessfraz/dockerfiles/blob/master/wireguard/install/Dockerfile
LABEL maintainer "Rakshit Menpara <deltasquare4@gmail.com>"

RUN apk add --no-cache \
        build-base \
        ca-certificates \
        elfutils-libelf \
        libelf-dev \
        libmnl-dev

# https://git.zx2c4.com/WireGuard/refs/
ENV WIREGUARD_VERSION 0.0.20181018

RUN set -x \
        && apk add --no-cache --virtual .build-deps \
                git \
        && git clone --depth 1 --branch "${WIREGUARD_VERSION}" https://git.zx2c4.com/WireGuard.git /wireguard \
        && ( \
                cd /wireguard/src \
                && make tools \
                && make -C tools install \
                && make -C tools clean \
        ) \
        && apk del .build-deps

COPY scripts/* /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD [ "/usr/local/bin/run.sh" ]
