FROM --platform=$BUILDPLATFORM golang:alpine AS build

WORKDIR /src

COPY . .

ARG TARGETOS
ARG TARGETARCH

RUN GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0 go build -o xray -trimpath -ldflags "-s -w -buildid=" ./main

ADD https://github.com/v2fly/geoip/releases/latest/download/geoip.dat /v2fly/geoip.dat
ADD https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat /v2fly/geosite.dat

FROM alpine

WORKDIR /var/log/xray

COPY --from=build --chmod=644 /v2fly /usr/share/xray
COPY .github/docker/files/config.json /etc/xray/config.json
COPY --from=build --chmod=755 /src/xray /usr/bin/xray

USER root
WORKDIR /root

RUN apk add --no-cache tzdata ca-certificates

ENV TZ=Asia/Shanghai

VOLUME /etc/xray
ENTRYPOINT [ "/usr/bin/xray" ]
CMD [ "-config", "/etc/xray/config.json" ]
