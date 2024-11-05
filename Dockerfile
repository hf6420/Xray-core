FROM --platform=$BUILDPLATFORM golang:alpine AS build

WORKDIR /src

COPY . .

ARG TARGETOS
ARG TARGETARCH

RUN GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0 go build -o xray -trimpath -ldflags "-s -w -buildid=" ./main

ADD https://github.com/v2fly/geoip/releases/latest/download/geoip.dat /v2fly/geoip.dat
ADD https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat /v2fly/geosite.dat
ADD https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat /loyalsoldier/geoip.dat
ADD https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat /loyalsoldier/geosite.dat

FROM alpine:3.15.11

WORKDIR /var/log/xray

COPY .github/docker/files/config.json /etc/xray/config.json
COPY --from=build --chmod=755 /src/xray /usr/bin/xray

USER root
WORKDIR /root

ARG TZ=Asia/Shanghai
ENV TZ=$TZ

VOLUME /etc/xray
ENTRYPOINT [ "/usr/bin/xray" ]
CMD [ "-config", "/etc/xray/config.json" ]

ARG flavor=v2fly
COPY --from=build --chmod=644 /$flavor /usr/share/xray
