FROM postgres:14.2-alpine3.15

COPY *.sh /
RUN apk add restic \
    rclone \
    curl \
    mysql-client \
    openssh-client --no-cache \
    && mkdir /backup-providers.d && mkdir /setup.d && \
    ln -s /launcher.sh /usr/local/bin/launcher && \
    ln -s /setup.sh /usr/local/bin/setup

WORKDIR /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["backup"]