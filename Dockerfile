FROM alpine:3.10

ENV RSPAMD_VERSION=1.9.4-r0
ENV BUILD_DATE=2019-05-29
ENV ALPINE_VERSION=3.10

LABEL maintainer="docker-dario@neomediatech.it" \ 
      org.label-schema.version=$RSPAMD_VERSION \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-type=Git \
      org.label-schema.vcs-url=https://github.com/Neomediatech/rspamd-honey-docker-alpine \
      org.label-schema.maintainer=Neomediatech

RUN apk update; apk upgrade ; apk add --no-cache tzdata; cp /usr/share/zoneinfo/Europe/Rome /etc/localtime ; \ 
    apk add --no-cache tini rspamd rspamd-controller rsyslog ca-certificates bash && \ 
    rm -rf /usr/local/share/doc /usr/local/share/man && \ 
    mkdir /run/rspamd

COPY conf/ /etc/rspamd
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=5 CMD rspamadm control -s /run/rspamd/rspamd.sock stat|grep -m1 uptime || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tini","--","rspamd","-i","-f"]
