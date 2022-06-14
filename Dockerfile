FROM alpine:3.16

COPY *.sh /
RUN apk add restic \
    rclone \
    curl \
    mysql-client \
    postgresql-client \
    openssh-client --no-cache \
    && mkdir /backup-providers.d && mkdir /setup.d && \
    ln -s /launcher.sh /usr/local/bin/launcher && \
    ln -s /setup.sh /usr/local/bin/setup

WORKDIR /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["backup"]